// src/controllers/auditController.js
import db from '../config/db.js';

/**
 * 1. GET PRICE HISTORY
 * Allows Users/Admins to see how prices for Plastic/Iron have changed.
 */
export const getPriceHistory = async (req, res) => {
    const { itemId } = req.params;
    const [rows] = await db.query(
        "SELECT * FROM scrap_price_history WHERE scrap_item_id = ? ORDER BY created_at DESC",
        [itemId]
    );
    res.json({ success: true, data: rows });
};

/**
 * 2. ADMIN AUDIT LOGS
 * God-view of who deleted what or updated sensitive settings.
 */
export const getSystemAuditLogs = async (req, res) => {
    const [rows] = await db.query(
        "SELECT l.*, u.full_name FROM admin_audit_logs l JOIN users u ON l.admin_id = u.id ORDER BY l.created_at DESC LIMIT 100"
    );
    res.json({ success: true, data: rows });
};

/**
 * 3. UPDATE AGENT COVERAGE
 * Maps an Agent Hub to specific Upazilas.
 */
export const updateAgentCoverage = async (req, res) => {
    const { agent_id, upazila_ids } = req.body; // Array [12, 14, 15]

    // Clear old coverage and insert new
    await db.query("DELETE FROM agent_coverage WHERE agent_id = ?", [agent_id]);

    for (let upzId of upazila_ids) {
        await db.query("INSERT INTO agent_coverage (agent_id, upazila_id) VALUES (?, ?)", [agent_id, upzId]);
    }
    res.json({ success: true, message: "Hub coverage zones updated." });
};