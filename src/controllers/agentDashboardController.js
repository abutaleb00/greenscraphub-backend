import pool from "../config/db.js";
import ApiError from "../utils/ApiError.js";

/**
 * Helper: Resolve the Agent ID based on the logged-in user's role.
 */
async function resolveAgentId(req) {
    const { role, id: userId } = req.user;
    const { agent_id } = req.query;

    if (role === "admin") {
        if (!agent_id) throw new ApiError(400, "Admin must specify ?agent_id= to view a specific hub.");
        return Number(agent_id);
    }

    if (role === "agent") {
        const [rows] = await pool.query("SELECT id FROM agents WHERE owner_user_id = ? LIMIT 1", [userId]);
        if (!rows.length) throw new ApiError(404, "Agent profile not found.");
        return rows[0].id;
    }

    throw new ApiError(403, "Access denied to Agent Dashboard.");
}

export async function getAgentDashboard(req, res, next) {
    try {
        const agentId = await resolveAgentId(req);

        /* ---------------------------------------------
           1) LIVE OPERATIONS (Today's Pulse)
        --------------------------------------------- */
        const [todayStats] = await pool.query(`
            SELECT
                COUNT(*) AS total_today,
                SUM(CASE WHEN status IN ('pending', 'assigned', 'rider_on_way', 'arrived', 'weighing') THEN 1 ELSE 0 END) AS active_now,
                SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) AS completed_today,
                COALESCE(SUM(CASE WHEN status = 'completed' THEN agent_commission_amount ELSE 0 END), 0) AS earnings_today,
                (SELECT COALESCE(SUM(pi.actual_weight), 0) 
                 FROM pickup_items pi 
                 JOIN pickups p ON pi.pickup_id = p.id 
                 WHERE p.agent_id = ? AND DATE(p.completed_at) = CURDATE()) AS tonnage_today
            FROM pickups
            WHERE agent_id = ? AND (DATE(created_at) = CURDATE() OR scheduled_date = CURDATE())
        `, [agentId, agentId]);

        /* ---------------------------------------------
           2) FINANCIAL OVERVIEW (Wallet & Cash)
        --------------------------------------------- */
        const [financeStats] = await pool.query(`
            SELECT
                COALESCE(SUM(agent_commission_amount), 0) AS total_lifetime_commission,
                -- Total cash riders currently have that hasn't been settled
                COALESCE(SUM(rider_collected_cash), 0) AS total_rider_cash_collected,
                (SELECT balance FROM wallet_accounts WHERE user_id = (SELECT owner_user_id FROM agents WHERE id = ?)) AS current_wallet_balance
            FROM pickups
            WHERE agent_id = ? AND status = 'completed'
        `, [agentId, agentId]);

        /* ---------------------------------------------
           3) RIDER PERFORMANCE (Staff Accountability)
        --------------------------------------------- */
        const [riderPerformance] = await pool.query(`
            SELECT
                u.full_name AS name,
                r.is_online,
                r.vehicle_type,
                r.rating_avg,
                COUNT(p.id) AS total_pickups,
                COALESCE(SUM(p.rider_collected_cash), 0) AS cash_in_hand
            FROM riders r
            JOIN users u ON r.user_id = u.id
            LEFT JOIN pickups p ON p.rider_id = r.id AND p.status = 'completed'
            WHERE r.agent_id = ?
            GROUP BY r.id
            ORDER BY r.is_online DESC, cash_in_hand DESC
        `, [agentId]);

        /* ---------------------------------------------
           4) RECENT BOOKINGS (Actionable Feed)
        --------------------------------------------- */
        const [recentBookings] = await pool.query(`
            SELECT 
                p.id, p.booking_code, p.status, p.net_payable_amount, 
                u.full_name AS customer_name,
                p.scheduled_time_slot,
                ru.full_name AS rider_name
            FROM pickups p
            JOIN customers c ON p.customer_id = c.id
            JOIN users u ON c.user_id = u.id
            LEFT JOIN riders r ON p.rider_id = r.id
            LEFT JOIN users ru ON r.user_id = ru.id
            WHERE p.agent_id = ?
            ORDER BY p.created_at DESC LIMIT 10
        `, [agentId]);

        /* ---------------------------------------------
           5) INVENTORY INSIGHTS (Warehouse Stock)
        --------------------------------------------- */
        const [inventory] = await pool.query(`
            SELECT 
                cat.name_en, 
                cat.name_bn,
                SUM(pi.actual_weight) AS total_weight_kg
            FROM pickup_items pi
            JOIN pickups p ON pi.pickup_id = p.id
            JOIN scrap_items si ON pi.item_id = si.id
            JOIN scrap_categories cat ON si.category_id = cat.id
            WHERE p.agent_id = ? AND p.status = 'completed'
            GROUP BY cat.id
            ORDER BY total_weight_kg DESC
        `, [agentId]);

        /* ---------------------------------------------
           CONSOLIDATED RESPONSE
        --------------------------------------------- */
        res.json({
            success: true,
            data: {
                operational_summary: todayStats[0],
                financial_summary: {
                    wallet_balance: financeStats[0]?.current_wallet_balance || 0,
                    lifetime_commission: financeStats[0]?.total_lifetime_commission || 0,
                    outstanding_rider_cash: financeStats[0]?.total_rider_cash_collected || 0
                },
                riders: riderPerformance,
                recent_pickups: recentBookings,
                inventory: inventory,
                hub_meta: {
                    timestamp: new Date(),
                    agent_id: agentId
                }
            }
        });

    } catch (err) {
        next(err);
    }
}