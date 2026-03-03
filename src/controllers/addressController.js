// src/controllers/addressController.js
import db from '../config/db.js';
import ApiError from '../utils/ApiError.js';

/**
 * 1. Get all addresses for the logged-in user
 * Now includes joined names for Division, District, and Upazila
 */
export const getAddresses = async (req, res, next) => {
    try {
        const [rows] = await db.query(`
            SELECT a.*, 
                   div.name_en as division_name, 
                   dis.name_en as district_name, 
                   upz.name_en as upazila_name
            FROM addresses a
            LEFT JOIN divisions div ON a.division_id = div.id
            LEFT JOIN districts dis ON a.district_id = dis.id
            LEFT JOIN upazilas upz ON a.upazila_id = upz.id
            WHERE a.user_id = ? 
            ORDER BY a.is_default DESC, a.created_at DESC`,
            [req.user.id]
        );
        res.status(200).json({ success: true, data: rows });
    } catch (err) {
        next(err);
    }
};

/**
 * 2. Add Address (Integrated with Geo-IDs)
 */
export const addAddress = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const {
            label, address_line,
            division_id, district_id, upazila_id,
            latitude, longitude, is_default
        } = req.body;

        const userId = req.user.id;
        const role = req.user.role;

        await conn.beginTransaction();

        // 1. If setting as default, reset others
        if (is_default) {
            await conn.query("UPDATE addresses SET is_default = 0 WHERE user_id = ?", [userId]);
        }

        // 2. Insert with Geographical IDs for Hub Routing
        const [result] = await conn.query(
            `INSERT INTO addresses (
                user_id, label, address_line, 
                division_id, district_id, upazila_id, 
                latitude, longitude, is_default
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [
                userId, label || 'Home', address_line,
                division_id, district_id, upazila_id,
                latitude, longitude, is_default ? 1 : 0
            ]
        );

        const newAddressId = result.insertId;

        // 3. Sync with Profile (Role-Based)
        if (is_default && role === 'customer') {
            await conn.query(
                "UPDATE customers SET default_address_id = ? WHERE user_id = ?",
                [newAddressId, userId]
            );
        }

        await conn.commit();
        res.status(201).json({
            success: true,
            message: "Address saved successfully",
            address_id: newAddressId
        });
    } catch (err) {
        await conn.rollback();
        console.error("Add Address Error:", err);
        next(new ApiError(500, "Failed to save address. Check if Geographical IDs are valid."));
    } finally {
        conn.release();
    }
};

/**
 * 3. Set Default Address
 */
export const setDefaultAddress = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const { id } = req.params;
        const userId = req.user.id;
        const role = req.user.role;

        await conn.beginTransaction();

        // Reset all
        await conn.query("UPDATE addresses SET is_default = 0 WHERE user_id = ?", [userId]);

        // Set new primary
        const [updateRes] = await conn.query(
            "UPDATE addresses SET is_default = 1 WHERE id = ? AND user_id = ?",
            [id, userId]
        );

        if (updateRes.affectedRows === 0) throw new ApiError(404, "Address not found");

        // Sync with Role Table
        if (role === 'customer') {
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
 * 4. Delete Address (With Protection)
 */
export const deleteAddress = async (req, res, next) => {
    try {
        // Check if address is being used as a default in Customer profile
        const [customer] = await db.query("SELECT id FROM customers WHERE default_address_id = ?", [req.params.id]);
        if (customer.length > 0) {
            throw new ApiError(400, "Cannot delete primary address. Set another address as default first.");
        }

        const [result] = await db.query(
            "DELETE FROM addresses WHERE id = ? AND user_id = ?",
            [req.params.id, req.user.id]
        );

        if (result.affectedRows === 0) throw new ApiError(404, "Address not found");

        res.json({ success: true, message: "Address removed" });
    } catch (err) {
        next(err);
    }
};