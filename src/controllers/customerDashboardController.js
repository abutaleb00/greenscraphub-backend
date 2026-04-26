import pool from "../config/db.js";
import ApiError from "../utils/ApiError.js";

async function getCustomerId(req) {
    const { role, id: userId } = req.user;
    if (role !== "customer") throw new ApiError(403, "Access denied.");
    const [rows] = await pool.query("SELECT id FROM customers WHERE user_id = ? LIMIT 1", [userId]);
    if (!rows.length) throw new ApiError(404, "Customer profile not found");
    return rows[0].id;
}

export async function getCustomerDashboard(req, res, next) {
    try {
        const customerId = await getCustomerId(req);
        const userId = req.user.id;

        /* ------------------------------------------------------------
            1) PROFILE & TOTAL IMPACT SUMMARY
        ------------------------------------------------------------ */
        const [profileRows] = await pool.query(
            `
            SELECT 
                c.total_points,
                c.referral_code,
                (SELECT balance FROM wallet_accounts WHERE user_id = ?) AS wallet_balance,
                (SELECT COUNT(*) FROM customers WHERE referred_by = c.id) AS total_referrals,
                (SELECT COALESCE(SUM(net_payable_amount), 0) FROM pickups WHERE customer_id = c.id AND status = 'completed') AS total_earned,
                -- Fixed: Summing actual_weight from items linked to completed pickups
                (SELECT COALESCE(SUM(pi.actual_weight), 0) 
                 FROM pickup_items pi 
                 JOIN pickups p2 ON pi.pickup_id = p2.id 
                 WHERE p2.customer_id = c.id AND p2.status = 'completed') AS total_weight_recycled
            FROM customers c
            WHERE c.id = ?
            `,
            [userId, customerId]
        );

        const profile = profileRows[0];

        /* ------------------------------------------------------------
            2) DYNAMIC CHART DATA (Last 6 Months)
            Fixed: Using pi.actual_weight logic for the chart
        ------------------------------------------------------------ */
        const [monthlyRows] = await pool.query(
            `
            SELECT 
                m.month_idx,
                COALESCE(SUM(pi.actual_weight), 0) AS weight
            FROM (
                SELECT 0 AS month_idx UNION SELECT 1 UNION SELECT 2 UNION 
                SELECT 3 UNION SELECT 4 UNION SELECT 5
            ) m
            LEFT JOIN pickups p ON 
                p.customer_id = ? AND 
                p.status = 'completed' AND 
                MONTH(p.completed_at) = MONTH(CURRENT_DATE - INTERVAL m.month_idx MONTH) AND
                YEAR(p.completed_at) = YEAR(CURRENT_DATE - INTERVAL m.month_idx MONTH)
            LEFT JOIN pickup_items pi ON p.id = pi.pickup_id
            GROUP BY m.month_idx
            ORDER BY m.month_idx DESC
            `,
            [customerId]
        );

        const monthlyStats = monthlyRows.map(row => parseFloat(row.weight));

        /* ------------------------------------------------------------
            3) ACTIVE PICKUPS
        ------------------------------------------------------------ */
        const [activePickups] = await pool.query(
            `
            SELECT 
                p.id, p.booking_code, p.status, 
                p.scheduled_date, p.scheduled_time_slot,
                u.full_name AS rider_name,
                u.phone AS rider_phone
            FROM pickups p
            LEFT JOIN riders r ON p.rider_id = r.id
            LEFT JOIN users u ON r.user_id = u.id
            WHERE p.customer_id = ? 
              AND p.status NOT IN ('completed', 'cancelled')
            ORDER BY p.created_at DESC
            `,
            [customerId]
        );

        /* ------------------------------------------------------------
            4) STATUS-WISE COUNTS
        ------------------------------------------------------------ */
        const [statusStats] = await pool.query(
            `
            SELECT
                SUM(CASE WHEN status='pending' THEN 1 ELSE 0 END) AS pending,
                SUM(CASE WHEN status IN ('assigned', 'rider_on_way', 'arrived', 'weighing') THEN 1 ELSE 0 END) AS in_progress,
                SUM(CASE WHEN status='completed' THEN 1 ELSE 0 END) AS completed
            FROM pickups
            WHERE customer_id = ?
            `,
            [customerId]
        );

        /* ------------------------------------------------------------
            5) RECENT HISTORY PREVIEW
        ------------------------------------------------------------ */
        const [recentHistory] = await pool.query(
            `
            SELECT 
                id, booking_code, status, net_payable_amount, 
                completed_at
            FROM pickups
            WHERE customer_id = ? AND status = 'completed'
            ORDER BY completed_at DESC LIMIT 5
            `,
            [customerId]
        );

        const totalKg = parseFloat(profile?.total_weight_recycled || 0);

        return res.json({
            success: true,
            data: {
                profile: {
                    wallet_balance: parseFloat(profile?.wallet_balance || 0),
                    green_points: profile?.total_points || 0,
                    referral_code: profile?.referral_code,
                    referral_count: profile?.total_referrals || 0,
                    total_earned: parseFloat(profile?.total_earned || 0)
                },
                impact: {
                    total_kg_recycled: totalKg,
                    co2_saved_kg: (totalKg * 1.2).toFixed(2),
                    trees_saved_equivalent: (totalKg * 0.05).toFixed(1),
                    monthly_stats: monthlyStats
                },
                orders: {
                    active: activePickups,
                    stats: statusStats[0] || { pending: 0, in_progress: 0, completed: 0 },
                    history_preview: recentHistory
                },
                meta: {
                    hub_region: "Khulna",
                    server_time: new Date()
                }
            }
        });

    } catch (err) {
        next(err);
    }
}