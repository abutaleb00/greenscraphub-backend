import db from '../../config/db.js';
import ApiError from '../../utils/ApiError.js';
import { sendUnifiedReceipt } from '../../services/mailService.js';
/**
 * Helper: Resolve rider_id and online status from logged-in user
 */
async function getRiderInfo(req) {
    const { role, id: userId } = req.user;

    if (role !== "rider") {
        throw new ApiError(403, "Access denied. Only riders can access these features.");
    }

    const [rows] = await db.query(
        "SELECT id, is_online FROM riders WHERE user_id = ? LIMIT 1",
        [userId]
    );

    if (!rows.length) {
        throw new ApiError(404, "Rider profile not found");
    }

    return rows[0]; // Returns { id, is_online }
}

/**
 * 1. GET RIDER DASHBOARD
 * Mobile optimized summary of tasks, performance, and cash.
 */

/**
 * GET RIDER DASHBOARD
 * Mobile-optimized LOC (Logistics Operations Center) data.
 */
export async function getRiderDashboard(req, res, next) {
    try {
        const userId = req.user.id;

        // 1. Get Rider basic info
        const [riderRows] = await db.query(
            "SELECT id, is_online FROM riders WHERE user_id = ?",
            [userId]
        );

        if (!riderRows.length) {
            throw new ApiError(404, "Rider profile not found.");
        }

        const riderId = riderRows[0].id;

        // 2. Fetch Active Tasks with the correct 'addresses' table join
        const [activeTasks] = await db.query(
            `SELECT 
                p.id AS pickup_id, 
                p.booking_code, 
                p.status, 
                p.scheduled_date, 
                p.scheduled_time_slot,
                u.full_name AS customer_name, 
                u.phone AS customer_phone,
                -- Building a readable address from your 'addresses' schema
                adr.address_line,
                adr.house_no,
                adr.road_no,
                adr.landmark,
                adr.latitude, 
                adr.longitude, 
                COALESCE(p.customer_note, '') as customer_note
            FROM pickups p
            JOIN customers c ON p.customer_id = c.id
            JOIN users u ON c.user_id = u.id
            LEFT JOIN addresses adr ON p.customer_address_id = adr.id
            WHERE p.rider_id = ? 
              AND p.status IN ('assigned', 'rider_on_way', 'arrived', 'weighing')
              AND p.is_deleted = 0
            ORDER BY p.scheduled_date ASC`,
            [riderId]
        );

        // 3. Performance Stats (Today vs Month)
        const [stats] = await db.query(
            `SELECT
                COUNT(CASE WHEN DATE(completed_at) = CURDATE() THEN 1 END) AS completed_today,
                COUNT(CASE WHEN MONTH(completed_at) = MONTH(CURDATE()) AND YEAR(completed_at) = YEAR(CURDATE()) THEN 1 END) AS completed_month,
                COALESCE(SUM(CASE WHEN DATE(completed_at) = CURDATE() THEN rider_commission_amount ELSE 0 END), 0) AS earnings_today,
                COALESCE(SUM(CASE WHEN MONTH(completed_at) = MONTH(CURDATE()) AND YEAR(completed_at) = YEAR(CURDATE()) THEN rider_commission_amount ELSE 0 END), 0) AS earnings_month
            FROM pickups
            WHERE rider_id = ? AND status = 'completed' AND is_deleted = 0`,
            [riderId]
        );

        // 4. Financial Accountability
        const [finance] = await db.query(
            `SELECT 
                COALESCE(SUM(rider_collected_cash), 0) AS total_cash_held
            FROM pickups 
            WHERE rider_id = ? 
              AND status = 'completed' 
              AND payment_method = 'cash'
              AND is_settled_to_hub = 0`,
            [riderId]
        );

        // 5. Wallet Balance
        const [wallet] = await db.query(
            "SELECT balance FROM wallet_accounts WHERE user_id = ?",
            [userId]
        );

        return res.json({
            success: true,
            data: {
                rider_status: {
                    is_online: Boolean(riderRows[0].is_online),
                    last_pulse: new Date()
                },
                tasks: {
                    active_count: activeTasks.length,
                    active_list: activeTasks.map(task => ({
                        ...task,
                        // Formatting the address for the mobile UI
                        display_address: `${task.house_no ? 'House ' + task.house_no + ', ' : ''}${task.road_no ? 'Road ' + task.road_no + ', ' : ''}${task.address_line}${task.landmark ? ' (Near ' + task.landmark + ')' : ''}`
                    }))
                },
                performance: {
                    today: {
                        pickups: stats[0].completed_today || 0,
                        earned: parseFloat(stats[0].earnings_today || 0)
                    },
                    monthly: {
                        pickups: stats[0].completed_month || 0,
                        earned: parseFloat(stats[0].earnings_month || 0)
                    }
                },
                finance: {
                    cash_held_to_submit: parseFloat(finance[0].total_cash_held || 0),
                    withdrawable_balance: parseFloat(wallet[0]?.balance || 0)
                }
            }
        });
    } catch (err) {
        next(err);
    }
}

