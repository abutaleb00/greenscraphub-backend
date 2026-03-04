import db from '../../config/db.js';
import ApiError from '../../utils/ApiError.js';

/**
 * 1. GET AGENT RIDER FLEET
 * Logic: Fetch riders linked to agent, showing only UNSETTLED cash.
 */
export const getHubRiders = async (req, res, next) => {
    try {
        const userId = req.user.id;

        const [riders] = await db.query(`
            SELECT 
                r.id as rider_id, 
                u.full_name, 
                u.phone, 
                u.is_active,
                r.vehicle_type, 
                r.is_online,
                r.status as rider_status,
                -- Count active tasks accurately
                (SELECT COUNT(*) FROM pickups 
                 WHERE rider_id = r.id 
                 AND status NOT IN ('completed', 'cancelled')) as active_tasks,
                -- IMPORTANT: Only sum cash that hasn't been settled to the hub yet
                (SELECT COALESCE(SUM(rider_collected_cash), 0) 
                 FROM pickups 
                 WHERE rider_id = r.id 
                 AND status = 'completed' 
                 AND payment_method = 'cash'
                 AND is_settled_to_hub = 0) as cash_in_hand
            FROM riders r
            JOIN users u ON r.user_id = u.id
            JOIN agents a ON r.agent_id = a.id
            WHERE a.owner_user_id = ?`, [userId]);

        res.json({
            success: true,
            data: riders
        });
    } catch (err) {
        next(err);
    }
};

/**
 * 2. GET HUB COLLECTION LOGS (Detailed List)
 * Retrieves all pickup records associated with the Agent's specific Hub.
 */
export const getHubCollectionLogs = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const {
            status,
            search,
            startDate,
            endDate,
            page = 1,
            limit = 20
        } = req.query;

        const offset = (page - 1) * limit;
        let queryParams = [userId];

        // --- BASE QUERY ---
        let sql = `
            FROM pickups p
            JOIN agents a ON p.agent_id = a.id
            JOIN customers c ON p.customer_id = c.id
            JOIN users u ON c.user_id = u.id
            LEFT JOIN riders r ON p.rider_id = r.id
            LEFT JOIN users r_u ON r.user_id = r_u.id
            WHERE a.owner_user_id = ? `;

        // --- DYNAMIC FILTERS ---
        if (status && status !== 'all') {
            sql += ` AND p.status = ? `;
            queryParams.push(status);
        }

        if (search) {
            sql += ` AND (p.booking_code LIKE ? OR u.full_name LIKE ? OR u.phone LIKE ?) `;
            const searchVal = `%${search}%`;
            queryParams.push(searchVal, searchVal, searchVal);
        }

        if (startDate && endDate) {
            sql += ` AND DATE(p.created_at) BETWEEN ? AND ? `;
            queryParams.push(startDate, endDate);
        }

        // --- GET STATS FOR THE FILTERED VIEW ---
        const [stats] = await db.query(`
            SELECT 
                COUNT(*) as total_count,
                COALESCE(SUM(p.rider_collected_cash), 0) as total_cash,
                COALESCE(SUM(p.agent_commission_amount), 0) as total_comm
            ${sql}`, queryParams);

        // --- GET FINAL DATA WITH PAGINATION ---
        const finalSql = `
            SELECT 
                p.id, p.booking_code, p.status, p.scheduled_date, 
                p.scheduled_time_slot, p.net_payable_amount,
                p.rider_collected_cash, p.agent_commission_amount,
                u.full_name as customer_name, u.phone as customer_phone,
                r_u.full_name as rider_name, p.created_at
            ${sql}
            ORDER BY p.created_at DESC
            LIMIT ? OFFSET ?`;

        queryParams.push(parseInt(limit), parseInt(offset));

        const [pickups] = await db.query(finalSql, queryParams);

        res.json({
            success: true,
            data: pickups,
            meta: {
                total_records: stats[0].total_count,
                total_pages: Math.ceil(stats[0].total_count / limit),
                current_page: parseInt(page),
                filtered_cash_sum: stats[0].total_cash,
                filtered_commission_sum: stats[0].total_comm
            }
        });
    } catch (err) {
        next(err);
    }
};

