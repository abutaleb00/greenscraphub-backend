// src/controllers/agentDashboardController.js
import pool from "../config/db.js";        // adjust path if needed
import ApiError from "../utils/ApiError.js"; // default export, same as in auth.js

/* --------------------------------------------------
   Helper: resolve agent_id for current request
   - agent user  => lookup agents.owner_user_id = user.id
   - admin user  => must pass ?agent_id= in query
-------------------------------------------------- */
async function resolveAgentId(req) {
    const { role, id: userId } = req.user || {};
    const { agent_id } = req.query || {};

    if (!role || !userId) {
        throw new ApiError(401, "Unauthorized");
    }

    /* --------------------------------------------------------
       ADMIN → CAN VIEW ANY AGENT (REQUIRES ?agent_id=)
    -------------------------------------------------------- */
    if (role === "admin") {
        if (!agent_id) {
            throw new ApiError(
                400,
                "agent_id query parameter is required for admin"
            );
        }
        return Number(agent_id);
    }

    /* --------------------------------------------------------
       AGENT USER → FIND agent.id WHERE owner_user_id = user.id
    -------------------------------------------------------- */
    if (role === "agent") {
        const [rows] = await pool.query(
            "SELECT id FROM agents WHERE owner_user_id = ? LIMIT 1",
            [userId]
        );

        if (!rows.length) {
            throw new ApiError(
                404,
                "Agent profile not found for this user (create agent profile first)"
            );
        }

        return rows[0].id;
    }

    /* --------------------------------------------------------
       RIDER USER → rider.agent_id
    -------------------------------------------------------- */
    if (role === "rider") {
        const [riderRows] = await pool.query(
            "SELECT agent_id FROM riders WHERE user_id = ? LIMIT 1",
            [userId]
        );

        if (!riderRows.length) {
            throw new ApiError(
                404,
                "Rider profile not found for this user"
            );
        }

        return riderRows[0].agent_id;
    }

    /* --------------------------------------------------------
       ALL OTHER ROLES → DENY ACCESS
    -------------------------------------------------------- */
    throw new ApiError(403, "You do not have permission to access the agent dashboard");
}