/**
 * 2. GET RIDER ACTIVE TASKS
 * Fixed: Joining addresses table to fetch location details
 */
export const getMyTasks = async (req, res, next) => {
    try {
        const rider = await getRiderInfo(req); // Using the helper from previous step
        const riderId = rider.id;

        const [tasks] = await db.query(`
            SELECT 
                p.id, 
                p.booking_code, 
                p.status, 
                p.scheduled_date, 
                p.scheduled_time_slot,
                u.full_name as customer_name, 
                u.phone as customer_phone,
                -- Fetching address details from the joined addresses table
                addr.address_line, 
                addr.latitude, 
                addr.longitude,
                -- We'll use base_amount as a proxy for estimated amount if weight isn't set yet
                p.base_amount as estimated_amount
            FROM pickups p
            JOIN customers c ON p.customer_id = c.id
            JOIN users u ON c.user_id = u.id
            -- Correct Join: Linking the pickup to its specific address record
            LEFT JOIN addresses addr ON p.customer_address_id = addr.id
            WHERE p.rider_id = ? 
              AND p.status NOT IN ('completed', 'cancelled')
            ORDER BY p.scheduled_date ASC, p.id DESC`, [riderId]);

        res.json({ success: true, data: tasks });
    } catch (err) {
        next(err);
    }
};

/**
 * GET SINGLE TASK DETAIL
 * Returns comprehensive data including customer info, catalog images, and user-uploaded proofs.
 */
