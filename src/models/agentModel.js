// src/models/agentModel.js
import pool from "../config/db.js";

/* ============================================================
    CREATE AGENT
    Updated: Uses Geographical IDs (Division/District/Upazila)
============================================================ */
export async function createAgent({
    ownerUserId,
    company_name,
    email = null,
    phone = null,
    address_line = null,
    division_id = null,
    district_id = null,
    upazila_id = null,
    commission_type = "percentage",
    commission_value = 0.00,
    area_coverage = null
}) {
    // Generate a unique Agent Code if not provided
    const agentCode = 'AG-' + Math.random().toString(36).substring(2, 7).toUpperCase();

    const [result] = await pool.query(
        `
        INSERT INTO agents (
            owner_user_id,
            name,
            code,
            email,
            phone,
            address_line,
            division_id,
            district_id,
            upazila_id,
            commission_type,
            commission_value,
            area_coverage
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `,
        [
            ownerUserId,
            company_name,
            agentCode,
            email,
            phone,
            address_line,
            division_id,
            district_id,
            upazila_id,
            commission_type,
            commission_value,
            area_coverage
        ]
    );

    return { id: result.insertId, code: agentCode };
}

/* ============================================================
    LIST ALL AGENTS (ADMIN)
    Joins with Geography and Wallet for a full overview
============================================================ */
export async function getAgents() {
    const [rows] = await pool.query(
        `
        SELECT 
            a.id AS agent_id,
            a.code AS agent_code,
            a.name AS company_name,
            u.id AS owner_id,
            u.full_name AS owner_name,
            u.phone AS owner_phone,
            div.name_en AS division_name,
            dis.name_en AS district_name,
            upz.name_en AS upazila_name,
            a.commission_type,
            a.commission_value,
            w.balance AS current_wallet_balance,
            a.created_at
        FROM agents a
        JOIN users u ON a.owner_user_id = u.id
        LEFT JOIN divisions div ON a.division_id = div.id
        LEFT JOIN districts dis ON a.district_id = dis.id
        LEFT JOIN upazilas upz ON a.upazila_id = upz.id
        LEFT JOIN wallet_accounts w ON u.id = w.user_id
        ORDER BY a.created_at DESC
        `
    );

    return rows;
}

/* ============================================================
    GET AGENT BY ID
============================================================ */
export async function getAgentById(agentId) {
    const [rows] = await pool.query(
        `
        SELECT 
            a.*,
            u.full_name AS owner_name,
            u.phone AS owner_phone,
            u.email AS owner_email,
            div.name_en AS division_name,
            dis.name_en AS district_name,
            upz.name_en AS upazila_name
        FROM agents a
        JOIN users u ON a.owner_user_id = u.id
        LEFT JOIN divisions div ON a.division_id = div.id
        LEFT JOIN districts dis ON a.district_id = dis.id
        LEFT JOIN upazilas upz ON a.upazila_id = upz.id
        WHERE a.id = ?
        LIMIT 1
        `,
        [agentId]
    );

    return rows[0] || null;
}

/* ============================================================
    GET AGENT BY USER ID
============================================================ */
export async function getAgentByUserId(userId) {
    const [rows] = await pool.query(
        `
        SELECT 
            a.id AS agent_id,
            a.owner_user_id,
            a.name AS company_name,
            a.code AS agent_code,
            a.upazila_id,
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

    const allowedFields = [
        'name', 'email', 'phone', 'address_line',
        'division_id', 'district_id', 'upazila_id',
        'commission_type', 'commission_value', 'area_coverage', 'is_active'
    ];

    Object.entries(data).forEach(([key, value]) => {
        if (allowedFields.includes(key) && value !== undefined) {
            fields.push(`${key} = ?`);
            values.push(value);
        }
    });

    if (!fields.length) return false;

    values.push(agentId);

    const [result] = await pool.query(
        `UPDATE agents SET ${fields.join(", ")} WHERE id = ?`,
        values
    );

    return result.affectedRows > 0;
}

/* ============================================================
    DELETE AGENT (Hard delete)
============================================================ */
export async function deleteAgent(agentId) {
    // Note: In real applications, check for assigned riders/pickups first
    const [result] = await pool.query(`DELETE FROM agents WHERE id = ?`, [agentId]);
    return result.affectedRows > 0;
}