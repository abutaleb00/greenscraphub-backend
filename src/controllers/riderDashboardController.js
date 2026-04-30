import db from "../config/db.js";
import ApiError from "../utils/ApiError.js";

export async function getRiderDashboard(req, res, next) {
    try {
        // Use your working helper to get riderId
        const rider = await getRiderInfo(req);
        const riderId = rider.id;
        const userId = req.user.id;

        // 1. Fetch Active Missions (Using EXACT logic from getMyTasks)
        const [tasks] = await db.query(`
            SELECT 
                p.id, p.booking_code, p.status, p.scheduled_date, 
                p.scheduled_time_slot,
                u.full_name as customer_name, u.phone as customer_phone,
                addr.address_line, addr.house_no, addr.road_no, addr.landmark,
                addr.latitude, addr.longitude
            FROM pickups p
            JOIN customers c ON p.customer_id = c.id
            JOIN users u ON c.user_id = u.id
            LEFT JOIN addresses addr ON p.customer_address_id = addr.id
            WHERE p.rider_id = ? 
              AND p.status NOT IN ('completed', 'cancelled')
              AND p.is_deleted = 0
            ORDER BY 
                CASE 
                    WHEN p.status = 'weighing' THEN 1
                    WHEN p.status = 'arrived' THEN 2
                    WHEN p.status = 'rider_on_way' THEN 3
                    ELSE 4 
                END ASC, 
                p.scheduled_date ASC`, [riderId]);

        // 2. Performance Stats (Today & Month)
        const [stats] = await db.query(`
            SELECT
                COUNT(CASE WHEN DATE(completed_at) = CURDATE() THEN 1 END) AS count_today,
                COUNT(CASE WHEN MONTH(completed_at) = MONTH(CURDATE()) AND YEAR(completed_at) = YEAR(CURDATE()) THEN 1 END) AS count_month,
                COALESCE(SUM(CASE WHEN DATE(completed_at) = CURDATE() THEN rider_commission_amount ELSE 0 END), 0) AS earn_today,
                COALESCE(SUM(CASE WHEN MONTH(completed_at) = MONTH(CURDATE()) AND YEAR(completed_at) = YEAR(CURDATE()) THEN rider_commission_amount ELSE 0 END), 0) AS earn_month,
                COALESCE(SUM(CASE WHEN is_settled_to_hub = 0 AND status = 'completed' THEN rider_collected_cash ELSE 0 END), 0) AS cash_liability
            FROM pickups
            WHERE rider_id = ?`, [riderId]);

        // 3. Wallet Balance
        const [wallet] = await db.query("SELECT balance FROM wallet_accounts WHERE user_id = ?", [userId]);

        // 4. Format Missions for Frontend
        const active_missions = tasks.map(task => {
            const addressParts = [];
            if (task.house_no) addressParts.push(`H# ${task.house_no}`);
            if (task.road_no) addressParts.push(`R# ${task.road_no}`);
            if (task.address_line) addressParts.push(task.address_line);

            return {
                id: task.id,
                ref: task.booking_code,
                status: task.status,
                customer: { name: task.customer_name, phone: task.customer_phone },
                location: {
                    address: addressParts.join(', ') || "Address N/A",
                    coords: { lat: task.latitude, lng: task.longitude }
                },
                schedule: task.scheduled_time_slot
            };
        });

        // 5. Final Response
        return res.json({
            success: true,
            data: {
                profile: {
                    name: req.user.full_name,
                    avatar: req.user.profile_image || null,
                    is_online: Boolean(rider.is_online)
                },
                financials: {
                    withdrawable_balance: parseFloat(wallet[0]?.balance || 0).toFixed(2),
                    cash_held_liability: parseFloat(stats[0].cash_liability || 0).toFixed(2),
                    currency: "BDT"
                },
                performance: {
                    today: {
                        trips: stats[0].count_today || 0,
                        income: parseFloat(stats[0].earn_today || 0).toFixed(2)
                    },
                    monthly: {
                        trips: stats[0].count_month || 0,
                        income: parseFloat(stats[0].earn_month || 0).toFixed(2)
                    }
                },
                active_missions: active_missions
            }
        });

    } catch (err) {
        next(err);
    }
}