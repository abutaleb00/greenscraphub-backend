// src/models/agentModel.js
import pool from "../config/db.js";

/* ============================================================
   CREATE AGENT
   Called after a user is created with role=agent
============================================================ */
export async function createAgent({
    ownerUserId,
    company_name,
    email = null,
    phone = null,
    address_line = null,
    city = null,
    state = null,
    country = null,
    postal_code = null,
    commission_type = "percentage",
    commission_value = 0.00,
}) {
    const [result] = await pool.query(
        `
        INSERT INTO agents (
            owner_user_id,
            name,
            email,
            phone,
            address_line,
            city,
            state,
            country,
            postal_code,
            commission_type,
            commission_value
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `,
        [
            ownerUserId,
            company_name,   // DB column = name
            email,
            phone,
            address_line,
            city,
            state,
            country,
            postal_code,
            commission_type,
            commission_value,
        ]
    );

    return { id: result.insertId };
}

/* ============================================================
   LIST ALL AGENTS (ADMIN)
============================================================ */
export async function getAgents() {
    const [rows] = await pool.query(
        `
        SELECT 
            a.id AS agent_id,
            u.id AS owner_id,
            u.full_name AS owner_name,
            u.phone AS owner_phone,
            u.email AS owner_email,
            u.is_active,

            a.name AS company_name,
            a.email AS agent_email,
            a.phone AS agent_phone,
            a.city,
            a.state,
            a.country,
            a.commission_type,
            a.commission_value,
            a.created_at
        FROM agents a
        JOIN users u ON a.owner_user_id = u.id
        ORDER BY a.created_at DESC
        `
    );

    return rows;
}

/* ============================================================
   GET AGENT BY AGENT ID
============================================================ */
export async function getAgentById(agentId) {
    const [rows] = await pool.query(
        `
        SELECT 
            a.id AS agent_id,
            u.id AS owner_id,
            u.full_name AS owner_name,
            u.phone AS owner_phone,
            u.email AS owner_email,
            u.is_active,

            a.name AS company_name,
            a.email AS agent_email,
            a.phone AS agent_phone,
            a.address_line,
            a.city,
            a.state,
            a.country,
            a.postal_code,
            a.commission_type,
            a.commission_value,
            a.created_at
        FROM agents a
        JOIN users u ON a.owner_user_id = u.id
        WHERE a.id = ?
        LIMIT 1
        `,
        [agentId]
    );

    return rows[0] || null;
}

/* ============================================================
   GET AGENT BY USER ID (IMPORTANT)
   Used when an Agent logs in and when creating riders
============================================================ */
export async function getAgentByUserId(userId) {
    const [rows] = await pool.query(
        `
        SELECT 
            a.id AS agent_id,
            a.owner_user_id,
            a.name AS company_name,
            a.city,
            a.state,
            a.country,
            a.commission_type,
            a.commission_value
        FROM agents a
        WHERE a.owner_user_id = ?
        LIMIT 1
        `,
        [userId]
    );

    return rows[0] || null;
}

/* ============================================================
   UPDATE AGENT
============================================================ */
export async function updateAgent(agentId, data) {
    const fields = [];
    const values = [];

    Object.entries(data).forEach(([key, value]) => {
        // prevent invalid SQL
        if (value !== undefined && value !== null) {
            fields.push(`${key} = ?`);
            values.push(value);
        }
    });

    if (!fields.length) return false;

    values.push(agentId);

    await pool.query(
        `
        UPDATE agents 
        SET ${fields.join(", ")} 
        WHERE id = ?
        `,
        values
    );

    return true;
}

/* ============================================================
   DELETE AGENT (Soft delete recommended)
============================================================ */
export async function deleteAgent(agentId) {
    await pool.query(`DELETE FROM agents WHERE id = ?`, [agentId]);
    return true;
}
