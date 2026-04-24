import db from '../../config/db.js';
import ApiError from '../../utils/ApiError.js';
import { sendUnifiedReceipt } from '../../services/mailService.js';
import { sendPushNotification } from '../../utils/notificationHelper.js';

/* -----------------------------------------------------
    HELPER: SAVE TO NOTIFICATIONS TABLE (DB Persistent)
    Mapped to ENUM('info', 'alert', 'success', 'warning')
----------------------------------------------------- */
const saveNotification = async (conn, userId, titleKey, bodyKey, placeholders = {}, type = 'info', action = null) => {
    try {
        const validTypes = ['info', 'alert', 'success', 'warning'];
        const finalType = validTypes.includes(type) ? type : 'info';

        await conn.query(`
            INSERT INTO notifications (
                user_id, title_key, body_key, body_placeholders, 
                notification_type, click_action, created_at
            ) VALUES (?, ?, ?, ?, ?, ?, NOW())`,
            [userId, titleKey, bodyKey, JSON.stringify(placeholders), finalType, action]
        );
    } catch (err) {
        console.error("[DB NOTIFICATION ERROR]", err.message);
    }
};
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
 * 1. GET RIDER Status
 * Mobile optimized summary of tasks, performance, and cash.
 */
export const updateStatus = async (req, res) => {
    const { is_online, current_latitude, current_longitude } = req.body;
    const userId = req.user.id; // From auth middleware

    try {
        // 1. Update the riders table
        // We use user_id to find the rider record
        const [result] = await db.query(
            `UPDATE riders 
             SET is_online = ?, 
                 current_latitude = IFNULL(?, current_latitude), 
                 current_longitude = IFNULL(?, current_longitude),
                 updated_at = NOW()
             WHERE user_id = ?`,
            [is_online, current_latitude, current_longitude, userId]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({
                success: false,
                message: "Rider profile not found."
            });
        }

        // 2. Get the IO instance attached in server.js
        const io = req.app.get('io');

        // 3. Broadcast to Admin/Agent Dashboard (Live Map)
        // This ensures the dot on the admin map changes color instantly
        io.to('active_riders_map').emit('rider_status_update', {
            riderId: userId,
            is_online: is_online === 1,
            location: current_latitude ? {
                lat: current_latitude,
                lng: current_longitude
            } : null,
            timestamp: new Date()
        });

        return res.json({
            success: true,
            message: is_online ? "You are now Online" : "You are now Offline",
            data: { is_online: !!is_online }
        });

    } catch (error) {
        console.error("Internal Server Error (updateStatus):", error);
        return res.status(500).json({
            success: false,
            message: "Failed to update status on server."
        });
    }
};

/**
 * Updates Rider's Last Known Coordinates in Database
 * This is called by the background task every 30-60 seconds.
 */
export const updateLocation = async (req, res) => {
    const { latitude, longitude, heading, speed } = req.body;
    const userId = req.user.id;

    try {
        // 1. Update Persistent Storage (MySQL)
        const [result] = await db.query(
            `UPDATE riders 
             SET current_latitude = ?, 
                 current_longitude = ?, 
                 updated_at = NOW()
             WHERE user_id = ?`,
            [latitude, longitude, userId]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, message: "Rider not found" });
        }

        // 2. Optional: If you want to trigger the Socket from the REST API instead of the App
        // const io = req.app.get('io');
        // io.to('active_riders_map').emit('rider_moved', {
        //     riderId: userId,
        //     latitude,
        //     longitude,
        //     heading
        // });

        return res.json({ success: true, message: "Location synced to DB" });

    } catch (error) {
        console.error("DB Location Sync Error:", error);
        return res.status(500).json({ success: false });
    }
};
/**
 * GET RIDER DASHBOARD
 * Mobile-optimized LOC (Logistics Operations Center) data.
 */
