import db from '../config/db.js';
import ApiError from '../utils/ApiError.js';

/**
 * 1. Get all addresses for the logged-in user
 */
export const getAddresses = async (req, res, next) => {
    try {
        const [rows] = await db.query(
            "SELECT * FROM addresses WHERE user_id = ? ORDER BY is_default DESC, created_at DESC",
            [req.user.id]
        );
        res.status(200).json({ success: true, data: rows });
    } catch (err) { 
        next(err); 
    }
};

/**
 * 2. Add Address (Universal for Customer, Rider, Agent)
 */
export const addAddress = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const { label, address_line, city, state, postal_code, latitude, longitude, is_default } = req.body;
        const userId = req.user.id;
        const role = req.user.role; // Injected by Auth Middleware

        await conn.beginTransaction();

        // If this is the new default, reset other addresses for this user
        if (is_default) {
            await conn.query("UPDATE addresses SET is_default = 0 WHERE user_id = ?", [userId]);
        }

        // Insert into the unified addresses table
        const [result] = await conn.query(
            `INSERT INTO addresses (user_id, label, address_line, city, state, postal_code, latitude, longitude, is_default) 
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [userId, label || 'Home', address_line, city, state, postal_code, latitude, longitude, is_default ? 1 : 0]
        );

        const newAddressId = result.insertId;

        // --- 🔄 Role-Based Sync ---
        // Now that the SQL constraint is fixed, this update will work perfectly
        if (is_default && role === 'customer') {
            await conn.query(
                "UPDATE customers SET default_address_id = ? WHERE user_id = ?", 
                [newAddressId, userId]
            );
        }

        // Add similar sync for Riders or Agents here if they have a 'default_address' field
        // if (is_default && role === 'rider') { ... }

        await conn.commit();
        res.status(201).json({ 
            success: true, 
            message: "Address saved and set as default", 
            id: newAddressId 
        });
    } catch (err) {
        await conn.rollback();
        console.error("Add Address Error:", err);
        next(new ApiError(500, "Failed to sync address with profile. Did you run the ALTER TABLE script?"));
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

        // Reset defaults
        await conn.query("UPDATE addresses SET is_default = 0 WHERE user_id = ?", [userId]);
        
        // Set new default
        const [updateRes] = await conn.query(
            "UPDATE addresses SET is_default = 1 WHERE id = ? AND user_id = ?", 
            [id, userId]
        );

        if (updateRes.affectedRows === 0) throw new ApiError(404, "Address not found");

        // Sync with Role-specific table
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
 * 4. Delete Address
 */
export const deleteAddress = async (req, res, next) => {
    try {
        const [result] = await db.query(
            "DELETE FROM addresses WHERE id = ? AND user_id = ?", 
            [req.params.id, req.user.id]
        );
        
        if (result.affectedRows === 0) throw new ApiError(404, "Address not found");
        
        res.json({ success: true, message: "Address removed successfully" });
    } catch (err) { 
        next(err); 
    }
};