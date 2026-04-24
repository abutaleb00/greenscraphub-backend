import db from "../../config/db.js";
import ApiError from "../../utils/ApiError.js";
import { sendPushNotification } from "../../utils/notificationHelper.js";

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
const updateWallet = async (conn, userId, amount, type, source, refType, refId, descEn) => {
    // 1. Prevent Double Processing: Check if this reference transaction already exists
    const [existing] = await conn.query(
        "SELECT id FROM wallet_transactions WHERE reference_type = ? AND reference_id = ? AND source = ?",
        [refType, refId, source]
    );
    if (existing.length > 0) return;

    // 2. Fetch Wallet with Row Lock (FOR UPDATE) to prevent race conditions
    let [wallet] = await conn.query(
        "SELECT id, balance FROM wallet_accounts WHERE user_id = ? FOR UPDATE",
        [userId]
    );

    if (!wallet.length) {
        const [ins] = await conn.query(
            "INSERT INTO wallet_accounts (user_id, balance) VALUES (?, 0)",
            [userId]
        );
        wallet = [{ id: ins.insertId, balance: 0 }];
    }

    const balanceBefore = parseFloat(wallet[0].balance);
    const balanceAfter = type === 'credit' ? balanceBefore + amount : balanceBefore - amount;

    // 3. Update Balance
    await conn.query(
        "UPDATE wallet_accounts SET balance = ?, updated_at = NOW() WHERE id = ?",
        [balanceAfter, wallet[0].id]
    );

    // 4. Log Transaction
    await conn.query(
        `INSERT INTO wallet_transactions 
        (wallet_id, type, source, reference_type, reference_id, amount, balance_before, balance_after, description_en, status) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'completed')`,
        [wallet[0].id, type, source, refType, refId, amount, balanceBefore, balanceAfter, descEn]
    );
};

/**
 * GET PICKUP DETAILS (Real-App Tracking Logic)
 * Provides dynamic coordinates based on the current state of the pickup
 */

/**
 * GET PICKUP DETAILS (Real-App Tracking Logic)
 * Fixed: Corrected coordinate mapping to use Address table and updated fallbacks to Khulna.
 */
