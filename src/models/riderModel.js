// src/models/riderModel.js
import pool from "../config/db.js";

/* ----------------------------------------------------
    CREATE RIDER
    Updated: Sets initial availability and zero stats
---------------------------------------------------- */
export async function createRider({ userId, agentId, vehicleType, vehicleNumber }) {
    const [result] = await pool.query(
        `
        INSERT INTO riders (
            user_id,
            agent_id,
            vehicle_type,
            vehicle_number,
            is_online,
            is_available,
            rating_avg,
            total_completed
        )
        VALUES (?, ?, ?, ?, 0, 1, 5.00, 0)
        `,
        [userId, agentId, vehicleType, vehicleNumber]
    );

    return { id: result.insertId };
}

/* ----------------------------------------------------
    GET RIDERS BY AGENT
    Updated: Includes wallet balance for the Agent to see staff earnings
---------------------------------------------------- */
export async function getRidersByAgent(agentId) {
    const [rows] = await pool.query(
        `
        SELECT 
            r.id AS rider_id,
            u.id AS user_id,
            u.full_name,
            u.phone,
            u.email,
            u.is_active,
            r.vehicle_type,
            r.vehicle_number,
            r.rating_avg,
            r.total_completed,
            r.is_online,
            r.is_available,
            w.balance AS wallet_balance,
            r.created_at
        FROM riders r
        JOIN users u ON r.user_id = u.id
        LEFT JOIN wallet_accounts w ON u.id = w.user_id
        WHERE r.agent_id = ?
        ORDER BY r.is_online DESC, r.created_at DESC
        `,
        [agentId]
    );

    return rows;
}

/* ----------------------------------------------------
    GET ALL RIDERS (ADMIN)
    Updated: Comprehensive overview with Agency and Wallet info
---------------------------------------------------- */
export async function getAllRidersWithAgent() {
    const [rows] = await pool.query(
        `
        SELECT 
            r.id AS rider_id,
            u.id AS user_id,
            u.full_name,
            u.phone,
            u.is_active,
            r.vehicle_type,
            r.is_online,
            r.rating_avg,
            r.total_completed,
            w.balance AS wallet_balance,
            a.id AS agent_id,
            a.name AS agent_company_name,
            au.full_name AS agent_owner_name
        FROM riders r
        JOIN users u ON r.user_id = u.id
        JOIN agents a ON r.agent_id = a.id
        JOIN users au ON a.owner_user_id = au.id
        LEFT JOIN wallet_accounts w ON u.id = w.user_id
        ORDER BY r.created_at DESC
        `
    );

    return rows;
}

/* ----------------------------------------------------
    LOGISTICS: UPDATE STATUS & LOCATION
    Called by the Rider App to stay trackable
---------------------------------------------------- */
export async function updateRiderLocation(userId, lat, lng) {
    const [result] = await pool.query(
        `UPDATE riders SET 
            current_latitude = ?, 
            current_longitude = ?, 
            last_location_update = NOW() 
         WHERE user_id = ?`,
        [lat, lng, userId]
    );
    return result.affectedRows > 0;
}

export async function toggleRiderOnline(userId, isOnline) {
    const [result] = await pool.query(
        `UPDATE riders SET is_online = ? WHERE user_id = ?`,
        [isOnline ? 1 : 0, userId]
    );
    return result.affectedRows > 0;
}

/* ----------------------------------------------------
    GET RIDER BY USER ID
---------------------------------------------------- */
export async function getRiderByUserId(userId) {
    const [rows] = await pool.query(
        `SELECT r.*, u.full_name, u.phone, a.name as agency_name 
         FROM riders r 
         JOIN users u ON r.user_id = u.id 
         JOIN agents a ON r.agent_id = a.id
         WHERE r.user_id = ?`,
        [userId]
    );
    return rows[0] || null;
}