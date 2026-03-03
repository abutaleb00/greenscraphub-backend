import pool from "../config/db.js";
import ApiError from "../utils/ApiError.js";

/**
 * GET ADMIN DASHBOARD SUMMARY
 * Final logic: Includes System Pulse, Transactional KPIs, Analytics, and Performance Leaderboards.
 */
export const getAdminDashboard = async (req, res, next) => {
    try {
        /* ---------------------------------------------
           1) SYSTEM PULSE (Capacity & Live Status)
        --------------------------------------------- */
        const [userCounts] = await pool.query(`
            SELECT 
                (SELECT COUNT(*) FROM users) AS total_users,
                (SELECT COUNT(*) FROM customers) AS total_customers,
                (SELECT COUNT(*) FROM agents) AS total_agents,
                (SELECT COUNT(*) FROM riders) AS total_riders,
                (SELECT COUNT(*) FROM riders WHERE is_online = 1) AS riders_online
        `);

        /* ---------------------------------------------
           2) TRANSACTIONAL KPIs (Revenue & Volume)
        --------------------------------------------- */
        const [kpiRows] = await pool.query(`
            SELECT 
                COUNT(id) AS total_requests,
                SUM(CASE WHEN status='pending' THEN 1 ELSE 0 END) AS live_requests,
                SUM(CASE WHEN status='completed' THEN 1 ELSE 0 END) AS successful_pickups,
                COALESCE(SUM(net_payable_amount), 0) AS total_gmv,
                COALESCE(SUM(admin_commission_amount), 0) AS platform_revenue,
                (SELECT COALESCE(SUM(actual_weight), 0) FROM pickup_items) AS total_tonnage
            FROM pickups
        `);

        /* ---------------------------------------------
           3) LOGISTICS STREAM (Recent Activity)
        --------------------------------------------- */
        const [recentPickups] = await pool.query(`
            SELECT 
                p.id, p.booking_code, u.full_name as customer, 
                p.status, p.net_payable_amount, p.created_at
            FROM pickups p
            JOIN customers c ON p.customer_id = c.id
            JOIN users u ON c.user_id = u.id
            ORDER BY p.created_at DESC LIMIT 5
        `);

        /* ---------------------------------------------
           4) ANALYTICS (Revenue Trend & Category Mix)
        --------------------------------------------- */
        const [revenueTrend] = await pool.query(`
            SELECT 
                DATE_FORMAT(completed_at, '%b %Y') AS label,
                COALESCE(SUM(admin_commission_amount), 0) AS value
            FROM pickups
            WHERE status='completed' AND completed_at > DATE_SUB(NOW(), INTERVAL 6 MONTH)
            GROUP BY DATE_FORMAT(completed_at, '%Y-%m')
            ORDER BY completed_at ASC
        `);

        const [categoryMix] = await pool.query(`
            SELECT 
                cat.name_en AS category,
                SUM(pi.actual_weight) AS weight
            FROM pickup_items pi
            JOIN scrap_items si ON pi.item_id = si.id
            JOIN scrap_categories cat ON si.category_id = cat.id
            GROUP BY cat.id
            ORDER BY weight DESC
        `);

        /* ---------------------------------------------
           5) REGIONAL REPORT (Upazila Performance)
        --------------------------------------------- */
        const [geoPerformance] = await pool.query(`
            SELECT 
                upz.name_en AS upazila,
                COUNT(p.id) AS volume
            FROM pickups p
            JOIN upazilas upz ON p.upazila_id = upz.id
            GROUP BY upz.id
            ORDER BY volume DESC LIMIT 5
        `);

        /* ---------------------------------------------
           6) FINANCIAL RISKS (Audit & Liabilities)
        --------------------------------------------- */
        const [liability] = await pool.query(`
            SELECT 
                COALESCE(SUM(balance), 0) AS total_wallet_liability,
                (SELECT COUNT(*) FROM payout_requests WHERE status='pending') AS pending_payouts,
                (SELECT COUNT(*) FROM pickups WHERE status='completed' AND (rider_collected_cash > 0 AND cash_paid_to_customer = 0)) AS unsettled_cash
            FROM wallet_accounts
        `);

        /* ---------------------------------------------
           7) PERFORMANCE LEADERBOARDS (Fixed)
        --------------------------------------------- */

        // Top Agents by GMV
        const [topAgents] = await pool.query(`
    SELECT 
        ag.business_name,
        u.full_name AS owner_name,
        COUNT(p.id) AS total_pickups,
        COALESCE(SUM(p.net_payable_amount), 0) AS total_value
    FROM agents ag
    JOIN users u ON ag.owner_user_id = u.id
    LEFT JOIN pickups p ON ag.id = p.agent_id AND p.status = 'completed'
    GROUP BY ag.id
    ORDER BY total_value DESC LIMIT 5
`);

        // Top Riders by Tonnage
        const [topRiders] = await pool.query(`
    SELECT 
        u.full_name,
        r.vehicle_type,
        COUNT(p.id) AS delivery_count,
        (SELECT COALESCE(SUM(pi.actual_weight), 0) 
         FROM pickup_items pi 
         WHERE pi.pickup_id IN (SELECT id FROM pickups WHERE rider_id = r.id AND status = 'completed')
        ) AS total_kg
    FROM riders r
    JOIN users u ON r.user_id = u.id
    LEFT JOIN pickups p ON r.id = p.rider_id AND p.status = 'completed'
    GROUP BY r.id
    ORDER BY total_kg DESC LIMIT 5
`);

        // Top Regions by Volume
        const [topRegions] = await pool.query(`
    SELECT 
        upz.name_en AS upazila,
        COUNT(p.id) AS request_count,
        COALESCE(SUM(p.net_payable_amount), 0) AS revenue_generated
    FROM upazilas upz
    LEFT JOIN pickups p ON upz.id = p.upazila_id AND p.status = 'completed'
    GROUP BY upz.id
    ORDER BY request_count DESC LIMIT 5
`);

        /* ---------------------------------------------
           FINAL STRUCTURED RESPONSE
        --------------------------------------------- */
        res.json({
            success: true,
            data: {
                system_pulse: userCounts[0],
                kpis: kpiRows[0],
                live_feed: {
                    recent_pickups: recentPickups
                },
                charts: {
                    revenue_trend: revenueTrend,
                    category_mix: categoryMix,
                    geo_distribution: geoPerformance
                },
                leaderboards: {
                    agents: topAgents,
                    riders: topRiders,
                    regions: topRegions
                },
                financial_risks: {
                    total_wallet_liability: liability[0].total_wallet_liability,
                    pending_payouts: liability[0].pending_payouts,
                    unsettled_cash: liability[0].unsettled_cash
                },
                server_time: new Date()
            }
        });

    } catch (err) {
        next(err);
    }
};