/**
 * 3. GET HUB EARNINGS (Financial Audit)
 * Logic: Provides a daily breakdown of commissions and a high-level summary.
 */
export const getHubEarnings = async (req, res, next) => {
    try {
        const userId = req.user.id;

        // 1. Fetch Daily Breakdown
        // We use COALESCE to ensure we return 0 instead of NULL for sums
        const [earnings] = await db.query(`
            SELECT 
                DATE(p.completed_at) as date,
                COUNT(p.id) as pickups_done,
                COALESCE(SUM(p.agent_commission_amount), 0) as daily_commission,
                COALESCE(SUM(p.net_payable_amount), 0) as total_volume
            FROM pickups p
            JOIN agents a ON p.agent_id = a.id
            WHERE a.owner_user_id = ? 
              AND p.status = 'completed'
            GROUP BY DATE(p.completed_at)
            ORDER BY date DESC
            LIMIT 30`, [userId]);

        // 2. Fetch Lifetime/Monthly Summary for the Top HUD Cards
        const [summary] = await db.query(`
            SELECT 
                COALESCE(SUM(p.agent_commission_amount), 0) as total_lifetime_commission,
                COUNT(p.id) as total_lifetime_pickups,
                COALESCE(SUM(CASE WHEN MONTH(p.completed_at) = MONTH(CURRENT_DATE()) THEN p.agent_commission_amount ELSE 0 END), 0) as current_month_commission
            FROM pickups p
            JOIN agents a ON p.agent_id = a.id
            WHERE a.owner_user_id = ? 
              AND p.status = 'completed'`, [userId]);

        res.json({
            success: true,
            data: earnings,
            summary: summary[0] || {
                total_lifetime_commission: 0,
                total_lifetime_pickups: 0,
                current_month_commission: 0
            }
        });
    } catch (err) {
        next(err);
    }
};

/**
 * 4. GET RIDER PERFORMANCE AUDIT
 * Deep dive into a specific rider's efficiency and financial history
 */
export const getRiderAudit = async (req, res, next) => {
    try {
        const { rider_id } = req.params;
        const userId = req.user.id; // Agent's User ID

        // 1. Verify this rider belongs to this agent's hub (Security Check)
        const [agentHub] = await db.query(
            "SELECT id FROM agents WHERE owner_user_id = ?",
            [userId]
        );
        if (!agentHub.length) throw new ApiError(403, "Unauthorized hub access");

        // 2. Aggregate Performance Data
        // We join with the riders table to get the 'rating_avg' 
        // while calculating totals from the pickups table
        const [stats] = await db.query(`
            SELECT 
                r.rating_avg as avg_rating,
                COUNT(p.id) as total_assigned,
                SUM(CASE WHEN p.status = 'completed' THEN 1 ELSE 0 END) as total_completed,
                SUM(CASE WHEN p.status = 'cancelled' THEN 1 ELSE 0 END) as total_cancelled,
                COALESCE(SUM(p.rider_collected_cash), 0) as total_cash_collected
            FROM riders r
            LEFT JOIN pickups p ON r.id = p.rider_id
            WHERE r.id = ? AND r.agent_id = ?
            GROUP BY r.id`, [rider_id, agentHub[0].id]);

        if (!stats.length) {
            throw new ApiError(404, "Rider data not found for this hub");
        }

        // 3. Get Recent 5 Completed Jobs for the Audit Trail
        const [recentJobs] = await db.query(`
            SELECT booking_code, completed_at, net_payable_amount, rider_collected_cash
            FROM pickups 
            WHERE rider_id = ? AND status = 'completed'
            ORDER BY completed_at DESC LIMIT 5`, [rider_id]);

        res.json({
            success: true,
            data: {
                metrics: stats[0],
                recent_activity: recentJobs
            }
        });
    } catch (err) {
        next(err);
    }
};


const getAgentInfo = async (req) => {
    const userId = req.user.id; // Assumes your auth middleware attaches user to req
    const [agent] = await db.query(
        "SELECT id, owner_user_id FROM agents WHERE owner_user_id = ?",
        [userId]
    );
    if (!agent.length) throw new ApiError(403, "Agent profile not found.");
    return agent[0];
};

