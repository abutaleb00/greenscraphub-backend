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
                u.email,
                u.is_active,
                r.vehicle_type, 
                r.vehicle_number,
                r.is_online,
                r.status as rider_status,
                r.payment_mode, -- Critical for the UI icons
                a.default_rider_mode as hub_default_mode, -- For the 'default' fallback text
                
                -- 1. Active Task Count (Current Workload)
                (SELECT COUNT(*) FROM pickups 
                 WHERE rider_id = r.id 
                 AND status IN ('assigned', 'rider_on_way', 'arrived', 'weighing')) as active_tasks,
                
                -- 2. Accountability (Physical cash held by rider)
                (SELECT COALESCE(SUM(rider_collected_cash), 0) 
                 FROM pickups 
                 WHERE rider_id = r.id 
                 AND status = 'completed' 
                 AND payment_method = 'cash'
                 AND is_settled_to_hub = 0) as cash_in_hand,

                -- 3. Last Activity (To show how recently they worked)
                (SELECT MAX(completed_at) 
                 FROM pickups 
                 WHERE rider_id = r.id) as last_completed_at,

                -- 4. Today's Performance (Instant audit)
                (SELECT COUNT(*) 
                 FROM pickups 
                 WHERE rider_id = r.id 
                 AND status = 'completed' 
                 AND DATE(completed_at) = CURDATE()) as jobs_today

            FROM riders r
            JOIN users u ON r.user_id = u.id
            JOIN agents a ON r.agent_id = a.id
            WHERE a.owner_user_id = ? 
            AND u.role_id = 3 -- Safety check for riders
            ORDER BY r.is_online DESC, u.full_name ASC`, [userId]);

        // Transform data slightly for cleaner Frontend consumption
        const formattedRiders = riders.map(rider => ({
            ...rider,
            cash_in_hand: parseFloat(rider.cash_in_hand || 0).toFixed(2),
            // Determine active payment mode for the UI badge
            resolved_payment_mode: rider.payment_mode === 'default' ? rider.hub_default_mode : rider.payment_mode
        }));

        res.json({
            success: true,
            data: formattedRiders
        });
    } catch (err) {
        console.error("Hub Riders API Error:", err);
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
 * GET HUB EARNINGS (Financial Analytics)
 * Updated Logic: Calculates Net Profit, Platform Fees, and Volume Breakdown
 */
export const getHubEarnings = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const [agentRows] = await db.query("SELECT id FROM agents WHERE owner_user_id = ?", [userId]);
        const agentId = agentRows[0].id;

        const [stats] = await db.query(`
            SELECT 
                -- 1. Money already in the Hub safe (Verified)
                COALESCE(SUM(CASE WHEN is_settled_to_hub = 1 THEN rider_collected_cash ELSE 0 END), 0) as verified_cash_vault,
                
                -- 2. Money still with Riders (Unverified/Receivable)
                COALESCE(SUM(CASE WHEN is_settled_to_hub = 0 THEN rider_collected_cash ELSE 0 END), 0) as floating_rider_cash,
                
                -- 3. Total Operating Margin (Potential Profit across all missions)
                COALESCE(SUM(agent_commission_amount), 0) as total_operating_margin,
                
                -- 4. Total Platform Debt (Money owed to you, the owner)
                COALESCE(SUM(platform_fee_amount), 0) as platform_debt
            FROM pickups 
            WHERE agent_id = ? AND status = 'completed' AND is_deleted = 0`, [agentId]);

        res.json({
            success: true,
            stats: {
                cash_in_vault: parseFloat(stats[0].verified_cash_vault).toFixed(2),
                floating_cash: parseFloat(stats[0].floating_rider_cash).toFixed(2),
                total_assets: (parseFloat(stats[0].verified_cash_vault) + parseFloat(stats[0].floating_rider_cash)).toFixed(2),
                operating_margin: parseFloat(stats[0].total_operating_margin).toFixed(2),
                platform_debt: parseFloat(stats[0].platform_debt).toFixed(2)
            }
        });
    } catch (err) { next(err); }
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
 * Updated logic: Fetches detailed rider liability metadata for Agent verification.
 */
export const getPendingSettlements = async (req, res, next) => {
    try {
        // 1. Get Agent identity from session
        const [agentRows] = await db.query(
            "SELECT id FROM agents WHERE owner_user_id = ?",
            [req.user.id]
        );

        if (!agentRows.length) throw new ApiError(403, "Agent profile not active.");
        const agentId = agentRows[0].id;

        // 2. Query riders with unsettled cash liability
        const [riders] = await db.query(`
            SELECT 
                r.id as rider_id, 
                u.full_name as name, 
                u.phone,
                r.vehicle_type,
                r.vehicle_number,
                -- Total physical cash the rider is carrying
                COALESCE(SUM(p.rider_collected_cash), 0) as pending_cash,
                -- Count of individual pickups making up this amount
                COUNT(p.id) as pickup_count,
                -- Total platform fee the agent will owe the system for these jobs
                COALESCE(SUM(p.platform_fee_amount), 0) as total_platform_fee,
                -- Last collection timestamp
                MAX(p.completed_at) as last_collection
            FROM riders r
            JOIN users u ON r.user_id = u.id
            JOIN pickups p ON r.id = p.rider_id
            WHERE p.agent_id = ? 
              AND p.status = 'completed' 
              AND p.payment_method = 'cash' 
              AND p.is_settled_to_hub = 0
            GROUP BY r.id, u.full_name, u.phone, r.vehicle_type, r.vehicle_number
            HAVING pending_cash > 0
            ORDER BY last_collection DESC`,
            [agentId]
        );

        // 3. Optional: Fetch individual pickup breakdown for a "Details" view if needed
        // This makes the UI much more realistic.
        const formattedData = riders.map(rider => ({
            ...rider,
            pending_cash: parseFloat(rider.pending_cash).toFixed(2),
            total_platform_fee: parseFloat(rider.total_platform_fee).toFixed(2),
        }));

        res.json({
            success: true,
            count: formattedData.length,
            data: formattedData
        });
    } catch (err) {
        console.error("Settlement Query Error:", err);
        next(err);
    }
};

/**
 * GET SETTLEMENT LOGS (AGENT)
 * Fetches historical cash handovers and income stats
 */
export const getSettlementLogs = async (req, res, next) => {
    try {
        const [agentRows] = await db.query(
            "SELECT id FROM agents WHERE owner_user_id = ?",
            [req.user.id]
        );
        if (!agentRows.length) throw new ApiError(403, "Agent not found.");
        const agentId = agentRows[0].id;

        // 1. Fetch historical completed pickups that were settled
        const [logs] = await db.query(`
            SELECT 
                p.id,
                p.booking_code,
                p.completed_at as date,
                u.full_name as rider_name,
                p.rider_collected_cash as collection_amount,
                p.rider_commission_amount as rider_incentive,
                p.platform_fee_amount as platform_fee,
                -- Agent Net = Collection - Rider Cut - Platform Cut
                (p.rider_collected_cash - p.rider_commission_amount - p.platform_fee_amount) as agent_net_income
            FROM pickups p
            JOIN riders r ON p.rider_id = r.id
            JOIN users u ON r.user_id = u.id
            WHERE p.agent_id = ? 
              AND p.is_settled_to_hub = 1
              AND p.status = 'completed'
            ORDER BY p.completed_at DESC
            LIMIT 50`, [agentId]);

        // 2. Summary Stats for the Agent
        const [stats] = await db.query(`
            SELECT 
                SUM(rider_collected_cash) as lifetime_collection,
                SUM(platform_fee_amount) as total_platform_debt,
                COUNT(id) as total_settled_jobs
            FROM pickups 
            WHERE agent_id = ? AND is_settled_to_hub = 1`, [agentId]);

        res.json({
            success: true,
            stats: {
                total_collected: parseFloat(stats[0].lifetime_collection || 0).toFixed(2),
                platform_debt: parseFloat(stats[0].total_platform_debt || 0).toFixed(2),
                job_count: stats[0].total_settled_jobs || 0
            },
            data: logs.map(log => ({
                ...log,
                collection_amount: parseFloat(log.collection_amount).toFixed(2),
                agent_net_income: parseFloat(log.agent_net_income).toFixed(2)
            }))
        });
    } catch (err) { next(err); }
};
/**
 * SETTLE RIDER CASH (Updated for Foreign Key Compliance)
 */
export const settleRiderCash = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        await conn.beginTransaction();

        const { riderId, amount, note } = req.body;
        const intakeAmount = parseFloat(amount);

        if (isNaN(intakeAmount) || intakeAmount < 0) {
            throw new ApiError(400, "Invalid intake amount.");
        }

        const agent = await getAgentInfo(req);
        const agentId = agent.id;

        // 1. Fetch Agent's Wallet
        const [agentWallet] = await conn.query(
            "SELECT id FROM wallet_accounts WHERE user_id = ?",
            [agent.owner_user_id]
        );
        if (!agentWallet.length) throw new ApiError(404, "Agent wallet not found.");
        const walletId = agentWallet[0].id;

        // 2. Fetch ALL pickups that have NOT been stocked yet (is_settled_to_hub = 0)
        // We do this because you want the items in the warehouse immediately.
        const [pendingPickups] = await conn.query(`
            SELECT id FROM pickups 
            WHERE rider_id = ? AND agent_id = ? 
              AND status = 'completed' AND is_settled_to_hub = 0`,
            [riderId, agentId]
        );

        if (pendingPickups.length > 0) {
            const pendingIds = pendingPickups.map(p => p.id);

            // 3. LOGIC: UPDATE HUB INVENTORY (STOCK STORE)
            // Fetch all items from these specific pickups
            const [itemsToStock] = await conn.query(`
    SELECT item_id, actual_weight 
    FROM pickup_items 
    WHERE pickup_id IN (?)`, [settledPickupIds]);

            for (const item of itemsToStock) {
                const weight = parseFloat(item.actual_weight);
                if (weight <= 0) continue;

                await conn.query(`
        INSERT INTO hub_inventory (agent_id, category_id, current_weight)
        VALUES (?, ?, ?)
        ON DUPLICATE KEY UPDATE 
            current_weight = current_weight + ?,
            last_updated_at = NOW()`,
                    [agentId, item.item_id, weight, weight]
                );
            }

            // 4. Mark these pickups as settled to hub so inventory isn't double-counted later
            await conn.query(
                `UPDATE pickups SET is_settled_to_hub = 1 WHERE id IN (?)`,
                [pendingIds]
            );
        }

        // 5. FINANCE: Log the Cash Transaction
        // We log the amount the rider actually paid. 
        // The "Pending Balance" is calculated in your 'getPendingSettlements' query 
        // by comparing (Total Rider Collected Cash) vs (Total Wallet Transactions for that rider).
        const [txResult] = await conn.query(`
            INSERT INTO wallet_transactions 
            (wallet_id, type, source, reference_type, reference_id, amount, balance_before, balance_after, description_en, status) 
            VALUES (?, 'credit', 'cash_settlement', 'rider', ?, ?, 0, 0, ?, 'completed')`,
            [
                walletId, riderId, intakeAmount,
                `Physical cash handover from Rider ID: ${riderId}. Note: ${note || 'Partial/Full'}`
            ]
        );

        // 6. Update Financial Ledger for Audit
        await conn.query(`
            INSERT INTO financial_ledger 
            (wallet_id, transaction_id, source_type, source_id, credit, debit, entry_type, payment_method, description) 
            VALUES (?, ?, 'cash_settlement', ?, ?, 0, 'inflow', 'cash', ?)`,
            [
                walletId, txResult.insertId, riderId, intakeAmount,
                `Hub Vault Intake: ${note || 'Handover'}`
            ]
        );

        await conn.commit();

        res.json({
            success: true,
            message: `Inventory updated for all items. ৳${intakeAmount} cash received and logged.`
        });

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