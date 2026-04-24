// src/controllers/addressController.js
import db from '../config/db.js';
import ApiError from '../utils/ApiError.js';

/**
 * 1. REVERSE GEO-LOOKUP (Uber Style)
 * Converts Lat/Lng into Database IDs for Division, District, and Upazila
 */
export const lookupGeoByCoords = async (req, res, next) => {
    try {
        const { latitude, longitude } = req.body;

        if (!latitude || !longitude) {
            return res.status(400).json({ success: false, message: "Coordinates required" });
        }

        /**
         * PROFESSIONAL PRECISION QUERY:
         * We now calculate distance directly to the Upazila's center point.
         */
        const [rows] = await db.query(`
            SELECT 
                u.id as upazila_id, u.name_en as upazila_name,
                d.id as district_id, d.name_en as district_name,
                v.id as division_id, v.name_en as division_name,
                /* Calculate distance to the specific Upazila coordinates */
                (ST_Distance_Sphere(point(?, ?), point(u.longitude, u.latitude))) AS distance
            FROM upazilas u
            JOIN districts d ON u.district_id = d.id
            JOIN divisions v ON d.division_id = v.id
            WHERE u.latitude IS NOT NULL
            ORDER BY distance ASC
            LIMIT 1
        `, [longitude, latitude]);

        // If the nearest upazila is more than 30km away, it's likely a dead zone
        if (!rows.length || rows[0].distance > 30000) {
            return res.json({
                success: false,
                message: "Outside service area. Please move the pin closer to a town."
            });
        }

        res.status(200).json({
            success: true,
            data: rows[0]
        });
    } catch (err) {
        console.error("Geo Lookup SQL Error:", err);
        res.status(500).json({ success: false, message: "Internal server error" });
    }
};

/**
 * 2. Get all addresses for the logged-in user
 */
export const getAddresses = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const [rows] = await db.query(`
            SELECT a.*, 
                   dvs.name_en as division_name, 
                   dis.name_en as district_name, 
                   upz.name_en as upazila_name
            FROM addresses a
            LEFT JOIN divisions dvs ON a.division_id = dvs.id
            LEFT JOIN districts dis ON a.district_id = dis.id
            LEFT JOIN upazilas upz ON a.upazila_id = upz.id
            WHERE a.user_id = ? 
            ORDER BY a.is_default DESC, a.created_at DESC`,
            [userId]
        );
        res.status(200).json({ success: true, data: rows });
    } catch (err) {
        next(err);
    }
};

/**
 * 3. Add Address (Integrated with Geo-IDs)
 */
export const addAddress = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const {
            label, address_line, landmark, house_no, road_no,
            division_id, district_id, upazila_id,
            latitude, longitude, is_default
        } = req.body;

        const userId = req.user.id;
        await conn.beginTransaction();

        if (is_default) {
            await conn.query("UPDATE addresses SET is_default = 0 WHERE user_id = ?", [userId]);
        }

        const [result] = await conn.query(
            `INSERT INTO addresses (
                user_id, label, address_line, landmark, house_no, road_no,
                division_id, district_id, upazila_id, 
                latitude, longitude, is_default, created_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())`,
            [
                userId, label || 'Home', address_line, landmark || null, house_no || null, road_no || null,
                division_id || null, district_id || null, upazila_id || null,
                latitude || null, longitude || null, is_default ? 1 : 0
            ]
        );

        if (is_default && req.user.role === 'customer') {
            await conn.query("UPDATE customers SET default_address_id = ? WHERE user_id = ?", [result.insertId, userId]);
        }

        await conn.commit();
        res.status(201).json({ success: true, message: "Address saved", data: { id: result.insertId } });
    } catch (err) {
        await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};

/**
 * 4. Update Address
 */
export const updateAddress = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const { id } = req.params;
        const { label, address_line, division_id, district_id, upazila_id, is_default, latitude, longitude } = req.body;
        const userId = req.user.id;

        await conn.beginTransaction();

        if (is_default) {
            await conn.query("UPDATE addresses SET is_default = 0 WHERE user_id = ?", [userId]);
        }

        const [result] = await conn.query(
            `UPDATE addresses SET 
                label = ?, address_line = ?, 
                division_id = ?, district_id = ?, upazila_id = ?, 
                latitude = ?, longitude = ?,
                is_default = ? 
            WHERE id = ? AND user_id = ?`,
            [label, address_line, division_id, district_id, upazila_id, latitude, longitude, is_default ? 1 : 0, id, userId]
        );

        if (result.affectedRows === 0) throw new ApiError(404, "Address not found");

        if (is_default && req.user.role === 'customer') {
            await conn.query("UPDATE customers SET default_address_id = ? WHERE user_id = ?", [id, userId]);
        }

        await conn.commit();
        res.json({ success: true, message: "Address updated successfully" });
    } catch (err) {
        await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};

/**
 * 5. Set Default Address
 */
export const setDefaultAddress = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const { id } = req.params;
        const userId = req.user.id;

        await conn.beginTransaction();

        await conn.query("UPDATE addresses SET is_default = 0 WHERE user_id = ?", [userId]);

        const [updateRes] = await conn.query(
            "UPDATE addresses SET is_default = 1 WHERE id = ? AND user_id = ?",
            [id, userId]
        );

        if (updateRes.affectedRows === 0) throw new ApiError(404, "Address not found");

        if (req.user.role === 'customer') {
            await conn.query("UPDATE customers SET default_address_id = ? WHERE user_id = ?", [id, userId]);
        }

        await conn.commit();
        res.json({ success: true, message: "Primary address updated" });
    } catch (err) {
        await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};

/**
 * 6. Delete Address
 */
export const deleteAddress = async (req, res, next) => {
    try {
        const addressId = req.params.id;
        const userId = req.user.id;

        // 1. Check if this is the default address
        const [customer] = await db.query(
            "SELECT id FROM customers WHERE default_address_id = ? AND user_id = ?",
            [addressId, userId]
        );

        if (customer.length > 0) {
            throw new ApiError(400, "Cannot delete primary address. Please set another default first.");
        }

        // 2. OPTIONAL: Prevent deleting the last remaining address
        const [allAddresses] = await db.query(
            "SELECT COUNT(*) as total FROM addresses WHERE user_id = ?",
            [userId]
        );

        if (allAddresses[0].total <= 1) {
            throw new ApiError(400, "You must have at least one address saved.");
        }

        // 3. Delete the address
        const [result] = await db.query(
            "DELETE FROM addresses WHERE id = ? AND user_id = ?",
            [addressId, userId]
        );

        if (result.affectedRows === 0) throw new ApiError(404, "Address not found");

        res.json({ success: true, message: "Address removed successfully" });
    } catch (err) {
        next(err);
    }
};

/**
 * 7. Admin: Get user addresses
 */
export const getAddressesByUserId = async (req, res, next) => {
    try {
        const targetUserId = req.params.userId;
        const [rows] = await db.query(`
            SELECT a.*, dvs.name_en as division_name, dis.name_en as district_name, upz.name_en as upazila_name
            FROM addresses a
            LEFT JOIN divisions dvs ON a.division_id = dvs.id
            LEFT JOIN districts dis ON a.district_id = dis.id
            LEFT JOIN upazilas upz ON a.upazila_id = upz.id
            WHERE a.user_id = ? 
            ORDER BY a.is_default DESC, a.created_at DESC`,
            [targetUserId]
        );

        res.status(200).json({ success: true, count: rows.length, data: rows });
    } catch (err) {
        next(err);
    }
};