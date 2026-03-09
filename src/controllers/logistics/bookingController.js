import { ApiError } from "../../utils/ApiError.js";
import db from "../../config/db.js";

export const createPickup = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        await conn.beginTransaction();

        // 1. User Context & Request Body
        const userId = req.user.id;
        const {
            address_id,
            pickup_address, // Address string from mobile
            latitude,
            longitude,
            items,
            scheduled_date,
            scheduled_time_slot,
            customer_note,
            pickup_type
        } = req.body;

        // 2. Fetch Geo-Data & Resolve Address
        let div_id, dist_id, upz_id, final_address_text;

        if (address_id && address_id !== 'live') {
            // Case A: Saved Address
            const [addressRows] = await conn.query(
                "SELECT division_id, district_id, upazila_id, address_line FROM addresses WHERE id = ? AND user_id = ?",
                [address_id, userId]
            );

            if (!addressRows.length) {
                throw new ApiError(400, "Invalid address selected or unauthorized.");
            }
            div_id = addressRows[0].division_id;
            dist_id = addressRows[0].district_id;
            upz_id = addressRows[0].upazila_id;
            final_address_text = addressRows[0].address_line;
        } else {
            // Case B: Live Location
            if (!pickup_address) {
                throw new ApiError(400, "Pickup address text is required.");
            }
            div_id = req.body.division_id || null;
            dist_id = req.body.district_id || null;
            upz_id = req.body.upazila_id || null;
            final_address_text = pickup_address;
        }

        // 3. Verify Customer Profile
        const [customer] = await conn.query(
            "SELECT id FROM customers WHERE user_id = ?",
            [userId]
        );
        if (!customer.length) throw new ApiError(404, "Customer profile not found.");
        const customerId = customer[0].id;

        // 4. Parse Items
        const parsedItems = typeof items === 'string' ? JSON.parse(items) : items;
        const uploadedFiles = req.files || [];

        if (!parsedItems || parsedItems.length === 0) {
            throw new ApiError(400, "At least one scrap item is required.");
        }

        // 5. Generate Booking Code
        const bookingCode = `GS-${upz_id || '0'}-${Date.now().toString().slice(-4)}`;

        // 6. Insert Master Pickup Record
        // 🔥 FIX: Changed 'pickup_address' to 'address_line' (Matches your address table naming)
        // Verify your DB column name: if it is 'address', change 'address_line' to 'address' below.
        const [pickupResult] = await conn.query(
            `INSERT INTO pickups (
                booking_code, customer_id, customer_address_id, 
                address_line, latitude, longitude,
                division_id, district_id, upazila_id,
                status, scheduled_date, scheduled_time_slot, 
                customer_note, pickup_type, created_at, updated_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending', ?, ?, ?, ?, NOW(), NOW())`,
            [
                bookingCode,
                customerId,
                (address_id === 'live' ? null : address_id),
                final_address_text,
                latitude || null,
                longitude || null,
                div_id,
                dist_id,
                upz_id,
                scheduled_date || new Date().toISOString().split('T')[0],
                scheduled_time_slot || '10:00 AM - 06:00 PM',
                customer_note,
                pickup_type || 'scheduled'
            ]
        );
        const pickupId = pickupResult.insertId;

        let totalEstMin = 0;

        // 7. Process Items & Pricing
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
                [upz_id, dist_id, div_id, itemId]
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

        // 8. Initialize Timeline (🔥 FIXED: Added changed_by)
        await conn.query(
            `INSERT INTO pickup_timeline (pickup_id, status, note, changed_by, created_at) 
             VALUES (?, 'pending', 'Shipment request created by customer', ?, NOW())`,
            [pickupId, userId]
        );

        // 9. Finalize Master Amount
        await conn.query("UPDATE pickups SET base_amount = ? WHERE id = ?", [totalEstMin, pickupId]);

        await conn.commit();

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