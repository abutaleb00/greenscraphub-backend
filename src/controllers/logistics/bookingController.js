// 1. Fix the Import
import axios from "axios";
import nodemailer from 'nodemailer';
import ApiError from "../../utils/ApiError.js";
import db from "../../config/db.js";
import { sendPushNotification } from "../../utils/notificationHelper.js";
import useragent from 'useragent';
import requestIp from 'request-ip';

/* -----------------------------------------------------
    HELPER: LOG ACTIVITY (Device & Platform Tracking)
----------------------------------------------------- */
const logActivity = async (req, userId, action, metadata = {}) => {
    try {
        const agent = useragent.parse(req.headers['user-agent']);
        const ip = requestIp.getClientIp(req);

        // Platform detection (Mobile App should send x-platform header)
        const platform = req.headers['x-platform'] || (req.headers['user-agent'].includes('Postman') ? 'API' : 'WEB');

        const query = `
            INSERT INTO activity_logs 
            (user_id, action, platform, browser, os, device, ip_address, metadata, created_at) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())
        `;

        const values = [
            userId,
            action,
            platform,
            agent.toAgent(),
            agent.os.toString(),
            agent.device.toString(),
            ip,
            JSON.stringify(metadata)
        ];

        await db.query(query, values);
    } catch (error) {
        console.error("[Activity Log Error]", error.message);
    }
};

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

        // 2. Fetch Customer Info
        const [customerRows] = await conn.query(
            `SELECT c.id, u.phone, u.full_name, u.email, u.fcm_token 
             FROM customers c 
             JOIN users u ON c.user_id = u.id 
             WHERE u.id = ?`,
            [userId]
        );
        if (!customerRows.length) throw new ApiError(404, "Customer profile not found.");

        const {
            id: customerId,
            phone: customerPhone,
            full_name: customerName,
            email: customerEmail,
            fcm_token: customerFcmToken
        } = customerRows[0];

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
                bookingCode, customerId, address_id,
                division_id, district_id, upazila_id,
                scheduled_date || new Date().toISOString().split('T')[0],
                scheduled_time_slot || '10:00 AM - 06:00 PM',
                customer_note, pickup_type || 'scheduled'
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

        // 🔥 8. LOG ACTIVITY: CREATE PICKUP
        await logActivity(req, userId, 'CREATE_PICKUP', {
            booking_code: bookingCode,
            pickup_id: pickupId,
            estimated_value: totalEstMin.toFixed(2)
        });

        // 9. NOTIFICATION ENGINE (SMS, EMAIL & FIREBASE PUSH)
        try {
            // A. Send Firebase Push Notification
            if (customerFcmToken) {
                await sendPushNotification(
                    customerFcmToken,
                    "Pickup Requested! 📝",
                    `Your request ${bookingCode} has been received and is pending.`,
                    {
                        orderId: pickupId.toString(),
                        type: "order_update"
                    }
                );
            }

            // B. Send SMS
            let formattedPhone = customerPhone.trim();
            if (formattedPhone.startsWith('0')) formattedPhone = '88' + formattedPhone;
            const smsMessage = `Your pickup request confirmed! Order Code: ${bookingCode}. - Smart Scrap BD`;
            await axios.post('https://api.sms.net.bd/sendsms', {
                api_key: process.env.SMS_API_KEY,
                msg: smsMessage,
                to: formattedPhone
            }, { headers: { 'Content-Type': 'multipart/form-data' } });

            // C. Send Email
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
    try {
        const [rows] = await db.query(
            `SELECT p.*, upz.name_en as upazila_name 
             FROM pickups p 
             JOIN customers c ON p.customer_id = c.id 
             LEFT JOIN upazilas upz ON p.upazila_id = upz.id
             WHERE c.user_id = ? 
             AND p.is_archived = 0 
             AND p.is_deleted = 0 
             ORDER BY p.created_at DESC`,
            [req.user.id]
        );

        res.json({
            success: true,
            data: rows
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: "Failed to fetch pickups"
        });
    }
};

