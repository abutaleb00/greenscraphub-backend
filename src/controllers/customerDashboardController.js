import pool from "../config/db.js";
import ApiError from "../utils/ApiError.js";

/**
 * Helper: Resolve customer_id from logged-in user
 */
async function getCustomerId(req) {
    const { role, id: userId } = req.user;

    if (role !== "customer") {
        throw new ApiError(403, "Access denied. Only customers can view this dashboard.");
    }

    const [rows] = await pool.query(
        "SELECT id FROM customers WHERE user_id = ? LIMIT 1",
        [userId]
    );

    if (!rows.length) {
        throw new ApiError(404, "Customer profile not found");
    }

    return rows[0].id;
}

export async function getCustomerDashboard(req, res, next) {
    try {
        const customerId = await getCustomerId(req);
        const userId = req.user.id;

        /* ------------------------------------------------------------
            1) IMPACT & LOYALTY SUMMARY
            Mapped to: net_payable_amount and total_weight_kg (calculated)
        ------------------------------------------------------------ */
        const [profile] = await pool.query(
            `
            SELECT 
                c.total_points,
                c.referral_code,
                (SELECT balance FROM wallet_accounts WHERE user_id = ?) AS wallet_balance,
                (SELECT COUNT(*) FROM customers WHERE referred_by = c.id) AS total_referrals,
                COALESCE(SUM(p.net_payable_amount), 0) AS total_earned,
                -- We sum weight from completed pickups
                (SELECT COALESCE(SUM(pi.actual_weight), 0) 
                 FROM pickup_items pi 
                 JOIN pickups p2 ON pi.pickup_id = p2.id 
                 WHERE p2.customer_id = ? AND p2.status = 'completed') AS total_weight_recycled
            FROM customers c
            LEFT JOIN pickups p ON c.id = p.customer_id AND p.status = 'completed'
            WHERE c.id = ?
            GROUP BY c.id
            `,
            [userId, customerId, customerId]
        );

        /* ------------------------------------------------------------
            2) ACTIVE PICKUPS (Live Tracking)
            Shows status and assigned rider info
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
            3) STATUS-WISE COUNTS (Order Journey)
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
            4) RECENT HISTORY PREVIEW
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

        /* ------------------------------------------------------------
            5) ENVIRONMENTAL IMPACT CALCULATION
            1kg scrap ≈ 1.2kg CO2 saved
            10kg scrap ≈ 0.5 tree offset equivalent
        ------------------------------------------------------------ */
        const totalKg = parseFloat(profile[0]?.total_weight_recycled || 0);
        const co2Saved = (totalKg * 1.2).toFixed(2);
        const treesSaved = (totalKg * 0.05).toFixed(1);

        /* ------------------------------------------------------------
            FINAL STRUCTURED RESPONSE
        ------------------------------------------------------------ */
        return res.json({
            success: true,
            data: {
                profile: {
                    wallet_balance: parseFloat(profile[0]?.wallet_balance || 0),
                    green_points: profile[0]?.total_points || 0,
                    referral_code: profile[0]?.referral_code,
                    referral_count: profile[0]?.total_referrals || 0,
                    total_earned: parseFloat(profile[0]?.total_earned || 0)
                },
                impact: {
                    total_kg_recycled: totalKg,
                    co2_saved_kg: co2Saved,
                    trees_saved_equivalent: treesSaved
                },
                orders: {
                    active: activePickups,
                    stats: statusStats[0] || { pending: 0, in_progress: 0, completed: 0 },
                    history_preview: recentHistory
                },
                meta: {
                    hub_region: "Noapara, Khulna",
                    server_time: new Date()
                }
            }
        });

    } catch (err) {
        next(err);
    }
}