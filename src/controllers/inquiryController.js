import db from '../config/db.js';

/**
 * 1. SUBMIT INQUIRY (Public)
 * Handles both general contact and corporate leads.
 */
export const submitInquiry = async (req, res) => {
    try {
        const { type, full_name, email, phone, company_name, inquiry_category, message } = req.body;

        await db.query(
            `INSERT INTO unified_inquiries 
            (type, full_name, email, phone, company_name, inquiry_category, message) 
            VALUES (?, ?, ?, ?, ?, ?, ?)`,
            [type, full_name, email, phone, company_name || null, inquiry_category, message]
        );

        res.json({ success: true, message: "Transmission received." });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

/**
 * 2. GET ALL INQUIRIES (Admin)
 * Includes optional filtering by type (general/corporate) or status.
 */
export const getAllInquiries = async (req, res) => {
    try {
        const { type, status } = req.query;
        let sql = "SELECT * FROM unified_inquiries WHERE 1=1";
        const params = [];

        if (type) { sql += " AND type = ?"; params.push(type); }
        if (status) { sql += " AND status = ?"; params.push(status); }

        sql += " ORDER BY created_at DESC";

        const [rows] = await db.query(sql, params);
        res.json({ success: true, data: rows });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

/**
 * 3. UPDATE INQUIRY STATUS/NOTES (Admin)
 * Used for marking as read, contacted, or resolved.
 */
export const updateInquiry = async (req, res) => {
    try {
        const { id } = req.params;
        const { status, admin_notes } = req.body;

        await db.query(
            "UPDATE unified_inquiries SET status = ?, admin_notes = ? WHERE id = ?",
            [status, admin_notes, id]
        );

        res.json({ success: true });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

/**
 * 4. DELETE INQUIRY (Admin)
 */
export const deleteInquiry = async (req, res) => {
    try {
        const { id } = req.params;
        await db.query("DELETE FROM unified_inquiries WHERE id = ?", [id]);
        res.json({ success: true });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};