export const listAllPickupsAdmin = async (req, res, next) => {
    try {
        // Added showArchived to the destructuring
        const { status, page = 1, limit = 10, showArchived = 'false' } = req.query;
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
            LEFT JOIN customers c ON p.customer_id = c.id
            LEFT JOIN users u ON c.user_id = u.id
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

        // --- FILTER: ARCHIVED STATUS ---
        // By default, only show non-archived items (is_archived = 0)
        if (showArchived === 'true') {
            query += " AND p.is_archived = 1";
        } else {
            query += " AND p.is_archived = 0";
        }

        // --- FILTER: ORDER STATUS ---
        if (status && status !== 'all') {
            query += " AND p.status = ?";
            params.push(status);
        }

        query += " ORDER BY p.created_at DESC LIMIT ? OFFSET ?";
        params.push(parseInt(limit), parseInt(offset));

        const [rows] = await db.query(query, params);

        // Get total count for pagination (optional but recommended for a "Start Fresh" UI)
        const [totalRows] = await db.query(
            `SELECT COUNT(*) as count FROM pickups WHERE is_deleted = 0 AND is_archived = ${showArchived === 'true' ? 1 : 0}`,
            []
        );

        res.json({
            success: true,
            data: rows,
            meta: {
                total: totalRows[0].count,
                page: parseInt(page),
                limit: parseInt(limit)
            }
        });
    } catch (err) {
        next(err);
    }
};

// 1. ARCHIVE (Updates is_archived to 1)
export const archivePickup = async (req, res) => {
    const { id } = req.params;
    try {
        const [result] = await db.query('UPDATE pickups SET is_archived = 1 WHERE id = ?', [id]);

        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, message: "Pickup not found" });
        }

        await logActivity(req, req.user.id, 'ADMIN_ARCHIVE', `Archived Pickup ID: ${id}`);
        res.json({ success: true, message: "Moved to system archive." });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};

// 2. HARD DELETE (Permanently removes from DB)
export const deletePickupAdmin = async (req, res) => {
    const { id } = req.params;

    // We use a transaction to ensure data integrity
    const connection = await db.getConnection();

    try {
        await connection.beginTransaction();

        // 1. Delete all "Children" first (pickup_items)
        // This clears the foreign key constraint block
        await connection.query('DELETE FROM pickup_items WHERE pickup_id = ?', [id]);

        // 2. (Optional) Delete associated photos from storage if necessary
        // You would fetch photo_urls before step 1 and trigger FS/S3 delete here

        // 3. Delete the "Parent" (pickups)
        const [result] = await connection.query('DELETE FROM pickups WHERE id = ?', [id]);

        if (result.affectedRows === 0) {
            await connection.rollback();
            return res.status(404).json({
                success: false,
                message: "Pickup record not found."
            });
        }

        // 4. Record this action in the System Activity Logs
        await logActivity(req, req.user.id, 'ADMIN_HARD_DELETE', `Deleted Pickup ID: ${id} and all related pickup_items`);

        // If everything is successful, commit changes
        await connection.commit();

        return res.status(200).json({
            success: true,
            message: "Pickup and all related items have been permanently removed."
        });

    } catch (err) {
        // If anything fails, undo all changes made during this function
        await connection.rollback();
        console.error("Critical Delete Error:", err);
        return res.status(500).json({
            success: false,
            message: "Failed to delete record. " + err.message
        });
    } finally {
        // Always release the connection back to the pool
        connection.release();
    }
};

// 3. BULK CLEANUP (Archives all currently active orders)
export const bulkDeletePickups = async (req, res) => {
    try {
        await db.query('UPDATE pickups SET is_archived = 1 WHERE is_archived = 0');
        await logActivity(req, req.user.id, 'ADMIN_BULK_CLEANUP', `Performed system-wide archive cleanup`);

        res.json({ success: true, message: "All active pickups have been archived." });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};