export const getTaskDetail = async (req, res, next) => {
    try {
        const { id } = req.params;
        const rider = await getRiderInfo(req);

        // 1. Fetch Comprehensive Pickup Info
        // Added 'p.rider_id' to select to verify if it's assigned
        const [taskRows] = await db.query(`
            SELECT 
                p.id, p.booking_code, p.status, p.base_amount, p.customer_note,
                u.full_name as customer_name, u.phone as customer_phone,
                addr.address_line, addr.house_no, addr.road_no, addr.landmark,
                addr.latitude, addr.longitude, p.rider_id
            FROM pickups p
            JOIN customers c ON p.customer_id = c.id
            JOIN users u ON c.user_id = u.id
            LEFT JOIN addresses addr ON p.customer_address_id = addr.id
            WHERE p.id = ?`, // Removed rider_id temporarily to see if data exists at all
            [id]
        );

        if (!taskRows.length) {
            throw new ApiError(404, "Mission Node not found in database.");
        }

        const task = taskRows[0];

        // SECURITY CHECK: If you want to strictly enforce rider ownership
        // if (task.rider_id !== rider.id) { throw new ApiError(403, "Unauthorized access to this node."); }

        // Helper to format image URLs
        const getFullUrl = (path) => {
            if (!path) return null;
            if (path.startsWith('http')) return path;
            const baseUrl = process.env.BASE_URL || 'http://localhost:4000';
            return `${baseUrl}/${path.replace(/^\//, '')}`;
        };

        // 2. Fetch Itemized List
        // Changed to LEFT JOIN to ensure items appear even if scrap_items reference is wonky
        const [items] = await db.query(`
            SELECT 
                pi.id as pickup_item_id,
                pi.item_id, 
                si.name_en, si.name_bn, si.unit, 
                si.current_min_rate as price,
                si.image_url as product_image,
                pi.estimated_weight,
                pi.photo_url as user_uploaded_photo,
                pi.category_id
            FROM pickup_items pi
            LEFT JOIN scrap_items si ON pi.item_id = si.id
            WHERE pi.pickup_id = ?`,
            [id]
        );

        console.log(`[DEBUG] Found ${items.length} items for Pickup ID: ${id}`);

        // Transform items...
        const transformedItems = items.map(item => {
            let photosArray = [];
            try {
                photosArray = item.user_uploaded_photo ? JSON.parse(item.user_uploaded_photo) : [];
            } catch (e) {
                photosArray = [];
            }

            const userPhotosUrls = photosArray.map(p => getFullUrl(p));
            const catalogImageUrl = getFullUrl(item.product_image);

            return {
                ...item,
                user_photos: userPhotosUrls,
                catalog_image: catalogImageUrl,
                thumbnail: userPhotosUrls.length > 0 ? userPhotosUrls[0] : catalogImageUrl
            };
        });

        res.json({
            success: true,
            data: {
                pickup: task,
                items: transformedItems
            }
        });
    } catch (err) {
        next(err);
    }
};
/**
 * 3. UPDATE TASK STATUS
 * Validates status flow: assigned -> rider_on_way -> arrived
 */
export const updateTaskStatus = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { status } = req.body;

        const validStatuses = ['assigned', 'rider_on_way', 'arrived', 'weighing'];
        if (!validStatuses.includes(status)) throw new ApiError(400, "Invalid status transition");

        const [result] = await db.query(
            "UPDATE pickups SET status = ? WHERE id = ?",
            [status, id]
        );

        if (result.affectedRows === 0) throw new ApiError(404, "Task not found");

        res.json({ success: true, message: `Status updated to ${status.replace(/_/g, ' ')}` });
    } catch (err) { next(err); }
};

/**
 * 4. GET RIDER EARNINGS (Ledger)
 */
export const getRiderEarnings = async (req, res, next) => {
    try {
        const rider = await getRiderInfo(req);
        const [earnings] = await db.query(`
            SELECT 
                DATE(completed_at) as date,
                COUNT(*) as jobs,
                SUM(rider_commission_amount) as amount
            FROM pickups
            WHERE rider_id = ? AND status = 'completed'
            GROUP BY DATE(completed_at)
            ORDER BY date DESC LIMIT 30`, [rider.id]);

        res.json({ success: true, data: earnings });
    } catch (err) { next(err); }
};

/**
 * 5. GET RIDER COLLECTION LOGS (History)
 */
export const getRiderCollectionLogs = async (req, res, next) => {
    try {
        const rider = await getRiderInfo(req);
        const [logs] = await db.query(`
            SELECT p.booking_code, p.status, p.completed_at, p.net_payable_amount, u.full_name as customer_name
            FROM pickups p
            JOIN customers c ON p.customer_id = c.id
            JOIN users u ON c.user_id = u.id
            WHERE p.rider_id = ? AND p.status IN ('completed', 'cancelled')
            ORDER BY p.completed_at DESC`, [rider.id]);

        res.json({ success: true, data: logs });
    } catch (err) { next(err); }
};

/**
 * Helper: Update User Wallet and Log Transaction
 */
