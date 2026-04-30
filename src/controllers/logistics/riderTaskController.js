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
/**
 * UPDATE RIDER LIVE LOCATION
 * Updates coordinates and triggers real-time socket events for live tracking.
 */
export const updateLocation = async (req, res) => {
    const { latitude, longitude, heading, speed } = req.body;
    const userId = req.user.id; // Identification from auth middleware

    // Validate coordinates to prevent DB errors
    if (!latitude || !longitude) {
        return res.status(400).json({
            success: false,
            message: "Invalid satellite coordinates received."
        });
    }

    try {
        // 1. Update Persistent Storage (MySQL)
        // We update current_latitude, current_longitude, and updated_at
        const [result] = await db.query(
            `UPDATE riders 
             SET current_latitude = ?, 
                 current_longitude = ?, 
                 updated_at = NOW()
             WHERE user_id = ?`,
            [latitude, longitude, userId]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({
                success: false,
                message: "Rider profile not found in active registry."
            });
        }

        // 2. Real-time Dispatch (Socket.io)
        // Triggering this from the API ensures the Admin/Agent map updates instantly
        const io = req.app.get('io');
        if (io) {
            io.to('fleet_monitoring_room').emit('rider_position_update', {
                rider_id: userId,
                latitude: parseFloat(latitude),
                longitude: parseFloat(longitude),
                heading: heading || 0,
                speed: speed || 0,
                timestamp: new Date()
            });
        }

        return res.json({
            success: true,
            message: "Satellite link synchronized",
            timestamp: new Date()
        });

    } catch (error) {
        console.error("Critical Location Sync Error:", error);
        return res.status(500).json({
            success: false,
            message: "Internal telemetry failure."
        });
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
        // 🔥 SYNCED JOIN: pickups -> customers -> users
        const [activeTasks] = await db.query(
            `SELECT 
                p.id, p.booking_code, p.status, p.scheduled_date, p.scheduled_time_slot,
                u.full_name AS customer_name, u.phone AS customer_phone,
                adr.address_line, adr.house_no, adr.road_no, adr.landmark,
                adr.latitude, adr.longitude
            FROM pickups p
            INNER JOIN customers c ON p.customer_id = c.id
            INNER JOIN users u ON c.user_id = u.id
            LEFT JOIN addresses adr ON p.customer_address_id = adr.id
            WHERE p.rider_id = ? 
              AND p.status NOT IN ('completed', 'cancelled')
              AND p.is_deleted = 0
            ORDER BY 
                CASE 
                    WHEN p.status = 'weighing' THEN 1
                    WHEN p.status = 'arrived' THEN 2
                    WHEN p.status = 'rider_on_way' THEN 3
                    ELSE 4 
                END ASC, p.scheduled_date ASC`,
            [riderId]
        );

        // 3. Financial Intelligence Query
        const [stats] = await db.query(
            `SELECT
                COUNT(CASE WHEN DATE(completed_at) = CURDATE() THEN 1 END) AS count_today,
                COUNT(CASE WHEN MONTH(completed_at) = MONTH(CURDATE()) AND YEAR(completed_at) = YEAR(CURDATE()) THEN 1 END) AS count_month,
                COALESCE(SUM(CASE WHEN DATE(completed_at) = CURDATE() THEN rider_commission_amount ELSE 0 END), 0) AS earn_today,
                COALESCE(SUM(CASE WHEN MONTH(completed_at) = MONTH(CURDATE()) AND YEAR(completed_at) = YEAR(CURDATE()) THEN rider_commission_amount ELSE 0 END), 0) AS earn_month,
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
                active_missions: activeTasks.map(t => {
                    // Format address string
                    const addressParts = [];
                    if (t.house_no) addressParts.push(`H# ${t.house_no}`);
                    if (t.road_no) addressParts.push(`R# ${t.road_no}`);
                    if (t.address_line) addressParts.push(t.address_line);

                    return {
                        id: t.id,
                        ref: t.booking_code,
                        status: t.status,
                        customer: { name: t.customer_name, phone: t.customer_phone },
                        location: {
                            address: addressParts.join(', ') || 'Location Specified',
                            landmark: t.landmark,
                            coords: { lat: t.latitude, lng: t.longitude }
                        },
                        schedule: t.scheduled_time_slot
                    };
                })
            }
        });
    } catch (err) {
        console.error("Dashboard API Error:", err);
        next(err);
    }
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
 * Returns comprehensive data including customer info, catalog images, 
 * market pricing, and a full operational timeline.
 */
