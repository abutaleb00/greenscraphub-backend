// src/models/riderModel.js
import pool from "../config/db.js";

/* ----------------------------------------------------
   CREATE RIDER
---------------------------------------------------- */
export async function createRider({ userId, agentId, vehicleType, vehicleNumber }) {
    const [result] = await pool.query(
        `
        INSERT INTO riders (
            user_id,
            agent_id,
            vehicle_type,
            vehicle_number
        )
        VALUES (?, ?, ?, ?)
        `,
        [userId, agentId, vehicleType, vehicleNumber]
    );

    return { id: result.insertId };
}

/* ----------------------------------------------------
   GET RIDERS BY AGENT
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
            r.created_at
        FROM riders r
        JOIN users u ON r.user_id = u.id
        WHERE r.agent_id = ?
        ORDER BY r.created_at DESC
        `,
        [agentId]
    );

    return rows;
}

/* ----------------------------------------------------
   GET ALL RIDERS WITH AGENT INFO (ADMIN)
---------------------------------------------------- */
export async function getAllRidersWithAgent() {
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
            r.created_at,

            a.id AS agent_id,
            a.name AS agent_company_name,
            au.full_name AS agent_owner_name,
            au.phone AS agent_owner_phone
        FROM riders r
        JOIN users u ON r.user_id = u.id
        JOIN agents a ON r.agent_id = a.id
        JOIN users au ON a.owner_user_id = au.id   -- FIXED HERE
        ORDER BY r.created_at DESC
        `
    );

    return rows;
}