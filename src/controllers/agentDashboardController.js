import pool from "../config/db.js";
import ApiError from "../utils/ApiError.js";

async function resolveAgentId(req) {
    const { role, id: userId } = req.user;
    const { agent_id } = req.query;
    if (role === "admin") return agent_id ? Number(agent_id) : null;
    if (role === "agent") {
        const [rows] = await pool.query("SELECT id FROM agents WHERE owner_user_id = ?", [userId]);
        return rows[0]?.id || null;
    }
    return null;
}

export async function getAgentDashboard(req, res, next) {
    try {
        const agentId = await resolveAgentId(req);
        if (!agentId) throw new ApiError(404, "Agent profile not identified.");

        /* ---------------------------------------------
           1) REAL-TIME HUB PULSE (Live Ops)
        --------------------------------------------- */
        const [ops] = await pool.query(`
            SELECT
                COUNT(id) AS total_today,
                SUM(CASE WHEN status IN ('assigned', 'rider_on_way', 'arrived', 'weighing') THEN 1 ELSE 0 END) AS active_missions,
                SUM(CASE WHEN status = 'completed' AND DATE(completed_at) = CURDATE() THEN 1 ELSE 0 END) AS completed_today,
                COALESCE(SUM(CASE WHEN DATE(completed_at) = CURDATE() THEN agent_commission_amount ELSE 0 END), 0) AS earnings_today,
                (SELECT COALESCE(SUM(actual_weight), 0) FROM pickup_items pi 
                 JOIN pickups p ON pi.pickup_id = p.id 
                 WHERE p.agent_id = ? AND DATE(p.completed_at) = CURDATE()) AS tonnage_today
            FROM pickups
            WHERE agent_id = ? AND (DATE(created_at) = CURDATE() OR DATE(scheduled_date) = CURDATE())
        `, [agentId, agentId]);

        /* ---------------------------------------------
           2) HUB VAULT & LIQUIDITY (The "Money" Card)
        --------------------------------------------- */
        // We calculate 'Vault Cash' (Settled) vs 'Field Cash' (Unsettled)
        const [finance] = await pool.query(`
            SELECT
                (SELECT balance FROM wallet_accounts WHERE user_id = (SELECT owner_user_id FROM agents WHERE id = ?)) AS wallet_balance,
                COALESCE(SUM(CASE WHEN is_settled_to_hub = 0 THEN rider_collected_cash ELSE 0 END), 0) AS field_cash_liability,
                COALESCE(SUM(CASE WHEN is_settled_to_hub = 1 THEN rider_collected_cash ELSE 0 END), 0) AS total_vault_intake,
                COALESCE(SUM(agent_commission_amount), 0) AS lifetime_earnings
            FROM pickups
            WHERE agent_id = ? AND status = 'completed' AND payment_method = 'cash'
        `, [agentId, agentId]);

        /* ---------------------------------------------
           3) FLEET STATUS (Live Riders)
        --------------------------------------------- */
        const [riders] = await pool.query(`
            SELECT
                u.full_name AS name,
                r.is_online,
                r.vehicle_type,
                COALESCE(SUM(CASE WHEN p.is_settled_to_hub = 0 THEN p.rider_collected_cash ELSE 0 END), 0) AS cash_in_pocket,
                (SELECT COUNT(*) FROM pickups WHERE rider_id = r.id AND status NOT IN ('completed', 'cancelled')) AS active_tasks
            FROM riders r
            JOIN users u ON r.user_id = u.id
            LEFT JOIN pickups p ON p.rider_id = r.id AND p.status = 'completed'
            WHERE r.agent_id = ?
            GROUP BY r.id
            ORDER BY cash_in_pocket DESC
        `, [agentId]);

        /* ---------------------------------------------
           4) WAREHOUSE STOCK (By Category)
        --------------------------------------------- */
        const [stock] = await pool.query(`
    SELECT 
        cat.name_en AS category, 
        cat.icon, -- Changed from image_url to icon
        SUM(pi.actual_weight) AS weight
    FROM pickup_items pi
    JOIN pickups p ON pi.pickup_id = p.id
    JOIN scrap_items si ON pi.item_id = si.id
    JOIN scrap_categories cat ON si.category_id = cat.id
    WHERE p.agent_id = ? AND p.status = 'completed'
    GROUP BY cat.id
    ORDER BY weight DESC
`, [agentId]);

        /* ---------------------------------------------
           5) RECENT AUDIT LOG (Timeline)
        --------------------------------------------- */
        const [recent] = await pool.query(`
            SELECT p.booking_code, p.status, p.net_payable_amount, u.full_name as customer, ru.full_name as rider
            FROM pickups p
            JOIN customers c ON p.customer_id = c.id JOIN users u ON c.user_id = u.id
            LEFT JOIN riders r ON p.rider_id = r.id LEFT JOIN users ru ON r.user_id = ru.id
            WHERE p.agent_id = ?
            ORDER BY p.updated_at DESC LIMIT 8
        `, [agentId]);

        res.json({
            success: true,
            data: {
                metrics: {
                    today_revenue: ops[0].earnings_today,
                    today_tonnage: ops[0].tonnage_today,
                    active_missions: ops[0].active_missions,
                    completed_today: ops[0].completed_today
                },
                financials: {
                    wallet: finance[0]?.wallet_balance || 0,
                    field_cash: finance[0]?.field_cash_liability || 0,
                    vault_total: finance[0]?.total_vault_intake || 0,
                    lifetime: finance[0]?.lifetime_earnings || 0
                },
                fleet: riders,
                inventory: stock,
                timeline: recent
            }
        });

    } catch (err) {
        next(err);
    }
}