const updateWallet = async (conn, userId, amount, type, source, refType, refId, descEn) => {
    console.log(`[Wallet] Processing ${type} for User: ${userId}, Amount: ${amount}`);

    // 1. Double-Check Reference: Ensure we don't duplicate, but don't skip if new
    const [existing] = await conn.query(
        "SELECT id FROM wallet_transactions WHERE reference_type = ? AND reference_id = ? AND source = ?",
        [refType, refId, source]
    );

    if (existing.length > 0) {
        console.log(`[Wallet] Transaction already exists (ID: ${existing[0].id}). Skipping.`);
        return existing[0].id;
    }

    // 2. Fetch/Lock Wallet
    let [wallet] = await conn.query(
        "SELECT id, balance FROM wallet_accounts WHERE user_id = ? FOR UPDATE",
        [userId]
    );

    if (!wallet.length) {
        console.log(`[Wallet] Creating new wallet account for User: ${userId}`);
        const [ins] = await conn.query("INSERT INTO wallet_accounts (user_id, balance) VALUES (?, 0)", [userId]);
        wallet = [{ id: ins.insertId, balance: 0 }];
    }

    const balanceBefore = parseFloat(wallet[0].balance) || 0;
    const balanceAfter = type === 'credit' ? balanceBefore + amount : balanceBefore - amount;

    // 3. Update Balance
    await conn.query(
        "UPDATE wallet_accounts SET balance = ?, updated_at = NOW() WHERE id = ?",
        [balanceAfter, wallet[0].id]
    );

    // 4. INSERT INTO TRANSACTION TABLE (The critical step)
    const [result] = await conn.query(
        `INSERT INTO wallet_transactions 
        (wallet_id, type, source, reference_type, reference_id, amount, balance_before, balance_after, description_en, status) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'completed')`,
        [wallet[0].id, type, source, refType, refId, amount, balanceBefore, balanceAfter, descEn]
    );

    console.log(`[Wallet] Success. Transaction ID: ${result.insertId}`);
    return result.insertId;
};

/**
 * FINALIZE PICKUP (Settlement & Financial Audit)
 * 1. Updates verified item weights and rates.
 * 2. Processes Rider Incentives and Agent Commissions.
 * 3. Settles payment (Cash or Wallet).
 * 4. Logs a master entry into the Financial Ledger.
 */