export const getPickupDetails = async (req, res, next) => {
    try {
        const { id } = req.params;

        // 1. Fetch main pickup info with Address Coordinates
        const [pickupRows] = await db.query(
            `SELECT 
                p.*, 
                u.full_name as customer_name, u.phone as customer_phone, 
                r_u.full_name as rider_name, r_u.phone as rider_phone,
                r.current_latitude as rider_live_lat, r.current_longitude as rider_live_lng,
                ag.business_name as hub_name, ag.latitude as hub_lat, ag.longitude as hub_lng,
                addr.address_line, addr.house_no, addr.road_no, addr.landmark,
                addr.latitude as addr_lat, addr.longitude as addr_lng, -- Added specific address coords
                dns.name_en as division_name, dist.name_en as district_name, upz.name_en as upazila_name
             FROM pickups p 
             JOIN customers c ON p.customer_id = c.id 
             JOIN users u ON c.user_id = u.id
             LEFT JOIN riders r ON p.rider_id = r.id 
             LEFT JOIN users r_u ON r.user_id = r_u.id
             LEFT JOIN agents ag ON p.agent_id = ag.id
             LEFT JOIN addresses addr ON p.customer_address_id = addr.id
             LEFT JOIN divisions dns ON addr.division_id = dns.id
             LEFT JOIN districts dist ON addr.district_id = dist.id
             LEFT JOIN upazilas upz ON addr.upazila_id = upz.id
             WHERE p.id = ?`,
            [id]
        );

        if (!pickupRows.length) throw new ApiError(404, "Pickup request not found");

        const pickup = pickupRows[0];

        // 2. Real-App Tracking Logic
        // Khulna Default Fallback: 22.8456, 89.5403
        let tracking = {
            origin: {
                latitude: parseFloat(pickup.hub_lat) || 22.8456,
                longitude: parseFloat(pickup.hub_lng) || 89.5403,
                label: 'Hub'
            },
            destination: {
                // Priority: 1. Address Lat/Lng, 2. Pickup Lat/Lng, 3. Khulna Default
                latitude: parseFloat(pickup.addr_lat) || parseFloat(pickup.latitude) || 22.8456,
                longitude: parseFloat(pickup.addr_lng) || parseFloat(pickup.longitude) || 89.5403,
                label: 'Customer'
            },
            current_focus: 'agent'
        };

        // Switch origin to Rider Live Location if they are currently moving
        if (['rider_on_way', 'arrived', 'weighing'].includes(pickup.status?.toLowerCase()) && pickup.rider_live_lat) {
            tracking.origin = {
                latitude: parseFloat(pickup.rider_live_lat),
                longitude: parseFloat(pickup.rider_live_lng),
                label: 'Rider'
            };
            tracking.current_focus = 'rider';
        }

        // 3. Image URL Helper
        const getFullUrl = (path) => {
            if (!path) return null;
            if (path.startsWith('http')) return path;
            const baseUrl = process.env.BASE_URL || 'https://webapp.prosfata.space';
            return `${baseUrl.replace(/\/$/, "")}/${path.replace(/^\//, "")}`;
        };

        // 4. Fetch Items with photos
        const [items] = await db.query(
            `SELECT pi.*, si.name_en, si.name_bn, si.unit, si.image_url as product_image
             FROM pickup_items pi 
             JOIN scrap_items si ON pi.item_id = si.id 
             WHERE pi.pickup_id = ?`,
            [id]
        );

        const transformedItems = items.map(item => {
            let photos = [];
            if (item.photo_url) {
                try {
                    const parsed = typeof item.photo_url === 'string' ? JSON.parse(item.photo_url) : item.photo_url;
                    photos = Array.isArray(parsed) ? parsed.map(p => getFullUrl(p)) : [getFullUrl(parsed)];
                } catch (e) {
                    photos = [getFullUrl(item.photo_url)];
                }
            }
            return {
                ...item,
                product_image: getFullUrl(item.product_image),
                user_photos: photos
            };
        });

        // 5. Fetch Timeline
        const [timeline] = await db.query(
            `SELECT pt.*, u.full_name as changer_name FROM pickup_timeline pt
             LEFT JOIN users u ON pt.changed_by = u.id
             WHERE pt.pickup_id = ? ORDER BY pt.created_at DESC`,
            [id]
        );

        res.json({
            success: true,
            data: {
                pickup: {
                    ...pickup,
                    proof_image_before: getFullUrl(pickup.proof_image_before),
                    proof_image_after: getFullUrl(pickup.proof_image_after),
                    rider_image: null
                },
                tracking,
                items: transformedItems,
                timeline
            }
        });

    } catch (err) {
        console.error("Tracking API Error:", err);
        next(err);
    }
};

