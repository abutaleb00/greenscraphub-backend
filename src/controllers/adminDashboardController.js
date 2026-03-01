import pool from "../config/db.js";
import ApiError from "../utils/ApiError.js";

export async function getAdminDashboard(req, res, next) {
    try {
        /* ---------------------------------------------
           1) TOTALS
        --------------------------------------------- */
        const [totals] = await pool.query(`
            SELECT 
                COUNT(*) AS total_pickups,
                SUM(CASE WHEN status='completed' THEN 1 ELSE 0 END) AS completed_pickups,
                SUM(CASE WHEN status='cancelled' THEN 1 ELSE 0 END) AS cancelled_pickups,
                COALESCE(SUM(agent_commission_amount), 0) AS total_earnings
            FROM pickups
        `);

        /* ---------------------------------------------
           2) MONTHLY INCOME REPORT
        --------------------------------------------- */
        const [monthlyIncome] = await pool.query(`
            SELECT 
                DATE_FORMAT(completed_at, '%Y-%m') AS month,
                COALESCE(SUM(agent_commission_amount), 0) AS total_income
            FROM pickups
            WHERE status='completed'
            GROUP BY DATE_FORMAT(completed_at, '%Y-%m')
            ORDER BY month DESC
            LIMIT 12
        `);

        /* ---------------------------------------------
           3) CATEGORY STATISTICS
        --------------------------------------------- */
        const [categoryStats] = await pool.query(`
            SELECT 
                cat.id AS category_id,
                cat.name AS category_name,
                COUNT(pi.id) AS total_items,
                SUM(pi.actual_weight) AS total_weight
            FROM pickup_items pi
            JOIN scrap_items si ON pi.scrap_item_id = si.id
            JOIN categories cat ON si.category_id = cat.id
            GROUP BY cat.id, cat.name
            ORDER BY total_items DESC
        `);

        /* ---------------------------------------------
           4) TOP AGENTS
        --------------------------------------------- */
        const [topAgents] = await pool.query(`
            SELECT 
                a.id AS agent_id,
                a.name AS agent_name,
                COUNT(p.id) AS total_completed,
                SUM(p.agent_commission_amount) AS total_earnings
            FROM pickups p
            JOIN agents a ON p.agent_id = a.id
            WHERE p.status='completed'
            GROUP BY a.id
            ORDER BY total_earnings DESC
            LIMIT 10
        `);

        /* ---------------------------------------------
           5) TOP RIDERS
        --------------------------------------------- */
        const [topRiders] = await pool.query(`
            SELECT 
                r.id AS rider_id,
                u.full_name AS rider_name,
                r.rating_avg,
                COUNT(p.id) AS completed_tasks
            FROM riders r
            JOIN users u ON r.user_id = u.id
            LEFT JOIN pickups p ON p.rider_id = r.id AND p.status='completed'
            GROUP BY r.id, u.full_name, r.rating_avg
            ORDER BY completed_tasks DESC
            LIMIT 10
        `);

        /* ---------------------------------------------
           FINAL RESPONSE
        --------------------------------------------- */
        res.json({
            success: true,
            data: {
                totals: totals[0],
                monthly_income_chart: monthlyIncome,
                category_stats: categoryStats,
                top_agents: topAgents,
                top_riders: topRiders
            }
        });
    } catch (err) {
        next(err);
    }
}