export async function getRiderDashboard(req, res, next) {
    try {
        const userId = req.user.id;

        // 1. Get Rider Profile with safety check
        const [riderRows] = await db.query(
            `SELECT r.id, r.is_online, u.full_name, u.profile_image 
             FROM riders r 
             JOIN users u ON r.user_id = u.id 
             WHERE r.user_id = ?`,
            [userId]
        );

        if (!riderRows.length) throw new ApiError(404, "Rider profile not found.");
        const rider = riderRows[0];
        const riderId = rider.id;

        // 2. Fetch Active Missions (Queue)
        const [activeTasks] = await db.query(
            `SELECT 
                p.id, p.booking_code, p.status, p.scheduled_date, p.scheduled_time_slot,
                u.full_name AS customer_name, u.phone AS customer_phone,
                adr.address_line, adr.house_no, adr.road_no, adr.landmark,
                adr.latitude, adr.longitude
            FROM pickups p
            JOIN users u ON p.customer_id = u.id
            LEFT JOIN addresses adr ON p.customer_address_id = adr.id
            WHERE p.rider_id = ? 
              AND p.status IN ('accepted', 'rider_on_way', 'arrived', 'weighing')
              AND p.is_deleted = 0
            ORDER BY p.status = 'weighing' DESC, p.scheduled_date ASC`,
            [riderId]
        );

        // 3. Financial Intelligence Query (Calculates Today, Month, and Liability)
        const [stats] = await db.query(
            `SELECT
                COUNT(CASE WHEN DATE(completed_at) = CURDATE() THEN 1 END) AS count_today,
                COUNT(CASE WHEN MONTH(completed_at) = MONTH(CURDATE()) AND YEAR(completed_at) = YEAR(CURDATE()) THEN 1 END) AS count_month,
                COALESCE(SUM(CASE WHEN DATE(completed_at) = CURDATE() THEN rider_commission_amount ELSE 0 END), 0) AS earn_today,
                COALESCE(SUM(CASE WHEN MONTH(completed_at) = MONTH(CURDATE()) AND YEAR(completed_at) = YEAR(CURDATE()) THEN rider_commission_amount ELSE 0 END), 0) AS earn_month,
                -- LIABILITY: Sum of collected cash where status is completed but NOT yet settled to hub
                COALESCE(SUM(CASE WHEN is_settled_to_hub = 0 AND status = 'completed' THEN rider_collected_cash ELSE 0 END), 0) AS cash_liability
            FROM pickups
            WHERE rider_id = ?`,
            [riderId]
        );

        // 4. Wallet Balance (Actual Withdrawable Earnings)
        const [wallet] = await db.query("SELECT balance FROM wallet_accounts WHERE user_id = ?", [userId]);

        // Helper for Avatar URL
        const getAvatarUrl = (path) => {
            if (!path) return null;
            return path.startsWith('http') ? path : `${process.env.BASE_URL || 'https://webapp.prosfata.space'}${path}`;
        };

        return res.json({
            success: true,
            data: {
                profile: {
                    name: rider.full_name,
                    avatar: getAvatarUrl(rider.profile_image),
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
                active_missions: activeTasks.map(t => ({
                    id: t.id,
                    ref: t.booking_code,
                    status: t.status,
                    customer: { name: t.customer_name, phone: t.customer_phone },
                    location: {
                        address: [t.house_no, t.road_no, t.address_line].filter(Boolean).join(', ') || 'Address N/A',
                        landmark: t.landmark,
                        coords: { lat: t.latitude, lng: t.longitude }
                    },
                    schedule: t.scheduled_time_slot
                }))
            }
        });
    } catch (err) { next(err); }
}

/**
 * GET RIDER ACTIVE TASKS
 * Optimized for Desktop Command Console: Fetches precise location and mission metadata
 */
export const getMyTasks = async (req, res, next) => {
    try {
        const rider = await getRiderInfo(req);
        const riderId = rider.id;

        // 1. Fetch Current Active Missions
        const [tasks] = await db.query(`
            SELECT 
                p.id, p.booking_code, p.status, p.scheduled_date, 
                p.scheduled_time_slot, p.customer_note,
                u.full_name as customer_name, u.phone as customer_phone,
                addr.address_line, addr.house_no, addr.road_no, addr.landmark,
                addr.latitude, addr.longitude,
                p.base_amount as estimated_amount,
                p.payment_method,
                p.payment_mode_snapshot as mode
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

        // 2. NEW: Calculate Total Liability (Cash collected but not settled to Hub)
        const [liabilityRow] = await db.query(`
            SELECT SUM(rider_collected_cash) as total_liability 
            FROM pickups 
            WHERE rider_id = ? 
              AND status = 'completed' 
              AND is_settled_to_hub = 0`, [riderId]);

        const totalLiability = parseFloat(liabilityRow[0].total_liability || 0);

        // 3. Transform Tasks for UI Consistency
        const missionQueue = tasks.map(task => {
            const addressParts = [];
            if (task.house_no) addressParts.push(`House ${task.house_no}`);
            if (task.road_no) addressParts.push(`Road ${task.road_no}`);
            if (task.address_line) addressParts.push(task.address_line);
            if (task.landmark) addressParts.push(`(${task.landmark})`);

            return {
                ...task,
                display_address: addressParts.length > 0 ? addressParts.join(', ') : "Location not specified",
                estimated_amount: parseFloat(task.estimated_amount || 0).toFixed(2),
                is_urgent: new Date(task.scheduled_date) <= new Date()
            };
        });

        res.json({
            success: true,
            meta: {
                total_active: missionQueue.length,
                total_liability: totalLiability.toFixed(2), // Match the UI Dashboard
                currency: "BDT"
            },
            data: missionQueue
        });
    } catch (err) {
        console.error("Task Query Error:", err);
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
            const baseUrl = process.env.BASE_URL || 'https://webapp.prosfata.space';
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
/**
 * UPDATE TASK STATUS WITH TIMELINE LOGGING
 * Flow: accepted -> rider_on_way -> arrived -> weighing
 */
export const updateTaskStatus = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const { id } = req.params;
        const { status } = req.body;
        const changerId = req.user.id;

        const validStatuses = ['accepted', 'rider_on_way', 'arrived', 'weighing'];
        if (!validStatuses.includes(status)) throw new ApiError(400, `Invalid transition: ${status}`);

        await conn.beginTransaction();

        let timestampQuery = "";
        if (status === 'accepted') timestampQuery = ", rider_assigned_at = NOW()"; // Track when rider accepted
        if (status === 'arrived') timestampQuery = ", rider_arrived_at = NOW()";
        if (status === 'weighing') timestampQuery = ", weighing_started_at = NOW()";

        const [result] = await conn.query(
            `UPDATE pickups SET status = ?, updated_at = NOW() ${timestampQuery} WHERE id = ?`,
            [status, id]
        );

        if (result.affectedRows === 0) throw new ApiError(404, "Task not found");

        // Add to history timeline
        await conn.query(
            `INSERT INTO pickup_timeline (pickup_id, status, changed_by, note) VALUES (?, ?, ?, ?)`,
            [id, status, changerId, `Rider marked status as: ${status.replace(/_/g, ' ')}`]
        );

        // Fetch Customer Data for notifications
        const [customer] = await conn.query(
            `SELECT u.id as target_user_id, u.fcm_token, p.booking_code 
             FROM pickups p 
             JOIN customers c ON p.customer_id = c.id 
             JOIN users u ON c.user_id = u.id 
             WHERE p.id = ?`, [id]
        );

        const target = customer[0];

        if (target) {
            // 🔥 Persistently save the notification in DB
            // We map the status to the translation keys used in the frontend
            let titleKey = `notif_${status}_title`;
            let bodyKey = `notif_${status}_body`;

            // Fix for status mismatch (accepted maps to rider_assigned in your UI)
            if (status === 'accepted') {
                titleKey = 'notif_rider_assigned_title';
                bodyKey = 'notif_rider_assigned_body';
            }

            let notifType = 'info';
            if (status === 'rider_on_way' || status === 'arrived') notifType = 'success';
            if (status === 'weighing') notifType = 'warning';

            await saveNotification(
                conn,
                target.target_user_id,
                titleKey,
                bodyKey,
                { bookingCode: target.booking_code },
                notifType,
                `/(home)/activity/${id}`
            );
        }

        await conn.commit();

        // 2. TRIGGER REAL-TIME PUSH (Optional but recommended)
        if (target && target.fcm_token) {
            let pushTitle = "Pickup Update";
            let pushBody = `Your request ${target.booking_code} is now ${status.replace(/_/g, ' ')}`;

            if (status === 'rider_on_way') {
                pushTitle = "Rider is on the way! 🛵";
                pushBody = "The rider is moving towards your location.";
            } else if (status === 'arrived') {
                pushTitle = "Rider Arrived! 📍";
                pushBody = "Our rider is at your location. Please get ready.";
            }

            await sendPushNotification(target.fcm_token, pushTitle, pushBody, { orderId: id.toString(), type: "order_update" });
        }

        res.json({ success: true, message: `Status updated to ${status}` });

    } catch (err) {
        if (conn) await conn.rollback();
        console.error("Task Update Error:", err);
        next(err);
    } finally {
        if (conn) conn.release();
    }
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
 * FINALIZE PICKUP (Hybrid Model: Salary vs Commission)
 * Updates items, calculates splits, executes wallet transfers, and logs to timeline.
 */
export const finalizePickup = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const { id: pickupId } = req.params;
        const { items, payment_method, note } = req.body;

        await conn.beginTransaction();

        const [p] = await conn.query(`
            SELECT p.*, c.user_id as customer_uid, cust_u.fcm_token as customer_fcm,
                   r.user_id as rider_uid, r.payment_mode as rider_specific_mode,
                   a.owner_user_id as agent_uid, a.default_rider_mode as agent_default_mode,
                   a.platform_fee_percent as hub_platform_fee_rate,
                   a.hub_commission_value as hub_commission_rate
            FROM pickups p
            JOIN customers c ON p.customer_id = c.id
            JOIN users cust_u ON c.user_id = cust_u.id
            LEFT JOIN riders r ON p.rider_id = r.id
            LEFT JOIN agents a ON p.agent_id = a.id
            WHERE p.id = ? FOR UPDATE`, [pickupId]);

        if (!p.length) throw new ApiError(404, "Pickup not found.");
        const pickup = p[0];

        const activePaymentMode = pickup.rider_specific_mode === 'default'
            ? pickup.agent_default_mode : pickup.rider_specific_mode;

        let netPayableToCustomer = 0;
        for (const it of items) {
            const weight = parseFloat(it.actual_weight) || 0;
            const rate = parseFloat(it.final_rate) || 0;
            const subtotal = weight * rate;
            netPayableToCustomer += subtotal;

            if (it.id && !String(it.id).startsWith('new-')) {
                await conn.query(`UPDATE pickup_items SET actual_weight = ?, final_rate_per_unit = ?, final_amount = ? WHERE id = ?`, [weight, rate, subtotal, it.id]);
            } else {
                await conn.query(`INSERT INTO pickup_items (pickup_id, item_id, actual_weight, final_rate_per_unit, final_amount) VALUES (?, ?, ?, ?, ?)`, [pickupId, it.item_id, weight, rate, subtotal]);
            }
        }

        const platformFeeAmount = (netPayableToCustomer * (parseFloat(pickup.hub_platform_fee_rate) || 0)) / 100;
        const agentCommAmount = (netPayableToCustomer * (parseFloat(pickup.hub_commission_rate) || 0)) / 100;
        let riderCommAmount = (activePaymentMode === 'commission') ? netPayableToCustomer * 0.02 : 0;

        // Wallet Transfers
        if (payment_method === 'wallet') {
            await updateWallet(conn, pickup.customer_uid, netPayableToCustomer, 'credit', 'pickup_payment', 'pickup', pickupId, `Payment for ${pickup.booking_code}`);
        }
        if (pickup.agent_uid && agentCommAmount > 0) {
            await updateWallet(conn, pickup.agent_uid, agentCommAmount, 'credit', 'pickup_commission', 'pickup', pickupId, `Hub Commission: ${pickup.booking_code}`);
        }
        if (pickup.rider_uid && riderCommAmount > 0) {
            await updateWallet(conn, pickup.rider_uid, riderCommAmount, 'credit', 'pickup_commission', 'pickup', pickupId, `Rider Incentive: ${pickup.booking_code}`);
        }

        await conn.query(`
            UPDATE pickups SET status = 'completed', net_payable_amount = ?, rider_collected_cash = ?, 
            rider_commission_amount = ?, platform_fee_amount = ?, agent_commission_amount = ?, 
            payment_mode_snapshot = ?, payment_status = 'paid', completed_at = NOW() WHERE id = ?`,
            [netPayableToCustomer, (payment_method === 'cash' ? netPayableToCustomer : 0), riderCommAmount, platformFeeAmount, agentCommAmount, activePaymentMode, pickupId]
        );

        await conn.query(`INSERT INTO pickup_timeline (pickup_id, status, note, changed_by) VALUES (?, 'completed', ?, ?)`,
            [pickupId, `Finalized. ৳${netPayableToCustomer} via ${payment_method.toUpperCase()}.`, req.user.id]);

        // 🔥 DB NOTIFICATION: Completion History
        await saveNotification(
            conn,
            pickup.customer_uid,
            'notif_pickup_completed_title',
            'notif_pickup_completed_body',
            { bookingCode: pickup.booking_code, amount: netPayableToCustomer.toFixed(2) },
            'success',
            `/(home)/activity/${pickupId}`
        );

        await conn.commit();

        // 3. TRIGGER PUSH NOTIFICATION
        if (pickup.customer_fcm) {
            await sendPushNotification(
                pickup.customer_fcm,
                "Recycling Completed! 💰",
                `Your pickup ${pickup.booking_code} is finished. You earned ৳${netPayableToCustomer.toFixed(2)}.`,
                { orderId: pickupId.toString(), type: "order_update" }
            );
        }

        res.json({ success: true, message: "Pickup Successfully Finalized" });

    } catch (err) {
        if (conn) await conn.rollback();
        next(err);
    } finally {
        if (conn) conn.release();
    }
};

/**
 * GET RIDER JOB HISTORY
 * Returns both completed and active missions for the mobile mission hub.
 */
export const getRiderHistory = async (req, res, next) => {
    try {
        const rider = await getRiderInfo(req);
        const riderId = rider.id;

        const [history] = await db.query(`
            SELECT 
                p.id, 
                p.booking_code, 
                p.status, -- CRITICAL: Returned for frontend logic
                p.completed_at, 
                p.created_at,
                -- Total scrap value collected
                p.net_payable_amount as total_value,
                -- Estimated value (for active tasks)
                p.base_amount as estimated_amount,
                -- Actual physical cash collected (if payment was cash)
                p.rider_collected_cash,
                -- The incentive earned
                p.rider_commission_amount as incentive,
                p.payment_method,
                -- Status of physical cash handover to Hub
                p.is_settled_to_hub,
                -- Historical snapshot of the payment mode (salary/commission)
                p.payment_mode_snapshot as payment_mode,
                u.full_name as customer_name,
                adr.address_line
            FROM pickups p
            JOIN customers c ON p.customer_id = c.id
            JOIN users u ON c.user_id = u.id
            LEFT JOIN addresses adr ON p.customer_address_id = adr.id
            WHERE p.rider_id = ? 
              -- Include all statuses relevant to the rider's task list
              AND p.status IN ('accepted', 'rider_on_way', 'arrived', 'weighing', 'completed', 'finalized')
            ORDER BY 
                CASE 
                    WHEN p.status != 'completed' AND p.status != 'finalized' THEN 1 
                    ELSE 2 
                END, 
                p.created_at DESC 
            LIMIT 50`, [riderId]);

        // Clean data for the Frontend
        const formattedHistory = history.map(item => ({
            ...item,
            status: item.status || 'pending', // Fallback for safety
            total_value: parseFloat(item.total_value || 0).toFixed(2),
            estimated_amount: parseFloat(item.estimated_amount || 0).toFixed(2),
            incentive: parseFloat(item.incentive || 0).toFixed(2),
            rider_collected_cash: parseFloat(item.rider_collected_cash || 0).toFixed(2),
            address_line: item.address_line || "On-site collection"
        }));

        res.json({
            success: true,
            data: formattedHistory
        });
    } catch (err) {
        console.error("History Fetch Error:", err);
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
 * Updated for Hybrid Model (is_settled_to_hub tracking)
 */
export const getEarningsOverview = async (req, res, next) => {
    try {
        const rider = await getRiderInfo(req);
        const userId = rider.user_id;
        const riderId = rider.id;

        // 1. Fetch Liquid Wallet Balance (Rider's actual available funds)
        const [wallet] = await db.query(
            "SELECT balance FROM wallet_accounts WHERE user_id = ?",
            [userId]
        );

        // 2. Fetch Liability (Cash in Hand - Collected but NOT yet paid to Agent)
        const [liabilityRow] = await db.query(
            `SELECT COALESCE(SUM(rider_collected_cash), 0) as total_liability 
             FROM pickups 
             WHERE rider_id = ? AND status = 'completed' AND is_settled_to_hub = 0`,
            [riderId]
        );

        // 3. Fetch Total Settled (Total Physical Cash the rider HAS already handed to Agents)
        const [settledRow] = await db.query(
            `SELECT COALESCE(SUM(rider_collected_cash), 0) as total_paid_to_agent 
             FROM pickups 
             WHERE rider_id = ? AND status = 'completed' AND is_settled_to_hub = 1`,
            [riderId]
        );

        // 4. Performance: Monthly Incentives (Commissions earned this month)
        const [monthlyRow] = await db.query(
            `SELECT COALESCE(SUM(rider_commission_amount), 0) as monthly_incentive 
             FROM pickups 
             WHERE rider_id = ? AND status = 'completed' 
             AND MONTH(completed_at) = MONTH(CURRENT_DATE())
             AND YEAR(completed_at) = YEAR(CURRENT_DATE())`,
            [riderId]
        );

        // 5. Audit Ledger (Recent Transactions)
        const [history] = await db.query(
            `SELECT 
                p.id, p.booking_code, p.net_payable_amount, 
                p.rider_collected_cash, p.rider_commission_amount, 
                p.completed_at, p.is_settled_to_hub, p.payment_mode_snapshot
             FROM pickups p
             WHERE p.rider_id = ? AND p.status = 'completed'
             ORDER BY p.completed_at DESC LIMIT 20`,
            [riderId]
        );

        res.json({
            success: true,
            stats: {
                wallet_balance: parseFloat(wallet[0]?.balance || 0).toFixed(2),
                cash_in_hand: parseFloat(liabilityRow[0]?.total_liability || 0).toFixed(2),
                total_paid_to_agent: parseFloat(settledRow[0]?.total_paid_to_agent || 0).toFixed(2),
                monthly_incentives: parseFloat(monthlyRow[0]?.monthly_incentive || 0).toFixed(2)
            },
            ledger: history.map(tx => ({
                id: tx.id,
                booking_code: tx.booking_code,
                total_collected: parseFloat(tx.rider_collected_cash).toFixed(2),
                my_incentive: parseFloat(tx.rider_commission_amount).toFixed(2),
                date: tx.completed_at,
                is_settled: tx.is_settled_to_hub === 1,
                protocol: tx.payment_mode_snapshot
            }))
        });
    } catch (err) {
        next(err);
    }
};