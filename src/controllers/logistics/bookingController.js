// 1. Fix the Import (Removed curly braces assuming it's a default export)
import axios from "axios";
import nodemailer from 'nodemailer';
import ApiError from "../../utils/ApiError.js";
import db from "../../config/db.js";

/* -----------------------------------------------------
    HELPER: SEND PICKUP CONFIRMATION EMAIL
----------------------------------------------------- */
const sendPickupEmail = async (email, details) => {
    const transporter = nodemailer.createTransport({
        host: process.env.MAIL_HOST,
        port: parseInt(process.env.MAIL_PORT),
        secure: process.env.MAIL_SECURE === 'true',
        auth: {
            user: process.env.MAIL_USER,
            pass: process.env.MAIL_PASS,
        },
    });

    await transporter.sendMail({
        from: `"Smart Scrap BD Support" <${process.env.MAIL_USER}>`,
        to: email,
        subject: `Pickup Request Confirmed - ${details.bookingCode}`,
        html: `
        <div style="font-family: sans-serif; padding: 20px; border: 1px solid #10B981; border-radius: 15px; max-width: 600px;">
            <h2 style="color: #10B981;">Pickup Request Successful!</h2>
            <p>Hello <strong>${details.customerName}</strong>,</p>
            <p>Your recycling pickup request has been received and is now being processed.</p>
            <div style="background: #f8fafc; padding: 20px; border-radius: 10px; margin: 20px 0;">
                <p style="margin: 5px 0;"><strong>Booking Code:</strong> <span style="color: #10B981;">${details.bookingCode}</span></p>
                <p style="margin: 5px 0;"><strong>Estimated Value:</strong> ৳${details.totalEstMin}</p>
                <p style="margin: 5px 0;"><strong>Scheduled Date:</strong> ${details.scheduledDate}</p>
                <p style="margin: 5px 0;"><strong>Time Slot:</strong> ${details.timeSlot}</p>
            </div>
            <p>Our rider will contact you at <strong>${details.customerPhone}</strong>. Thank you for helping the environment!</p>
            <hr style="border: 0; border-top: 1px solid #eee; margin: 20px 0;" />
            <p style="font-size: 12px; color: #94a3b8;">Smart Scrap BD - Recycle for a Greener Tomorrow</p>
        </div>
    `,
    });
};