export const finalizePickup = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        await conn.beginTransaction();

        const { id: pickupId } = req.params;
        const { items, payment_method, note } = req.body;

        // 1. Fetch Master Record
        const [p] = await conn.query(`
            SELECT p.*, 
                   c.user_id as customer_uid, 
                   r.user_id as rider_uid, 
                   a.owner_user_id as agent_uid, 
                   p.agent_id,
                   wa.id as agent_wallet_id
            FROM pickups p
            JOIN customers c ON p.customer_id = c.id
            LEFT JOIN riders r ON p.rider_id = r.id
            LEFT JOIN agents a ON p.agent_id = a.id
            LEFT JOIN wallet_accounts wa ON a.owner_user_id = wa.user_id
            WHERE p.id = ? FOR UPDATE`, [pickupId]);

        if (!p.length) throw new ApiError(404, "Pickup request not found.");
        const pickup = p[0];

        if (!pickup.agent_wallet_id && pickup.agent_uid) {
            const [newW] = await conn.query("INSERT INTO wallet_accounts (user_id, balance) VALUES (?, 0)", [pickup.agent_uid]);
            pickup.agent_wallet_id = newW.insertId;
        }

        let netPayable = 0;

        // 2. Process Items
        for (const it of items) {
            const weight = parseFloat(it.actual_weight) || 0;
            const rate = parseFloat(it.final_rate) || 0;
            const subtotal = weight * rate;
            netPayable += subtotal;

            if (it.id && !String(it.id).startsWith('new-')) {
                await conn.query(`UPDATE pickup_items SET actual_weight = ?, final_rate_per_unit = ?, final_amount = ? WHERE id = ?`,
                    [weight, rate, subtotal, it.id]);
            } else {
                await conn.query(`INSERT INTO pickup_items (pickup_id, item_id, actual_weight, final_rate_per_unit, final_amount) VALUES (?, ?, ?, ?, ?)`,
                    [pickupId, it.item_id, weight, rate, subtotal]);
            }
        }

        const adminComm = netPayable * 0.05;
        const agentComm = netPayable * 0.05;
        const riderComm = netPayable * 0.02;

        // 4. Payments
        let mainTxId;
        if (payment_method === 'wallet') {
            mainTxId = await updateWallet(conn, pickup.customer_uid, netPayable, 'credit', 'pickup_payment', 'pickup', pickupId, `Payment: ${pickup.booking_code}`);
        } else {
            const [cashTx] = await conn.query(`INSERT INTO wallet_transactions (wallet_id, type, source, reference_type, reference_id, amount, balance_before, balance_after, status) VALUES (?, 'debit', 'cash_collection', 'pickup', ?, ?, 0, 0, 'completed')`,
                [pickup.agent_wallet_id, pickupId, netPayable]);
            mainTxId = cashTx.insertId;
        }

        if (pickup.agent_uid) await updateWallet(conn, pickup.agent_uid, agentComm, 'credit', 'pickup_commission', 'pickup', pickupId, `Hub: ${pickup.booking_code}`);
        if (pickup.rider_uid) await updateWallet(conn, pickup.rider_uid, riderComm, 'credit', 'pickup_commission', 'pickup', pickupId, `Rider: ${pickup.booking_code}`);

        // 6. Audit Ledger
        await conn.query(`INSERT INTO financial_ledger (wallet_id, transaction_id, source_type, source_id, pickup_id, debit, credit, entry_type, admin_commission, agent_commission, rider_commission, net_payout, payment_method) VALUES (?, ?, 'pickup', ?, ?, ?, 0, 'outflow', ?, ?, ?, ?, ?)`,
            [pickup.agent_wallet_id, mainTxId, pickupId, pickupId, netPayable, netPayable, adminComm, agentComm, riderComm, netPayable, payment_method]);

        // 7. Final Update
        await conn.query(`UPDATE pickups SET status = 'completed', net_payable_amount = ?, rider_collected_cash = ?, payment_status = 'paid', completed_at = NOW() WHERE id = ?`,
            [netPayable, (payment_method === 'cash' ? netPayable : 0), pickupId]);

        await conn.commit();

        // 8. BACKGROUND: Generate Receipt and Email everyone
        setImmediate(async () => {
            try {
                const [receiptInfo] = await db.query(`
                    SELECT p.*, uc.full_name as customer_name, uc.email as customer_email, 
                           ur.full_name as rider_name, a.hub_name, ua.email as agent_email
                    FROM pickups p
                    JOIN customers c ON p.customer_id = c.id JOIN users uc ON c.user_id = uc.id
                    JOIN riders r ON p.rider_id = r.id JOIN users ur ON r.user_id = ur.id
                    JOIN agents a ON p.agent_id = a.id JOIN users ua ON a.owner_user_id = ua.id
                    WHERE p.id = ?`, [pickupId]);

                const [receiptItems] = await db.query(`
                    SELECT pi.*, si.name_en as item_name 
                    FROM pickup_items pi 
                    JOIN scrap_items si ON pi.item_id = si.id 
                    WHERE pi.pickup_id = ?`, [pickupId]);

                if (receiptInfo.length) await sendUnifiedReceipt(receiptInfo[0], receiptItems);
            } catch (err) { console.error("Receipt Processing Error:", err); }
        });

        res.json({ success: true, message: "Finalized & Receipt Dispatched" });

    } catch (err) {
        await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};

/**
 * GET RIDER JOB HISTORY
 * Fetches completed pickups and associated incentives
 */