export const completePickup = async (req, res, next) => {
    const conn = await db.getConnection();
    const { id: pickupId } = req.params;
    const { items, payment_method, note } = req.body;

    try {
        await conn.beginTransaction();

        // 1. Fetch Master Record with Locks
        const [p] = await conn.query(`
            SELECT p.*, 
                   c.user_id as customer_uid, 
                   r.user_id as rider_uid, 
                   a.owner_user_id as agent_uid,
                   u.fcm_token as customer_fcm
            FROM pickups p
            JOIN customers c ON p.customer_id = c.id
            JOIN users u ON c.user_id = u.id
            LEFT JOIN riders r ON p.rider_id = r.id
            LEFT JOIN agents a ON p.agent_id = a.id
            WHERE p.id = ? FOR UPDATE`, [pickupId]);

        if (!p.length) throw new ApiError(404, "Pickup request not found.");
        if (p[0].status === 'completed') throw new ApiError(400, "This pickup is already finalized.");

        const pickup = p[0];

        // 2. Settlement Settings
        const adminCommRate = 0.05;
        const agentCommRate = 0.05;
        const riderCommRate = 0.02;

        let netPayable = 0;
        let totalWeight = 0;
        const parsedItems = typeof items === 'string' ? JSON.parse(items) : items;

        // 3. Process Verified Weights
        for (const it of parsedItems) {
            const weight = parseFloat(it.actual_weight) || 0;
            const rate = parseFloat(it.final_rate) || 0;
            const itemSubtotal = weight * rate;

            netPayable += itemSubtotal;
            totalWeight += weight;

            await conn.query(
                `UPDATE pickup_items SET 
                    actual_weight = ?, 
                    final_rate_per_unit = ?, 
                    final_amount = ?, 
                    updated_at = NOW() 
                 WHERE id = ? AND pickup_id = ?`,
                [weight, rate, itemSubtotal, it.id, pickupId]
            );
        }

        // 4. Financial Transfers
        if (pickup.agent_uid) {
            await updateWallet(conn, pickup.agent_uid, (netPayable * agentCommRate), 'credit', 'pickup_commission', 'pickup', pickupId, `Commission for Shipment #${pickup.booking_code}`);
        }
        if (pickup.rider_uid) {
            await updateWallet(conn, pickup.rider_uid, (netPayable * riderCommRate), 'credit', 'pickup_commission', 'pickup', pickupId, `Incentive for Shipment #${pickup.booking_code}`);
        }
        if (payment_method === 'wallet') {
            await updateWallet(conn, pickup.customer_uid, netPayable, 'credit', 'pickup_payment', 'pickup', pickupId, `Payment for Shipment #${pickup.booking_code}`);
        }

        // 5. Finalize Record
        const proofImage = req.file ? `/uploads/pickups/${req.file.filename}` : null;
        await conn.query(
            `UPDATE pickups SET 
                status = 'completed', 
                actual_weight_kg = ?, 
                net_payable_amount = ?, 
                admin_commission_amount = ?, 
                agent_commission_amount = ?, 
                rider_commission_amount = ?,
                payment_method = ?, 
                payment_status = ?,
                proof_image_after = ?, 
                completed_at = NOW(),
                updated_at = NOW()
            WHERE id = ?`,
            [totalWeight, netPayable, (netPayable * adminCommRate), (netPayable * agentCommRate), (netPayable * riderCommRate), payment_method, (payment_method === 'wallet' ? 'paid' : 'pending'), proofImage, pickupId]
        );

        // 6. Timeline Entry
        await conn.query(
            `INSERT INTO pickup_timeline (pickup_id, status, note, changed_by, created_at) 
             VALUES (?, 'completed', ?, ?, NOW())`,
            [pickupId, note || 'Shipment verified and finalized', req.user.id]
        );

        // 🔥 DB NOTIFICATION: Earnings Confirmed
        await saveNotification(
            conn,
            pickup.customer_uid,
            'notif_earnings_confirmed_title',
            'notif_earnings_confirmed_body',
            { bookingCode: pickup.booking_code, amount: netPayable.toFixed(2) },
            'success',
            `/(home)/activity/${pickupId}`
        );

        await conn.commit();

        // 8. FIREBASE PUSH
        if (pickup.customer_fcm) {
            try {
                await sendPushNotification(
                    pickup.customer_fcm,
                    "Earnings Confirmed! 💰",
                    `Success! You earned ৳${netPayable.toFixed(2)} for request ${pickup.booking_code}.`,
                    { orderId: pickupId.toString(), type: "order_update" }
                );
            } catch (notifErr) {
                console.error("FCM Error:", notifErr.message);
            }
        }

        res.json({ success: true, message: "Shipment finalized successfully!", net_amount: netPayable });

    } catch (err) {
        if (conn) await conn.rollback();
        next(err);
    } finally {
        if (conn) conn.release();
    }
};

export const getReceipt = async (req, res, next) => {
    try {
        const { id } = req.params;
        const [pickup] = await db.query(`
            SELECT p.*, u.full_name as customer_name, ag.business_name as hub_name
            FROM pickups p 
            JOIN customers c ON p.customer_id = c.id 
            JOIN users u ON c.user_id = u.id
            LEFT JOIN agents ag ON p.agent_id = ag.id
            WHERE p.id = ? AND p.status = 'completed'`, [id]);

        if (!pickup.length) throw new ApiError(404, "Receipt not available.");

        const [items] = await db.query(
            `SELECT pi.*, si.name_en 
             FROM pickup_items pi 
             JOIN scrap_items si ON pi.item_id = si.id 
             WHERE pi.pickup_id = ?`, [id]);

        res.json({ success: true, data: { pickup: pickup[0], items } });
    } catch (err) {
        next(err);
    }
};


export const getPickupTimeline = async (req, res, next) => {
    try {
        const { id } = req.params;

        const query = `
            SELECT 
                pt.id,
                pt.status,
                pt.note,
                pt.created_at,
                COALESCE(u.full_name, 'System/Deleted User') as actor_name
            FROM pickup_timeline pt
            LEFT JOIN users u ON pt.changed_by = u.id
            WHERE pt.pickup_id = ?
            ORDER BY pt.created_at ASC
        `;

        const [rows] = await db.query(query, [id]);

        res.json({
            success: true,
            data: rows
        });
    } catch (err) {
        console.error("Timeline API Error:", err);
        next(err);
    }
};