/* --------------------------------------------------
   MAIN: GET /api/v1/agent/dashboard
-------------------------------------------------- */
export async function getAgentDashboard(req, res, next) {
    try {
        const agentId = await resolveAgentId(req);

        /* ------------------------------------------
           1) TODAY'S PICKUPS (list + summary)
        ------------------------------------------ */
        const [todayList] = await pool.query(
            `
            SELECT 
                p.id,
                p.booking_code,
                p.status,
                p.scheduled_date,
                p.scheduled_time_slot,
                p.net_payable_amount,
                p.created_at,
                c.id AS customer_id,
                u.full_name AS customer_name
            FROM pickups p
            JOIN customers c ON p.customer_id = c.id
            JOIN users u ON c.user_id = u.id
            WHERE p.agent_id = ?
              AND (
                    p.scheduled_date = CURDATE()
                    OR DATE(p.created_at) = CURDATE()
                  )
            ORDER BY 
                p.scheduled_date IS NULL,    -- scheduled ones first
                p.scheduled_date ASC,
                p.created_at DESC
            `,
            [agentId]
        );

        const [todaySummaryRows] = await pool.query(
            `
            SELECT
                COUNT(*) AS total,
                SUM(CASE WHEN status = 'pending'        THEN 1 ELSE 0 END) AS pending,
                SUM(CASE WHEN status = 'assigned'       THEN 1 ELSE 0 END) AS assigned,
                SUM(CASE WHEN status = 'rider_on_way'   THEN 1 ELSE 0 END) AS rider_on_way,
                SUM(CASE WHEN status = 'arrived'        THEN 1 ELSE 0 END) AS arrived,
                SUM(CASE WHEN status = 'weighing'       THEN 1 ELSE 0 END) AS weighing,
                SUM(CASE WHEN status = 'completed'      THEN 1 ELSE 0 END) AS completed,
                SUM(CASE WHEN status = 'cancelled'      THEN 1 ELSE 0 END) AS cancelled
            FROM pickups
            WHERE agent_id = ?
              AND (
                    scheduled_date = CURDATE()
                    OR DATE(created_at) = CURDATE()
                  )
            `,
            [agentId]
        );

        const todaySummary = todaySummaryRows[0] || {
            total: 0,
            pending: 0,
            assigned: 0,
            rider_on_way: 0,
            arrived: 0,
            weighing: 0,
            completed: 0,
            cancelled: 0,
        };

        /* ------------------------------------------
           2) RIDER PERFORMANCE
        ------------------------------------------ */
        const [riderStats] = await pool.query(
            `
            SELECT
                r.id AS rider_id,
                u.full_name AS rider_name,
                r.vehicle_type,
                r.vehicle_number,
                r.rating_avg,
                r.total_completed,

                COALESCE(SUM(CASE WHEN p.status = 'completed' THEN 1 ELSE 0 END), 0) AS total_pickups,
                COALESCE(SUM(CASE 
                    WHEN p.status = 'completed'
                     AND DATE(p.completed_at) = CURDATE()
                    THEN 1 ELSE 0 END), 0) AS today_completed,

                COALESCE(SUM(CASE 
                    WHEN p.status = 'completed'
                     AND YEARWEEK(p.completed_at, 1) = YEARWEEK(CURDATE(), 1)
                    THEN 1 ELSE 0 END), 0) AS week_completed,

                COALESCE(SUM(CASE 
                    WHEN p.status = 'completed'
                     AND YEAR(p.completed_at) = YEAR(CURDATE())
                     AND MONTH(p.completed_at) = MONTH(CURDATE())
                    THEN 1 ELSE 0 END), 0) AS month_completed

            FROM riders r
            JOIN users u ON r.user_id = u.id
            LEFT JOIN pickups p 
                ON p.rider_id = r.id
               AND p.agent_id = r.agent_id
            WHERE r.agent_id = ?
            GROUP BY
                r.id,
                u.full_name,
                r.vehicle_type,
                r.vehicle_number,
                r.rating_avg,
                r.total_completed
            ORDER BY u.full_name ASC
            `,
            [agentId]
        );

        /* ------------------------------------------
           3) EARNINGS (Agent commission)
        ------------------------------------------ */
        const [earningRows] = await pool.query(
            `
            SELECT
                COALESCE(SUM(agent_commission_amount), 0) AS total_earnings,
                COALESCE(SUM(
                    CASE 
                        WHEN DATE(completed_at) = CURDATE() 
                        THEN agent_commission_amount 
                        ELSE 0 
                    END
                ), 0) AS today_earnings,
                COALESCE(SUM(
                    CASE 
                        WHEN YEARWEEK(completed_at, 1) = YEARWEEK(CURDATE(), 1)
                        THEN agent_commission_amount 
                        ELSE 0 
                    END
                ), 0) AS week_earnings,
                COALESCE(SUM(
                    CASE 
                        WHEN YEAR(completed_at) = YEAR(CURDATE())
                         AND MONTH(completed_at) = MONTH(CURDATE())
                        THEN agent_commission_amount 
                        ELSE 0 
                    END
                ), 0) AS month_earnings
            FROM pickups
            WHERE agent_id = ?
              AND status = 'completed'
            `,
            [agentId]
        );

        const earnings = earningRows[0] || {
            total_earnings: 0,
            today_earnings: 0,
            week_earnings: 0,
            month_earnings: 0,
        };

        /* ------------------------------------------
           4) PICKUP SUMMARY (overall for this agent)
        ------------------------------------------ */
        const [summaryRows] = await pool.query(
            `
            SELECT
                COUNT(*) AS total_pickups,
                SUM(CASE WHEN status = 'pending'        THEN 1 ELSE 0 END) AS pending,
                SUM(CASE WHEN status = 'assigned'       THEN 1 ELSE 0 END) AS assigned,
                SUM(CASE WHEN status = 'rider_on_way'   THEN 1 ELSE 0 END) AS rider_on_way,
                SUM(CASE WHEN status = 'arrived'        THEN 1 ELSE 0 END) AS arrived,
                SUM(CASE WHEN status = 'weighing'       THEN 1 ELSE 0 END) AS weighing,
                SUM(CASE WHEN status = 'completed'      THEN 1 ELSE 0 END) AS completed,
                SUM(CASE WHEN status = 'cancelled'      THEN 1 ELSE 0 END) AS cancelled,

                COALESCE(SUM(net_payable_amount), 0)       AS total_net_payable,
                COALESCE(SUM(agent_commission_amount), 0)  AS total_agent_commission,
                COALESCE(SUM(rider_commission_amount), 0)  AS total_rider_commission,
                COALESCE(SUM(rider_collected_cash), 0)     AS total_rider_collected_cash,
                COALESCE(SUM(cash_paid_to_customer), 0)    AS total_cash_paid_to_customer,
                COALESCE(SUM(wallet_credit_amount), 0)     AS total_wallet_credit
            FROM pickups
            WHERE agent_id = ?
            `,
            [agentId]
        );

        const pickupSummary = summaryRows[0] || {
            total_pickups: 0,
            pending: 0,
            assigned: 0,
            rider_on_way: 0,
            arrived: 0,
            weighing: 0,
            completed: 0,
            cancelled: 0,
            total_net_payable: 0,
            total_agent_commission: 0,
            total_rider_commission: 0,
            total_rider_collected_cash: 0,
            total_cash_paid_to_customer: 0,
            total_wallet_credit: 0,
        };

        /* ------------------------------------------
           FINAL RESPONSE
        ------------------------------------------ */
        return res.json({
            success: true,
            data: {
                today_pickups: {
                    summary: todaySummary,
                    list: todayList,
                },
                rider_performance: riderStats,
                earnings,
                pickup_summary: pickupSummary,
            },
        });
    } catch (err) {
        next(err);
    }
}