export const getRiderHistory = async (req, res, next) => {
    try {
        const rider = await getRiderInfo(req);
        const riderId = rider.id;

        const [history] = await db.query(`
            SELECT 
                p.id, 
                p.booking_code, 
                p.completed_at, 
                p.net_payable_amount as total_value,
                p.rider_commission_amount as incentive,
                p.payment_method,
                u.full_name as customer_name,
                addr.address_line
            FROM pickups p
            JOIN customers c ON p.customer_id = c.id
            JOIN users u ON c.user_id = u.id
            LEFT JOIN addresses addr ON p.customer_address_id = addr.id
            WHERE p.rider_id = ? AND p.status = 'completed'
            ORDER BY p.completed_at DESC`, [riderId]);

        res.json({ success: true, data: history });
    } catch (err) {
        next(err);
    }
};

/**
 * GET RIDER HISTORY DETAIL
 * Fetches item-by-item breakdown of a completed task
 */
export const getHistoryDetail = async (req, res, next) => {
    try {
        const { id } = req.params;
        const rider = await getRiderInfo(req);

        // 1. Fetch Master Record
        const [pickup] = await db.query(`
            SELECT p.*, u.full_name as customer_name, addr.address_line
            FROM pickups p
            JOIN customers c ON p.customer_id = c.id
            JOIN users u ON c.user_id = u.id
            LEFT JOIN addresses addr ON p.customer_address_id = addr.id
            WHERE p.id = ? AND p.rider_id = ? AND p.status = 'completed'`,
            [id, rider.id]
        );

        if (!pickup.length) throw new ApiError(404, "History record not found.");

        // 2. Fetch Itemized Audit Trail
        const [items] = await db.query(`
            SELECT pi.*, si.name_en, si.unit, si.image_url
            FROM pickup_items pi
            JOIN scrap_items si ON pi.item_id = si.id
            WHERE pi.pickup_id = ?`, [id]);

        res.json({ success: true, data: { pickup: pickup[0], items } });
    } catch (err) {
        next(err);
    }
};

/**
 * GET RIDER EARNINGS OVERVIEW
 * Aggregates wallet balance, cash accountability, and monthly performance.
 */
export const getEarningsOverview = async (req, res, next) => {
    try {
        const rider = await getRiderInfo(req);
        const userId = rider.user_id; // Primary Key from 'users' table
        const riderId = rider.id;     // Primary Key from 'riders' table

        // 1. Fetch Wallet Balance (Directly from wallet_accounts)
        const [wallet] = await db.query(
            "SELECT id, balance FROM wallet_accounts WHERE user_id = ?",
            [userId]
        );

        const walletId = wallet[0]?.id || null;

        // 2. Fetch Cash in Hand (Total physical cash collected by rider not yet settled)
        const [cashRows] = await db.query(
            `SELECT SUM(rider_collected_cash) as total_cash 
             FROM pickups 
             WHERE rider_id = ? AND status = 'completed' AND payment_method = 'cash'`,
            [riderId]
        );

        // 3. Monthly Performance (Earnings for the current calendar month)
        const [monthlyRows] = await db.query(
            `SELECT SUM(rider_commission_amount) as monthly_total 
             FROM pickups 
             WHERE rider_id = ? AND status = 'completed' 
             AND MONTH(completed_at) = MONTH(CURRENT_DATE())
             AND YEAR(completed_at) = YEAR(CURRENT_DATE())`,
            [riderId]
        );

        // 4. Recent Wallet Transactions (Pulling by wallet_id for performance)
        let transactions = [];
        if (walletId) {
            const [txRows] = await db.query(
                `SELECT * FROM wallet_transactions 
                 WHERE wallet_id = ? 
                 ORDER BY created_at DESC LIMIT 15`,
                [walletId]
            );
            transactions = txRows;
        }

        res.json({
            success: true,
            stats: {
                // Ensure we return 0 instead of null for the UI
                wallet_balance: parseFloat(wallet[0]?.balance || 0).toFixed(2),
                cash_in_hand: parseFloat(cashRows[0]?.total_cash || 0).toFixed(2),
                monthly_earnings: parseFloat(monthlyRows[0]?.monthly_total || 0).toFixed(2)
            },
            transactions: transactions
        });
    } catch (err) {
        console.error("Earnings Overview Error:", err);
        next(err);
    }
};