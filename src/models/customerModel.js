// src/models/customerModel.js
import pool from '../config/db.js';

export async function createCustomer({ userId }) {
    const [result] = await pool.query(
        `INSERT INTO customers (user_id)
     VALUES (?)`,
        [userId]
    );

    return {
        id: result.insertId,
        user_id: userId,
    };
}

export async function getCustomers() {
    const [rows] = await pool.query(
        `SELECT 
        c.id AS customer_id,
        u.id AS user_id,
        u.full_name,
        u.phone,
        u.email,
        u.is_active,
        c.created_at
     FROM customers c
     JOIN users u ON c.user_id = u.id
     ORDER BY c.created_at DESC`
    );
    return rows;
}