export const createPickup = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        await conn.beginTransaction();

        const userId = req.user.id;
        const {
            address_id,
            items,
            scheduled_date,
            scheduled_time_slot,
            customer_note,
            pickup_type
        } = req.body;

        // 1. Fetch Geo-Data
        const [addressRows] = await conn.query(
            "SELECT division_id, district_id, upazila_id FROM addresses WHERE id = ? AND user_id = ?",
            [address_id, userId]
        );

        if (!addressRows.length) {
            throw new ApiError(400, "Invalid address selected or unauthorized.");
        }

        const { division_id, district_id, upazila_id } = addressRows[0];

        // 2. Fetch Customer Info (Email, Phone, Name)
        const [customerRows] = await conn.query(
            `SELECT c.id, u.phone, u.full_name, u.email 
             FROM customers c 
             JOIN users u ON c.user_id = u.id 
             WHERE u.id = ?`,
            [userId]
        );
        if (!customerRows.length) throw new ApiError(404, "Customer profile not found.");

        const { id: customerId, phone: customerPhone, full_name: customerName, email: customerEmail } = customerRows[0];

        // 3. Parse Items
        const parsedItems = typeof items === 'string' ? JSON.parse(items) : items;
        const uploadedFiles = req.files || [];

        if (!parsedItems || parsedItems.length === 0) {
            throw new ApiError(400, "At least one scrap item is required.");
        }

        // 4. Generate Booking Code
        const bookingCode = `GS-${upazila_id || '0'}-${Date.now().toString().slice(-4)}`;

        // 5. Insert Master Pickup Record 
        const [pickupResult] = await conn.query(
            `INSERT INTO pickups (
                booking_code, customer_id, customer_address_id, 
                division_id, district_id, upazila_id,
                status, scheduled_date, scheduled_time_slot, 
                customer_note, pickup_type, created_at, updated_at
            ) VALUES (?, ?, ?, ?, ?, ?, 'pending', ?, ?, ?, ?, NOW(), NOW())`,
            [
                bookingCode,
                customerId,
                address_id,
                division_id,
                district_id,
                upazila_id,
                scheduled_date || new Date().toISOString().split('T')[0],
                scheduled_time_slot || '10:00 AM - 06:00 PM',
                customer_note,
                pickup_type || 'scheduled'
            ]
        );
        const pickupId = pickupResult.insertId;

        let totalEstMin = 0;

        // 6. Process Items
        for (let i = 0; i < parsedItems.length; i++) {
            const item = parsedItems[i];
            const itemId = item.item_id || item.scrap_item_id;

            const [priceData] = await conn.query(
                `SELECT si.current_min_rate, si.category_id, ov.min_rate as override_rate
                 FROM scrap_items si
                 LEFT JOIN item_price_overrides ov ON si.id = ov.item_id 
                    AND ov.is_active = 1
                    AND (ov.upazila_id = ? OR ov.district_id = ? OR ov.division_id = ?)
                 WHERE si.id = ?
                 ORDER BY ov.upazila_id DESC, ov.district_id DESC, ov.division_id DESC LIMIT 1`,
                [upazila_id, district_id, division_id, itemId]
            );

            const finalRate = priceData.length > 0 ? (priceData[0].override_rate || priceData[0].current_min_rate || 0) : 0;
            const weight = parseFloat(item.estimated_weight || item.weight) || 0;
            const itemSubtotal = finalRate * weight;
            totalEstMin += itemSubtotal;

            const itemPhotos = uploadedFiles
                .filter(file => file.fieldname === `item_photos_${i}` || file.fieldname === 'photos')
                .map(file => `/uploads/pickups/${file.filename}`);

            await conn.query(
                `INSERT INTO pickup_items (
                    pickup_id, category_id, item_id, 
                    estimated_weight, final_rate_per_unit, final_amount, 
                    photo_url, created_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, NOW())`,
                [pickupId, priceData[0]?.category_id || null, itemId, weight, finalRate, itemSubtotal, JSON.stringify(itemPhotos)]
            );
        }

        // 7. Update Base Amount & Timeline
        await conn.query("UPDATE pickups SET base_amount = ? WHERE id = ?", [totalEstMin, pickupId]);

        await conn.query(
            `INSERT INTO pickup_timeline (pickup_id, status, note, changed_by, created_at) 
             VALUES (?, 'pending', 'Shipment request created by customer', ?, NOW())`,
            [pickupId, userId]
        );

        await conn.commit();

        // 8. NOTIFICATION ENGINE (SMS & EMAIL)
        // Wrapped in try/catch to ensure DB transaction success even if notifications fail
        try {
            // A. Send SMS
            let formattedPhone = customerPhone.trim();
            if (formattedPhone.startsWith('0')) formattedPhone = '88' + formattedPhone;

            const smsMessage = `Hello ${customerName}, pickup request confirmed! Code: ${bookingCode}. Est. Value: ৳${totalEstMin.toFixed(0)}. - Smart Scrap BD`;

            await axios.post('https://api.sms.net.bd/sendsms', {
                api_key: process.env.SMS_API_KEY,
                msg: smsMessage,
                to: formattedPhone
            }, { headers: { 'Content-Type': 'multipart/form-data' } });

            // B. Send Email
            if (customerEmail && !customerEmail.includes('example.com')) {
                await sendPickupEmail(customerEmail, {
                    customerName,
                    customerPhone,
                    bookingCode,
                    totalEstMin: totalEstMin.toFixed(2),
                    scheduledDate: scheduled_date,
                    timeSlot: scheduled_time_slot
                });
            }
        } catch (notifyErr) {
            console.error("[NOTIFICATION ERROR] Failed to notify user:", notifyErr.message);
        }

        res.status(201).json({
            success: true,
            message: "Pickup created successfully!",
            data: {
                booking_code: bookingCode,
                pickup_id: pickupId,
                estimated_value: totalEstMin.toFixed(2)
            }
        });

    } catch (err) {
        if (conn) await conn.rollback();
        console.error("CRITICAL BOOKING ERROR:", err);
        next(err);
    } finally {
        if (conn) conn.release();
    }
};

export const listCustomerPickups = async (req, res) => {
    const [rows] = await db.query(
        `SELECT p.*, upz.name_en as upazila_name 
         FROM pickups p 
         JOIN customers c ON p.customer_id = c.id 
         LEFT JOIN upazilas upz ON p.upazila_id = upz.id
         WHERE c.user_id = ? ORDER BY p.created_at DESC`, [req.user.id]
    );
    res.json({ success: true, data: rows });
};

export const listAllPickupsAdmin = async (req, res, next) => {
    try {
        const { status, page = 1, limit = 10 } = req.query;
        const offset = (page - 1) * limit;

        let query = `
    SELECT 
        p.*, 
        u.full_name as customer_name, 
        u.phone as customer_phone,
        addr.address_line,
        divs.name_en as division_name,
        dist.name_en as district_name,
        upz.name_en as upazila_name,
        ag.business_name as agent_business_name,
        r_u.full_name as rider_name
    FROM pickups p 
    -- 1. Join to Customers table first to bridge to the User
    LEFT JOIN customers c ON p.customer_id = c.id
    -- 2. Join to Users table to get Name and Phone
    LEFT JOIN users u ON c.user_id = u.id
    
    -- 3. The rest of your joins
    LEFT JOIN addresses addr ON p.customer_address_id = addr.id
    LEFT JOIN divisions divs ON p.division_id = divs.id
    LEFT JOIN districts dist ON p.district_id = dist.id
    LEFT JOIN upazilas upz ON p.upazila_id = upz.id
    LEFT JOIN agents ag ON p.agent_id = ag.id
    LEFT JOIN riders r ON p.rider_id = r.id
    LEFT JOIN users r_u ON r.user_id = r_u.id
    
    WHERE p.is_deleted = 0
`;

        const params = [];
        if (status && status !== 'all') {
            query += " AND p.status = ?";
            params.push(status);
        }

        query += " ORDER BY p.created_at DESC LIMIT ? OFFSET ?";
        params.push(parseInt(limit), parseInt(offset));

        const [rows] = await db.query(query, params);

        res.json({
            success: true,
            data: rows
        });
    } catch (err) {
        next(err);
    }
};