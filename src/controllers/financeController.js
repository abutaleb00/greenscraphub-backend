// src/controllers/financeController.js
import db from '../config/db.js';

/**
 * 1. RECORD PLATFORM EARNINGS (Internal)
 * Automatically called when a pickup is completed.
 */
export const recordEarnings = async (pickupId, adminAmount, agentAmount, conn) => {
    await conn.query(
        `INSERT INTO platform_earnings (pickup_id, admin_amount, agent_amount, status) 
         VALUES (?, ?, ?, 'earned')`,
        [pickupId, adminAmount, agentAmount]
    );

    // Also record in the General Ledger for the Admin
    await conn.query(
        `INSERT INTO financial_ledger (type, category, amount, reference_id, description) 
         VALUES ('credit', 'commission', ?, ?, 'Commission from Pickup ID: ?')`,
        [adminAmount, pickupId, pickupId]
    );
};

/**
 * 2. AGENT-RIDER SETTLEMENT (Hub Management)
 * When a Rider returns cash to the Noapara Agent.
 */
export const settleRiderCash = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        await conn.beginTransaction();
        const { rider_id, amount, note } = req.body;
        const agent_user_id = req.user.id;

        const [agent] = await conn.query("SELECT id FROM agents WHERE owner_user_id = ?", [agent_user_id]);

        const [result] = await conn.query(
            `INSERT INTO settlements (agent_id, rider_id, amount, status, note) 
             VALUES (?, ?, ?, 'completed', ?)`,
            [agent[0].id, rider_id, amount, note]
        );

        // Update the pickups for this rider to 'settled'
        await conn.query(
            "UPDATE pickups SET is_settled_with_agent = 1 WHERE rider_id = ? AND agent_id = ? AND status = 'completed'",
            [rider_id, agent[0].id]
        );

        await conn.commit();
        res.json({ success: true, message: "Settlement recorded and rider accounts cleared." });
    } catch (err) {
        await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};