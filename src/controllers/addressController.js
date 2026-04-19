// src/controllers/addressController.js
import db from '../config/db.js';
import ApiError from '../utils/ApiError.js';

/**
 * 1. Get all addresses for the logged-in user
 * Renamed 'div' alias to 'dvs' to avoid MariaDB/MySQL reserved keyword conflict.
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

        // 1. If setting as default, reset others for this user
        if (is_default) {
            await conn.query("UPDATE addresses SET is_default = 0 WHERE user_id = ?", [userId]);
        }

        // 2. Insert with Geographical IDs for Hub Routing
        const [result] = await conn.query(
            `INSERT INTO addresses (
                user_id, label, address_line, 
                division_id, district_id, upazila_id, 
                latitude, longitude, is_default, created_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())`,
            [
                userId, label || 'Home', address_line,
                division_id || null, district_id || null, upazila_id || null,
                latitude || null, longitude || null, is_default ? 1 : 0
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
            data: { id: newAddressId }
        });
    } catch (err) {
        await conn.rollback();
        console.error("Add Address Error:", err);
        next(new ApiError(500, "Failed to save address. Ensure location IDs are valid."));
    } finally {
        conn.release();
    }
};

/**
 * 3. Update Address
 */
export const updateAddress = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const { id } = req.params;
        const { label, address_line, division_id, district_id, upazila_id, is_default } = req.body;
        const userId = req.user.id;

        await conn.beginTransaction();

        if (is_default) {
            await conn.query("UPDATE addresses SET is_default = 0 WHERE user_id = ?", [userId]);
        }

        const [result] = await conn.query(
            `UPDATE addresses SET 
                label = ?, address_line = ?, 
                division_id = ?, district_id = ?, upazila_id = ?, 
                is_default = ? 
            WHERE id = ? AND user_id = ?`,
            [label, address_line, division_id, district_id, upazila_id, is_default ? 1 : 0, id, userId]
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
 * 4. Set Default Address
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
 * 5. Delete Address (With Default Protection)
 */
export const deleteAddress = async (req, res, next) => {
    try {
        const addressId = req.params.id;
        const userId = req.user.id;

        // Prevent deletion of the default address assigned in the customer profile
        const [customer] = await db.query(
            "SELECT id FROM customers WHERE default_address_id = ? AND user_id = ?",
            [addressId, userId]
        );

        if (customer.length > 0) {
            throw new ApiError(400, "Cannot delete your primary address. Set another address as default first.");
        }

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
 * 6. Get all addresses for a SPECIFIC user (Admin/Staff use)
 */
export const getAddressesByUserId = async (req, res, next) => {
    try {
        const targetUserId = req.params.userId;

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
            [targetUserId]
        );

        res.status(200).json({
            success: true,
            count: rows.length,
            data: rows
        });
    } catch (err) {
        next(err);
    }
};