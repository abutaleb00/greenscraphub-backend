import db from '../config/db.js';

/* -----------------------------------------------------
    UPSERT REGIONAL OVERRIDE (With History Logging)
----------------------------------------------------- */
export const upsertPriceOverride = async (req, res, next) => {
    const conn = await db.getConnection(); // Use transaction for data integrity
    try {
        const {
            item_id, division_id, district_id, upazila_id,
            min_rate, max_rate, is_active, change_reason
        } = req.body;

        const adminId = req.user?.id || 1; // Fallback to 1 if auth middleware isn't set yet

        await conn.beginTransaction();

        // 1. Check for existing override
        const [existing] = await conn.query(
            `SELECT id, min_rate, max_rate FROM item_price_overrides 
             WHERE item_id = ? AND division_id <=> ? AND district_id <=> ? AND upazila_id <=> ?`,
            [item_id, division_id || null, district_id || null, upazila_id || null]
        );

        let old_min = null;
        let old_max = null;

        if (existing.length > 0) {
            old_min = existing[0].min_rate;
            old_max = existing[0].max_rate;

            // 2. Update existing
            await conn.query(
                `UPDATE item_price_overrides 
                 SET min_rate = ?, max_rate = ?, is_active = ? 
                 WHERE id = ?`,
                [min_rate, max_rate, is_active ?? 1, existing[0].id]
            );
        } else {
            // 3. Insert new
            await conn.query(
                `INSERT INTO item_price_overrides 
                 (item_id, division_id, district_id, upazila_id, min_rate, max_rate) 
                 VALUES (?, ?, ?, ?, ?, ?)`,
                [item_id, division_id || null, district_id || null, upazila_id || null, min_rate, max_rate]
            );
        }

        // 4. Log to History Table for the Chart
        // We log changes if the price actually moved or if it's a new entry
        if (old_min !== min_rate || old_max !== max_rate) {
            await conn.query(
                `INSERT INTO scrap_price_history 
                 (scrap_item_id, old_min_price, old_max_price, new_min_price, new_max_price, changed_by_user_id, change_reason) 
                 VALUES (?, ?, ?, ?, ?, ?, ?)`,
                [item_id, old_min || 0, old_max || 0, min_rate, max_rate, adminId, change_reason || 'Regional Price Adjustment']
            );
        }

        await conn.commit();
        res.status(existing.length > 0 ? 200 : 201).json({
            success: true,
            message: existing.length > 0 ? "Regional rate updated." : "New regional price node deployed."
        });

    } catch (err) {
        await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};

/* -----------------------------------------------------
    FETCH PRICE HISTORY (For Trend Chart)
----------------------------------------------------- */
export const getPriceHistory = async (req, res, next) => {
    try {
        const { item_id } = req.params;

        const query = `
            SELECT 
                id,
                new_min_price as min, 
                new_max_price as max, 
                changed_at as date,
                change_reason as reason
            FROM scrap_price_history 
            WHERE scrap_item_id = ? 
            ORDER BY changed_at ASC 
            LIMIT 50
        `;

        const [rows] = await db.query(query, [item_id]);

        res.json({
            success: true,
            data: rows
        });
    } catch (err) {
        next(err);
    }
};

/* -----------------------------------------------------
    FETCH OVERRIDES FOR AN ITEM
----------------------------------------------------- */
export const getItemOverrides = async (req, res, next) => {
    try {
        const { item_id } = req.params;

        if (!item_id || item_id === 'undefined') {
            return res.status(400).json({ success: false, message: "Item ID is required" });
        }

        const query = `
            SELECT 
                o.*, 
                divs.name_en as div_name, 
                dist.name_en as dist_name, 
                upz.name_en as upz_name
            FROM item_price_overrides o
            LEFT JOIN divisions divs ON o.division_id = divs.id
            LEFT JOIN districts dist ON o.district_id = dist.id
            LEFT JOIN upazilas upz ON o.upazila_id = upz.id
            WHERE o.item_id = ?
            ORDER BY o.created_at DESC
        `;

        const [rows] = await db.query(query, [item_id]);

        res.json({ success: true, data: rows });
    } catch (err) {
        next(err);
    }
};

/* -----------------------------------------------------
    FETCH MASTER PRICE INDEX (Admin Dashboard)
----------------------------------------------------- */
export const getAdminPriceIndex = async (req, res, next) => {
    try {
        const query = `
            SELECT 
                si.id, 
                si.name_en, 
                si.unit, 
                si.image_url,
                si.current_min_rate, 
                si.current_max_rate, 
                si.is_active,
                c.name_en as category_name,
                (SELECT COUNT(*) FROM item_price_overrides WHERE item_id = si.id) as override_count
            FROM scrap_items si
            JOIN scrap_categories c ON si.category_id = c.id
            WHERE si.is_active = 1
            ORDER BY c.display_order ASC, si.name_en ASC
        `;

        const [rows] = await db.query(query);
        res.json({ success: true, data: rows });
    } catch (err) {
        next(err);
    }
};