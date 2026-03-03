import pool from "../config/db.js";
import ApiError from "../utils/ApiError.js";

/**
 * Helper: Resolve rider_id from logged-in user
 */
async function getRiderId(req) {
    const { role, id: userId } = req.user;

    if (role !== "rider") {
        throw new ApiError(403, "Access denied. Only riders can view this dashboard.");
    }

    const [rows] = await pool.query(
        "SELECT id, is_online FROM riders WHERE user_id = ? LIMIT 1",
        [userId]
    );

    if (!rows.length) {
        throw new ApiError(404, "Rider profile not found");
    }

    return rows[0];
}

export async function getRiderDashboard(req, res, next) {
    try {
        const riderInfo = await getRiderId(req);
        const riderId = riderInfo.id;

        /* ------------------------------------------------------------
            1) ACTIVE TASK LIST (Logistics & Navigation)
            Focuses on scheduled pickups that need action.
        ------------------------------------------------------------ */
        const [activeTasks] = await pool.query(
            `
            SELECT 
                p.id AS pickup_id,
                p.booking_code,
                p.status,
                p.scheduled_date,
                p.scheduled_time_slot,
                p.base_amount,
                u.full_name AS customer_name,
                u.phone AS customer_phone,
                -- Joining addresses to get location data for Google Maps navigation
                a.address_line,
                a.division_id, a.district_id, a.upazila_id,
                p.customer_note
            FROM pickups p
            JOIN customers c ON p.customer_id = c.id
            JOIN users u ON c.user_id = u.id
            LEFT JOIN addresses a ON p.customer_address_id = a.id
            WHERE p.rider_id = ? 
              AND p.status IN ('assigned', 'rider_on_way', 'arrived', 'weighing')
            ORDER BY p.scheduled_date ASC, p.created_at ASC
            `,
            [riderId]
        );

        /* ------------------------------------------------------------
            2) PERFORMANCE SUMMARY (Incentive Tracking)
            Calculates how much the rider earned today vs this month.
        ------------------------------------------------------------ */
        const [stats] = await pool.query(
            `
            SELECT
                COUNT(CASE WHEN DATE(completed_at) = CURDATE() THEN 1 END) AS completed_today,
                COUNT(CASE WHEN MONTH(completed_at) = MONTH(CURDATE()) AND YEAR(completed_at) = YEAR(CURDATE()) THEN 1 END) AS completed_month,
                COALESCE(SUM(CASE WHEN DATE(completed_at) = CURDATE() THEN rider_commission_amount ELSE 0 END), 0) AS earnings_today,
                COALESCE(SUM(CASE WHEN MONTH(completed_at) = MONTH(CURDATE()) THEN rider_commission_amount ELSE 0 END), 0) AS earnings_month
            FROM pickups
            WHERE rider_id = ? AND status = 'completed'
            `,
            [riderId]
        );

        /* ------------------------------------------------------------
            3) FINANCIAL ACCOUNTABILITY (Cash Collection)
            Money currently in the rider's pocket from cash pickups.
        ------------------------------------------------------------ */
        const [finance] = await pool.query(
            `
            SELECT 
                -- We track cash where the customer was paid in cash but rider hasn't settled with Agent
                COALESCE(SUM(rider_collected_cash), 0) AS total_cash_held,
                (SELECT balance FROM wallet_accounts WHERE user_id = ?) AS wallet_balance
            FROM pickups 
            WHERE rider_id = ? 
              AND status = 'completed' 
              -- Using your logic: If rider_collected_cash exists, they are holding physical hub money
              AND rider_collected_cash > 0
            `,
            [req.user.id, riderId]
        );

        /* ------------------------------------------------------------
            FINAL RESPONSE (Mobile Optimized)
        ------------------------------------------------------------ */
        return res.json({
            success: true,
            data: {
                rider_status: {
                    is_online: Boolean(riderInfo.is_online),
                    last_pulse: new Date()
                },
                tasks: {
                    active_count: activeTasks.length,
                    active_list: activeTasks
                },
                performance: {
                    today: {
                        pickups: stats[0].completed_today,
                        earned: parseFloat(stats[0].earnings_today)
                    },
                    monthly: {
                        pickups: stats[0].completed_month,
                        earned: parseFloat(stats[0].earnings_month)
                    }
                },
                finance: {
                    cash_in_hand: parseFloat(finance[0].total_cash_held),
                    withdrawable_commission: parseFloat(finance[0].wallet_balance)
                },
                meta: {
                    currency: "BDT",
                    hub_context: "Khulna Division"
                }
            }
        });

    } catch (err) {
        next(err);
    }
}