/**
 * GET PENDING SETTLEMENTS
 * Fetches riders who have collected physical cash but haven't paid the hub yet
 */
export const getPendingSettlements = async (req, res, next) => {
    try {
        const agent = await getAgentInfo(req);

        const [riders] = await db.query(`
            SELECT 
                r.id, 
                u.full_name as name, 
                SUM(p.rider_collected_cash) as pending_cash
            FROM riders r
            JOIN users u ON r.user_id = u.id
            JOIN pickups p ON r.id = p.rider_id
            WHERE p.agent_id = ? 
              AND p.status = 'completed' 
              AND p.payment_method = 'cash' 
              AND p.is_settled_to_hub = 0
            GROUP BY r.id, u.full_name
            HAVING pending_cash > 0`,
            [agent.id]
        );

        res.json({ success: true, data: riders });
    } catch (err) {
        next(err);
    }
};

/**
 * SETTLE RIDER CASH (Updated for Foreign Key Compliance)
 */
export const settleRiderCash = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        await conn.beginTransaction();
        const { riderId, amount, note } = req.body;
        const agent = await getAgentInfo(req);

        // 1. Fetch Agent's Wallet ID
        const [agentWallet] = await conn.query(
            "SELECT id FROM wallet_accounts WHERE user_id = ?",
            [agent.owner_user_id]
        );
        if (!agentWallet.length) throw new ApiError(404, "Agent wallet not found.");
        const walletId = agentWallet[0].id;

        // 2. Create a "Cash Intake" Transaction record to satisfy FK constraint
        // This logs the event in wallet_transactions without necessarily changing the digital balance
        const [txResult] = await conn.query(`
            INSERT INTO wallet_transactions 
            (wallet_id, type, source, reference_type, reference_id, amount, balance_before, balance_after, description_en, status) 
            VALUES (?, 'credit', 'cash_settlement', 'rider', ?, ?, 0, 0, ?, 'completed')`,
            [
                walletId,
                riderId,
                amount,
                `Physical cash intake from Rider ID: ${riderId}`
            ]
        );
        const transactionId = txResult.insertId;

        // 3. Mark pickups as settled to hub
        await conn.query(`
            UPDATE pickups 
            SET is_settled_to_hub = 1 
            WHERE rider_id = ? AND agent_id = ? 
              AND status = 'completed' AND is_settled_to_hub = 0`,
            [riderId, agent.id]
        );

        // 4. Log into Financial Ledger using the NEW transaction_id
        await conn.query(`
            INSERT INTO financial_ledger 
            (wallet_id, transaction_id, source_type, source_id, credit, debit, entry_type, payment_method, description) 
            VALUES (?, ?, 'cash_settlement', ?, ?, 0, 'inflow', 'cash', ?)`,
            [
                walletId,
                transactionId, // Satisfies financial_ledger_ibfk_2
                riderId,
                amount,
                `Cash intake verified: ${note || 'Daily Settle'}`
            ]
        );

        await conn.commit();
        res.json({ success: true, message: "Cash successfully reconciled into Hub Vault." });
    } catch (err) {
        await conn.rollback();
        console.error("Settlement Error:", err);
        next(err);
    } finally {
        conn.release();
    }
};