export const getTaskDetail = async (req, res, next) => {
    try {
        const { id } = req.params;
        const rider = await getRiderInfo(req);

        // 1. Fetch Pickup Master Data with Schedule Highlights
        const [taskRows] = await db.query(`
            SELECT 
                p.id, p.booking_code, p.status, p.base_amount, p.customer_note,
                p.min_total_amount, p.max_total_amount, p.payment_method,
                -- Schedule Info
                p.scheduled_date, p.scheduled_time_slot,
                -- Customer Details
                u.full_name as customer_name, u.phone as customer_phone,
                addr.address_line, addr.house_no, addr.road_no, addr.landmark,
                addr.latitude as addr_lat, addr.longitude as addr_lng, 
                p.rider_id, p.created_at as order_made_at
            FROM pickups p
            JOIN customers c ON p.customer_id = c.id
            JOIN users u ON c.user_id = u.id
            LEFT JOIN addresses addr ON p.customer_address_id = addr.id
            WHERE p.id = ?`,
            [id]
        );

        if (!taskRows.length) {
            throw new ApiError(404, "Mission Node not found.");
        }

        const task = taskRows[0];

        // 2. Fetch the Operational Timeline (The "Story" of the order)
        const [timeline] = await db.query(`
            SELECT status, note, created_at as timestamp
            FROM pickup_timeline
            WHERE pickup_id = ?
            ORDER BY created_at DESC`,
            [id]
        );

        // 3. Fetch Itemized List with Market Metadata
        const [items] = await db.query(`
            SELECT 
                pi.id as pickup_item_id, pi.item_id, pi.category_id,
                si.name_en, si.name_bn, si.unit, 
                si.current_min_rate as market_min_price,
                si.current_max_rate as market_max_price,
                si.image_url as product_image,
                pi.estimated_weight, pi.actual_weight,
                pi.final_rate_per_unit as applied_rate,
                pi.photo_url as user_uploaded_photo
            FROM pickup_items pi
            LEFT JOIN scrap_items si ON pi.item_id = si.id
            WHERE pi.pickup_id = ?`,
            [id]
        );

        const baseUrl = process.env.BASE_URL || 'https://webapp.prosfata.space';
        const getFullUrl = (path) => (!path ? null : (path.startsWith('http') ? path : `${baseUrl}/${path.replace(/^\//, '')}`));

        const transformedItems = items.map(item => {
            let photosArray = [];
            try { photosArray = item.user_uploaded_photo ? JSON.parse(item.user_uploaded_photo) : []; } catch (e) { photosArray = []; }

            return {
                ...item,
                market_range: `৳${item.market_min_price} - ৳${item.market_max_price}`,
                user_photos: photosArray.map(p => getFullUrl(p)),
                catalog_image: getFullUrl(item.product_image),
                current_valuation: (parseFloat(item.actual_weight || item.estimated_weight || 0) * parseFloat(item.applied_rate || item.market_min_price)).toFixed(2)
            };
        });

        res.json({
            success: true,
            data: {
                pickup: {
                    ...task,
                    // Highlights for UI
                    formatted_schedule: `${new Date(task.scheduled_date).toDateString()} | ${task.scheduled_time_slot}`,
                },
                scenarios: {
                    min_expected: parseFloat(task.min_total_amount || 0).toFixed(2),
                    max_expected: parseFloat(task.max_total_amount || 0).toFixed(2),
                    base_fare: parseFloat(task.base_amount || 0).toFixed(2)
                },
                items: transformedItems,
                // Full history of the order for the rider
                order_timeline: timeline
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
/**
 * FINALIZE PICKUP
 * Updates items, calculates splits, handles liability, and uploads proof images.
 */
export const finalizePickup = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const { id: pickupId } = req.params;
        const { items, payment_method, note, proof_image_after } = req.body;

        await conn.beginTransaction();

        // 1. Lock record and fetch participant details
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

        if (!p.length) throw new ApiError(404, "Pickup mission not found.");
        const pickup = p[0];

        // 2. Process Items & Calculate Totals
        let netPayableToCustomer = 0;
        for (const it of items) {
            const weight = parseFloat(it.actual_weight) || 0;
            const rate = parseFloat(it.final_rate) || 0;
            const subtotal = weight * rate;
            netPayableToCustomer += subtotal;

            if (it.id && !String(it.id).startsWith('new-')) {
                await conn.query(
                    `UPDATE pickup_items SET actual_weight = ?, final_rate_per_unit = ?, final_amount = ? WHERE id = ?`,
                    [weight, rate, subtotal, it.id]
                );
            } else {
                await conn.query(
                    `INSERT INTO pickup_items (pickup_id, item_id, actual_weight, final_rate_per_unit, final_amount) VALUES (?, ?, ?, ?, ?)`,
                    [pickupId, it.item_id, weight, rate, subtotal]
                );
            }
        }

        // 3. Calculate Splits (Rider Commission, Platform Fee, Agent Commission)
        const activeRiderMode = pickup.rider_specific_mode === 'default' ? pickup.agent_default_mode : pickup.rider_specific_mode;

        // Assume 2% for commission mode, 0 for salary mode
        const riderCommAmount = (activeRiderMode === 'commission') ? (netPayableToCustomer * 0.02) : 0;
        const agentCommAmount = (netPayableToCustomer * (parseFloat(pickup.hub_commission_rate) || 0)) / 100;
        const platformFeeAmount = (netPayableToCustomer * (parseFloat(pickup.hub_platform_fee_rate) || 0)) / 100;

        // 4. Handle Financial Flow & Liability
        // Instruction: Both Cash and Wallet increase Rider Liability
        const riderCollectedCashLiability = netPayableToCustomer;
        let walletCreditToCustomer = 0;

        if (payment_method === 'wallet') {
            walletCreditToCustomer = netPayableToCustomer;
            // System credits customer's digital wallet
            await updateWallet(conn, pickup.customer_uid, netPayableToCustomer, 'credit', 'pickup_payment', 'pickup', pickupId, `Wallet payment for ${pickup.booking_code}`);
        }

        // 5. Credit rider commission to their digital wallet (Incentive)
        if (riderCommAmount > 0) {
            await updateWallet(conn, pickup.rider_uid, riderCommAmount, 'credit', 'rider_commission', 'pickup', pickupId, `Incentive for ${pickup.booking_code}`);
        }

        // 6. Handle Proof Images (If provided as array or string)
        const proofAfter = Array.isArray(proof_image_after) ? JSON.stringify(proof_image_after) : proof_image_after;

        // 7. Final Update to Pickups Table
        await conn.query(`
            UPDATE pickups SET 
                status = 'completed',
                payment_status = 'paid',
                payment_method = ?,
                net_payable_amount = ?,
                cash_paid_to_customer = ?,
                rider_collected_cash = ?,
                wallet_credit_amount = ?,
                rider_commission_amount = ?,
                agent_commission_amount = ?,
                platform_fee_amount = ?,
                proof_image_after = ?,
                completed_at = NOW(),
                updated_at = NOW()
            WHERE id = ?`,
            [
                payment_method,
                netPayableToCustomer,
                (payment_method === 'cash' ? netPayableToCustomer : 0), // Cash paid physically
                riderCollectedCashLiability, // Rider's liability for the collected goods value
                walletCreditToCustomer,
                riderCommAmount,
                agentCommAmount,
                platformFeeAmount,
                proofAfter || pickup.proof_image_after,
                pickupId
            ]
        );

        // 8. Log Timeline
        await conn.query(`INSERT INTO pickup_timeline (pickup_id, status, note, changed_by) VALUES (?, 'completed', ?, ?)`,
            [pickupId, `Finalized at ৳${netPayableToCustomer.toFixed(2)} via ${payment_method.toUpperCase()}. Proof uploaded.`, req.user.id]);

        await conn.commit();

        res.json({
            success: true,
            message: "Mission finalized successfully.",
            data: {
                total: netPayableToCustomer.toFixed(2),
                incentive: riderCommAmount.toFixed(2),
                liability: riderCollectedCashLiability.toFixed(2)
            }
        });

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
 * Fetches breakdown, user photos, and the full timeline/audit trail.
 */
export const getHistoryDetail = async (req, res, next) => {
    try {
        const { id } = req.params;
        const rider = await getRiderInfo(req);

        const baseUrl = process.env.BASE_URL || 'https://webapp.prosfata.space';
        const getFullUrl = (path) => (!path ? null : (path.startsWith('http') ? path : `${baseUrl}/${path.replace(/^\//, '')}`));

        // 1. Fetch Master Record with Financial Result
        const [pickup] = await db.query(`
            SELECT 
                p.*, u.full_name as customer_name, u.phone as customer_phone, 
                addr.address_line, addr.landmark
            FROM pickups p
            JOIN customers c ON p.customer_id = c.id
            JOIN users u ON c.user_id = u.id
            LEFT JOIN addresses addr ON p.customer_address_id = addr.id
            WHERE p.id = ? AND p.rider_id = ?`,
            [id, rider.id]
        );

        if (!pickup.length) throw new ApiError(404, "History record not found.");

        // 2. Fetch Itemized Final Audit including User Photos
        const [items] = await db.query(`
            SELECT 
                pi.*, si.name_en, si.unit, si.image_url as product_image,
                pi.photo_url as user_uploaded_photo
            FROM pickup_items pi
            JOIN scrap_items si ON pi.item_id = si.id
            WHERE pi.pickup_id = ?`, [id]);

        // Transform items to include parsed and full-path user photos
        const transformedItems = items.map(item => {
            let photosArray = [];
            try {
                photosArray = item.user_uploaded_photo ? JSON.parse(item.user_uploaded_photo) : [];
            } catch (e) {
                photosArray = [];
            }

            return {
                ...item,
                subtotal: (parseFloat(item.actual_weight) * parseFloat(item.final_rate_per_unit)).toFixed(2),
                product_image: getFullUrl(item.product_image),
                user_photos: photosArray.map(p => getFullUrl(p)) // 🔥 These are the missing photos
            };
        });

        // 3. Fetch Full Mission Timeline
        const [timeline] = await db.query(`
            SELECT status, note, created_at as timestamp
            FROM pickup_timeline
            WHERE pickup_id = ?
            ORDER BY created_at ASC`, [id]);

        res.json({
            success: true,
            data: {
                pickup: {
                    ...pickup[0],
                    // Also format the proof_image_after (rider's upload) if it exists
                    proof_image_after: pickup[0].proof_image_after ? JSON.parse(pickup[0].proof_image_after).map(p => getFullUrl(p)) : []
                },
                items: transformedItems,
                audit_trail: timeline
            }
        });
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

/**
 * CANCEL/DECLINE TASK
 * Triggered when a rider cannot complete a deal (Price disagreement, Customer absent, etc.)
 */
export const cancelTask = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const { id } = req.params;
        const { reason, note } = req.body;
        const rider = await getRiderInfo(req); // Safety check for rider role

        if (!reason) {
            throw new ApiError(400, "A cancellation reason is required.");
        }

        await conn.beginTransaction();

        // 1. Update Pickup Table
        const [result] = await conn.query(
            `UPDATE pickups 
             SET status = 'cancelled', 
                 cancelled_at = NOW(), 
                 cancelled_by_user_id = ?, 
                 cancellation_reason = ?, 
                 cancellation_note = ?,
                 updated_at = NOW() 
             WHERE id = ? AND rider_id = ?`,
            [req.user.id, reason, note || null, id, rider.id]
        );

        if (result.affectedRows === 0) {
            throw new ApiError(404, "Task not found or unauthorized.");
        }

        // 2. Log to Timeline for History
        await conn.query(
            `INSERT INTO pickup_timeline (pickup_id, status, changed_by, note) 
             VALUES (?, 'cancelled', ?, ?)`,
            [id, req.user.id, `Declined by Rider. Reason: ${reason}. Note: ${note || 'N/A'}`]
        );

        // 3. Fetch Customer FCM Token to notify them
        const [customer] = await conn.query(
            `SELECT u.fcm_token, p.booking_code 
             FROM pickups p 
             JOIN customers c ON p.customer_id = c.id 
             JOIN users u ON c.user_id = u.id 
             WHERE p.id = ?`, [id]
        );

        await conn.commit();

        // 4. Trigger Notification (Async)
        if (customer[0]?.fcm_token) {
            sendPushNotification(
                customer[0].fcm_token,
                "Pickup Cancelled",
                `Your pickup ${customer[0].booking_code} was cancelled: ${reason}`,
                { type: "order_cancelled", id: id.toString() }
            ).catch(err => console.error("Push Error:", err.message));
        }

        res.json({
            success: true,
            message: "Mission successfully aborted and logged."
        });

    } catch (err) {
        if (conn) await conn.rollback();
        next(err);
    } finally {
        if (conn) conn.release();
    }
};