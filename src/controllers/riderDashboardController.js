import pool from "../config/db.js";
import ApiError from "../utils/ApiError.js";

/* ------------------------------------------------------------
   Resolve rider_id from logged-in user
------------------------------------------------------------ */
async function getRiderId(req) {
    const { role, id: userId } = req.user;

    if (role !== "rider") {
        throw new ApiError(403, "Only riders can access rider dashboard");
    }

    const [rows] = await pool.query(
        "SELECT id FROM riders WHERE user_id = ? LIMIT 1",
        [userId]
    );

    if (!rows.length) {
        throw new ApiError(404, "Rider profile not found");
    }

    return rows[0].id;
}

/* ------------------------------------------------------------
   RIDER DASHBOARD
------------------------------------------------------------ */
export async function getRiderDashboard(req, res, next) {
    try {
        const riderId = await getRiderId(req);

        /* ------------------------------------------
           1) Today's assigned pickups
        ------------------------------------------ */
        const [todayAssigned] = await pool.query(
            `
            SELECT 
                p.id AS pickup_id,
                p.booking_code,
                p.status,
                p.scheduled_time_slot,
                p.pickup_latitude,
                p.pickup_longitude,
                p.customer_note,
                u.full_name AS customer_name,
                ca.address_line AS address
            FROM pickups p
            JOIN customers c ON p.customer_id = c.id
            JOIN users u ON c.user_id = u.id
            LEFT JOIN customer_addresses ca ON p.customer_address_id = ca.id
            WHERE p.rider_id = ?
              AND (
                   p.status IN ('assigned', 'rider_on_way', 'arrived', 'weighing')
                   OR DATE(p.created_at) = CURDATE()
                  )
            ORDER BY p.created_at DESC
            `,
            [riderId]
        );

        /* ------------------------------------------
           2) Performance Stats
        ------------------------------------------ */
        const [performance] = await pool.query(
            `
            SELECT
                COALESCE(SUM(CASE 
                    WHEN DATE(completed_at) = CURDATE() 
                    THEN 1 ELSE 0 END), 0) AS today_completed,

                COALESCE(SUM(CASE 
                    WHEN YEARWEEK(completed_at, 1) = YEARWEEK(CURDATE(), 1) 
                    THEN 1 ELSE 0 END), 0) AS week_completed,

                COALESCE(SUM(CASE 
                    WHEN YEAR(completed_at) = YEAR(CURDATE())
                     AND MONTH(completed_at) = MONTH(CURDATE())
                    THEN 1 ELSE 0 END), 0) AS month_completed,

                COALESCE(SUM(CASE WHEN status='completed' THEN 1 ELSE 0 END), 0) AS total_completed
            FROM pickups
            WHERE rider_id = ?
            `,
            [riderId]
        );

        /* ------------------------------------------
           3) Earnings Summary
        ------------------------------------------ */
        const [earnings] = await pool.query(
            `
            SELECT
                COALESCE(SUM(
                    CASE WHEN DATE(completed_at)=CURDATE()
                    THEN rider_commission_amount ELSE 0 END
                ),0) AS today,

                COALESCE(SUM(
                    CASE WHEN YEARWEEK(completed_at,1)=YEARWEEK(CURDATE(),1)
                    THEN rider_commission_amount ELSE 0 END
                ),0) AS week,

                COALESCE(SUM(
                    CASE WHEN YEAR(completed_at)=YEAR(CURDATE())
                     AND MONTH(completed_at)=MONTH(CURDATE())
                    THEN rider_commission_amount ELSE 0 END
                ),0) AS month,

                COALESCE(SUM(rider_commission_amount),0) AS total
            FROM pickups
            WHERE rider_id = ?
              AND status='completed'
            `,
            [riderId]
        );

        /* ------------------------------------------
           4) Status Summary
        ------------------------------------------ */
        const [statusSummary] = await pool.query(
            `
            SELECT
                SUM(CASE WHEN status='assigned' THEN 1 ELSE 0 END) AS assigned,
                SUM(CASE WHEN status='rider_on_way' THEN 1 ELSE 0 END) AS rider_on_way,
                SUM(CASE WHEN status='arrived' THEN 1 ELSE 0 END) AS arrived,
                SUM(CASE WHEN status='weighing' THEN 1 ELSE 0 END) AS weighing,
                SUM(CASE WHEN status='completed' THEN 1 ELSE 0 END) AS completed
            FROM pickups
            WHERE rider_id = ?
            `,
            [riderId]
        );

        /* ------------------------------------------
           FINAL RESPONSE
        ------------------------------------------ */
        return res.json({
            success: true,
            data: {
                today: {
                    assigned: todayAssigned,
                    completed_count: performance[0].today_completed
                },
                performance: performance[0],
                earnings: earnings[0],
                status_summary: statusSummary[0]
            }
        });

    } catch (err) {
        next(err);
    }
}
