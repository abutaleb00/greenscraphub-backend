import pool from "../config/db.js";
import ApiError from "../utils/ApiError.js";

/* ------------------------------------------------------------
   Resolve customer_id from logged-in user
------------------------------------------------------------ */
async function getCustomerId(req) {
    const { role, id: userId } = req.user;

    if (role !== "customer") {
        throw new ApiError(403, "Only customers can access this dashboard");
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

/* ------------------------------------------------------------
   CUSTOMER DASHBOARD
------------------------------------------------------------ */
export async function getCustomerDashboard(req, res, next) {
    try {
        const customerId = await getCustomerId(req);

        /* ------------------------------------------
           1) STATUS SUMMARY
        ------------------------------------------ */
        const [summary] = await pool.query(
            `
            SELECT
                SUM(CASE WHEN status='pending'        THEN 1 ELSE 0 END) AS pending,
                SUM(CASE WHEN status='assigned'       THEN 1 ELSE 0 END) AS assigned,
                SUM(CASE WHEN status='rider_on_way'   THEN 1 ELSE 0 END) AS rider_on_way,
                SUM(CASE WHEN status='arrived'        THEN 1 ELSE 0 END) AS arrived,
                SUM(CASE WHEN status='weighing'       THEN 1 ELSE 0 END) AS weighing,
                SUM(CASE WHEN status='completed'      THEN 1 ELSE 0 END) AS completed,
                SUM(CASE WHEN status='cancelled'      THEN 1 ELSE 0 END) AS cancelled
            FROM pickups
            WHERE customer_id = ?
            `,
            [customerId]
        );

        /* ------------------------------------------
           2) LAST 10 PICKUPS
        ------------------------------------------ */
        const [recentPickups] = await pool.query(
            `
            SELECT
                p.id AS pickup_id,
                p.booking_code,
                p.status,
                p.scheduled_date,
                p.scheduled_time_slot,
                p.net_payable_amount,
                p.created_at,
                u.full_name AS rider_name
            FROM pickups p
            LEFT JOIN riders r ON p.rider_id = r.id
            LEFT JOIN users u ON r.user_id = u.id
            WHERE p.customer_id = ?
            ORDER BY p.created_at DESC
            LIMIT 10
            `,
            [customerId]
        );

        /* ------------------------------------------
           3) WALLET SUMMARY
        ------------------------------------------ */
        const [wallet] = await pool.query(
            `
            SELECT 
                COALESCE(SUM(cash_paid_to_customer),0) AS total_cash_received,
                COALESCE(SUM(wallet_credit_amount),0) AS wallet_credited,
                COALESCE(SUM(wallet_credit_amount),0) AS wallet_balance
            FROM pickups
            WHERE customer_id = ?
              AND status = 'completed'
            `,
            [customerId]
        );

        /* ------------------------------------------
           4) LIFETIME STATS
        ------------------------------------------ */
        const [lifetime] = await pool.query(
            `
            SELECT
                COUNT(*) AS total_pickups,
                COALESCE(SUM(net_payable_amount),0) AS total_earned
            FROM pickups
            WHERE customer_id = ?
            `,
            [customerId]
        );

        /* ------------------------------------------
           FINAL RESPONSE
        ------------------------------------------ */
        return res.json({
            success: true,
            data: {
                summary: summary[0],
                recent_pickups: recentPickups,
                wallet: wallet[0],
                lifetime: lifetime[0]
            }
        });

    } catch (err) {
        next(err);
    }
}