export const getDispatchConsole = async (req, res, next) => {
    try {
        // DEBUG: Check if agent_id exists. If not, we might need to fetch it from the database first
        let agentId = req.user.agent_id;

        if (!agentId) {
            // Fallback: If middleware didn't attach agent_id, find it via the logged-in userId
            const [agentRecord] = await db.query(
                "SELECT id FROM agents WHERE owner_user_id = ?",
                [req.user.id]
            );
            if (!agentRecord.length) throw new ApiError(404, "Agent Profile Not Found");
            agentId = agentRecord[0].id;
        }

        console.log(`[Dispatch] Fetching console for Agent ID: ${agentId}`);

        // 1. Fetch Unassigned (Pending) Pickups
        const [queue] = await db.query(`
            SELECT 
                p.id, p.booking_code, p.status, p.scheduled_date, 
                p.scheduled_time_slot, u.full_name as customer_name,
                addr.address_line
            FROM pickups p
            JOIN customers c ON p.customer_id = c.id
            JOIN users u ON c.user_id = u.id
            LEFT JOIN addresses addr ON p.customer_address_id = addr.id
            WHERE p.agent_id = ? 
              AND p.status = 'pending' 
              AND p.is_deleted = 0
            ORDER BY p.created_at DESC`, [agentId]);

        // 2. Fetch Active Missions
        const [active] = await db.query(`
            SELECT 
                p.id, p.booking_code, p.status, 
                ur.full_name as rider_name
            FROM pickups p
            INNER JOIN riders r ON p.rider_id = r.id
            INNER JOIN users ur ON r.user_id = ur.id
            WHERE p.agent_id = ? 
              AND p.status IN ('assigned', 'rider_on_way', 'arrived', 'weighing')
              AND p.is_deleted = 0`, [agentId]);

        // 3. Fetch Fleet
        const [fleet] = await db.query(`
            SELECT 
                r.id, u.full_name as name, r.is_online, r.vehicle_type,
                (SELECT COUNT(*) FROM pickups WHERE rider_id = r.id AND status IN ('assigned', 'rider_on_way', 'arrived', 'weighing')) as active_tasks
            FROM riders r
            JOIN users u ON r.user_id = u.id
            WHERE r.agent_id = ?`, [agentId]);

        res.json({
            success: true,
            data: {
                queue,
                active_missions: active,
                fleet
            }
        });
    } catch (err) {
        console.error("Dispatch Console Error:", err);
        next(err);
    }
};

export const getAgentMissionDetail = async (req, res, next) => {
    try {
        const { id } = req.params;
        const userId = req.user.id;

        // 1. Identify the Agent (Resolves the 'undefined' agent_id issue)
        const [agentRows] = await db.query(
            "SELECT id FROM agents WHERE owner_user_id = ?",
            [userId]
        );

        if (!agentRows.length) {
            throw new ApiError(403, "Access Denied: Agent profile not found.");
        }

        const agentId = agentRows[0].id;

        // 2. Fetch Pickup details
        const [pickupRows] = await db.query(`
            SELECT p.*, ur.full_name as rider_name, ur.phone as rider_phone,
                   u.full_name as customer_name, u.phone as customer_phone,
                   addr.address_line, addr.latitude, addr.longitude
            FROM pickups p
            LEFT JOIN riders r ON p.rider_id = r.id
            LEFT JOIN users ur ON r.user_id = ur.id
            JOIN customers c ON p.customer_id = c.id
            JOIN users u ON c.user_id = u.id
            LEFT JOIN addresses addr ON p.customer_address_id = addr.id
            WHERE p.id = ? AND p.agent_id = ?`, [id, agentId]);

        if (!pickupRows.length) throw new ApiError(404, "Mission not found.");

        const task = pickupRows[0];

        // 3. Fetch Items & Transform Images
        const [items] = await db.query(`
            SELECT pi.*, si.name_en, si.unit, si.image_url as product_image, pi.photo_url as user_uploaded_photo
            FROM pickup_items pi
            JOIN scrap_items si ON pi.item_id = si.id
            WHERE pi.pickup_id = ?`, [id]);

        const getFullUrl = (path) => {
            if (!path) return null;
            if (path.startsWith('http')) return path;
            const baseUrl = process.env.BASE_URL || 'http://localhost:4000';
            return `${baseUrl}/${path.replace(/^\//, '')}`;
        };

        const transformedItems = items.map(item => {
            let photosArray = [];
            try { photosArray = item.user_uploaded_photo ? JSON.parse(item.user_uploaded_photo) : []; }
            catch (e) { photosArray = []; }
            return {
                ...item,
                user_photos: photosArray.map(p => getFullUrl(p)),
                thumbnail: photosArray.length > 0 ? getFullUrl(photosArray[0]) : getFullUrl(item.product_image)
            };
        });

        // 4. FETCH FROM YOUR EXISTING pickup_timeline TABLE
        const [timeline] = await db.query(
            "SELECT * FROM pickup_timeline WHERE pickup_id = ? ORDER BY created_at DESC",
            [id]
        );

        res.json({
            success: true,
            data: {
                pickup: task,
                items: transformedItems,
                timeline: timeline // This now pulls from your correct table
            }
        });

    } catch (err) {
        next(err);
    }
};