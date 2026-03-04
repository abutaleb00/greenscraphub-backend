import db from "../../config/db.js";
import ApiError from "../../utils/ApiError.js";

/**
 * CREATE PICKUP REQUEST (FULL PRODUCTION VERSION)
 * Handles: Geo-validation, Hierarchical Pricing, and Multi-item Image Mapping.
 */
export const createPickup = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        await conn.beginTransaction();

        // 1. User Context & Request Body
        const userId = req.user.id;
        const {
            address_id,
            items, // JSON string or Array
            scheduled_date,
            scheduled_time_slot,
            customer_note,
            pickup_type
        } = req.body;

        // 2. Fetch Geo-Data from Address Table (Critical for FK constraints)
        const [addressRows] = await conn.query(
            "SELECT division_id, district_id, upazila_id FROM addresses WHERE id = ? AND user_id = ?",
            [address_id, userId]
        );

        if (!addressRows.length) {
            throw new ApiError(400, "Invalid address selected or unauthorized.");
        }

        const { division_id, district_id, upazila_id } = addressRows[0];

        // 3. Verify Customer Profile
        const [customer] = await conn.query(
            "SELECT id FROM customers WHERE user_id = ?",
            [userId]
        );
        if (!customer.length) throw new ApiError(404, "Customer profile not found.");
        const customerId = customer[0].id;

        // 4. Parse Items & Handle Image Binary Mapping
        // Note: Multer puts files in req.files (if using .any() or .array())
        const parsedItems = typeof items === 'string' ? JSON.parse(items) : items;
        const uploadedFiles = req.files || [];

        if (!parsedItems || parsedItems.length === 0) {
            throw new ApiError(400, "At least one scrap item is required.");
        }

        // 5. Generate Booking Code
        const bookingCode = `GS-${upazila_id || '0'}-${Date.now().toString().slice(-4)}`;

        // 6. Insert Master Pickup Record
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
                scheduled_date, scheduled_time_slot,
                customer_note, pickup_type || 'scheduled'
            ]
        );
        const pickupId = pickupResult.insertId;

        let totalEstMin = 0;

        // 7. Process Items, Pricing Hierarchy, and Image Paths
        for (let i = 0; i < parsedItems.length; i++) {
            const item = parsedItems[i];

            // Hierarchy Pricing Query
            const [priceData] = await conn.query(
                `SELECT 
                    si.current_min_rate as global_rate, 
                    si.category_id,
                    ov.min_rate as override_rate
                 FROM scrap_items si
                 LEFT JOIN item_price_overrides ov ON si.id = ov.item_id 
                    AND ov.is_active = 1
                    AND (
                        ov.upazila_id = ? OR 
                        ov.district_id = ? OR 
                        ov.division_id = ? OR 
                        (ov.upazila_id IS NULL AND ov.district_id IS NULL AND ov.division_id IS NULL)
                    )
                 WHERE si.id = ?
                 ORDER BY ov.upazila_id DESC, ov.district_id DESC, ov.division_id DESC LIMIT 1`,
                [upazila_id, district_id, division_id, item.item_id || item.scrap_item_id]
            );

            if (!priceData.length) continue;

            const finalRate = priceData[0].override_rate || priceData[0].global_rate || 0;
            const weight = parseFloat(item.estimated_weight) || 0;
            const itemSubtotal = finalRate * weight;
            totalEstMin += itemSubtotal;

            /**
             * IMAGE MAPPING LOGIC:
             * We associate the uploaded photos with the specific items.
             * If you are using the 'item_photos[index]' pattern from the frontend:
             */
            const itemPhotos = uploadedFiles
                .filter(file => file.fieldname === `item_photos[${i}]` || file.fieldname === 'photos')
                .map(file => `/uploads/pickups/${file.filename}`);

            // 8. Insert Line Item with Photo Paths (JSON string)
            await conn.query(
                `INSERT INTO pickup_items (
                    pickup_id, category_id, item_id, 
                    estimated_weight, final_rate_per_unit, final_amount, 
                    photo_url, created_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, NOW())`,
                [
                    pickupId,
                    priceData[0].category_id,
                    item.item_id || item.scrap_item_id,
                    weight,
                    finalRate,
                    itemSubtotal,
                    JSON.stringify(itemPhotos) // Saving as JSON array string
                ]
            );
        }

        // 9. Initialize Timeline
        await conn.query(
            `INSERT INTO pickup_timeline (pickup_id, status, note, created_at) 
             VALUES (?, 'pending', 'Shipment request created by customer', NOW())`,
            [pickupId]
        );

        // 10. Update Total Amount on Master Record
        await conn.query(
            "UPDATE pickups SET base_amount = ? WHERE id = ?",
            [totalEstMin, pickupId]
        );

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
        await conn.rollback();
        console.error("CRITICAL BOOKING ERROR:", err);

        if (err.code === 'ER_NO_REFERENCED_ROW_2') {
            return next(new ApiError(400, "Geographical mismatch. Please re-select your address."));
        }
        next(err);
    } finally {
        conn.release();
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
            SELECT p.*, u.full_name as customer_name, upz.name_en as upazila_name
            FROM pickups p 
            JOIN customers c ON p.customer_id = c.id 
            JOIN users u ON c.user_id = u.id
            LEFT JOIN upazilas upz ON p.upazila_id = upz.id
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
        res.json({ success: true, data: rows });
    } catch (err) {
        next(err);
    }
};