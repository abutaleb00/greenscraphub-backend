// src/models/customerModel.js
import pool from '../config/db.js';

/* ----------------------------------------------------
    CREATE CUSTOMER
    Updated: Now generates a referral code and sets initial points
---------------------------------------------------- */
export async function createCustomer({ userId, referredBy = null }) {
    // Generate a professional referral code: GS + 5 random chars
    const referralCode = 'GS' + Math.random().toString(36).substring(2, 7).toUpperCase();

    const [result] = await pool.query(
        `INSERT INTO customers (user_id, referral_code, referred_by, total_points)
         VALUES (?, ?, ?, ?)`,
        [userId, referralCode, referredBy, 20] // Default 20 welcome points
    );

    return {
        id: result.insertId,
        user_id: userId,
        referral_code: referralCode,
        total_points: 20
    };
}

/* ----------------------------------------------------
    LIST CUSTOMERS (ADMIN VIEW)
    Updated: Includes points, referral counts, and wallet balance
---------------------------------------------------- */
export async function getCustomers() {
    const [rows] = await pool.query(
        `SELECT 
            c.id AS customer_id,
            u.id AS user_id,
            u.full_name,
            u.phone,
            u.email,
            c.referral_code,
            c.total_points,
            (SELECT COUNT(*) FROM customers WHERE referred_by = c.id) AS total_referrals,
            w.balance AS wallet_balance,
            u.is_active,
            c.created_at
         FROM customers c
         JOIN users u ON c.user_id = u.id
         LEFT JOIN wallet_accounts w ON u.id = w.user_id
         ORDER BY c.created_at DESC`
    );
    return rows;
}

/* ----------------------------------------------------
    GET CUSTOMER PROFILE BY USER ID
---------------------------------------------------- */
export async function getCustomerByUserId(userId) {
    const [rows] = await pool.query(
        `SELECT 
            c.*, 
            u.full_name, 
            u.phone, 
            u.email,
            w.balance AS wallet_balance,
            a.address_line AS default_address
         FROM customers c
         JOIN users u ON c.user_id = u.id
         LEFT JOIN wallet_accounts w ON u.id = w.user_id
         LEFT JOIN addresses a ON c.default_address_id = a.id
         WHERE c.user_id = ?`,
        [userId]
    );
    return rows[0] || null;
}

/* ----------------------------------------------------
    UPDATE CUSTOMER POINTS
---------------------------------------------------- */
export async function updateCustomerPoints(customerId, points, connection = null) {
    const conn = connection || pool;
    const [result] = await conn.query(
        `UPDATE customers SET total_points = total_points + ? WHERE id = ?`,
        [points, customerId]
    );
    return result.affectedRows > 0;
}

/* ----------------------------------------------------
    SET DEFAULT ADDRESS
---------------------------------------------------- */
export async function updateDefaultAddress(customerId, addressId) {
    const [result] = await pool.query(
        `UPDATE customers SET default_address_id = ? WHERE id = ?`,
        [addressId, customerId]
    );
    return result.affectedRows > 0;
}