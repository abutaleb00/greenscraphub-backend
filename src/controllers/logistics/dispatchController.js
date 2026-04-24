import db from "../../config/db.js";
import ApiError from "../../utils/ApiError.js";
import { sendPushNotification } from "../../utils/notificationHelper.js";

/* -----------------------------------------------------
    HELPER: SAVE TO NOTIFICATIONS TABLE (DB Persistent)
    Mapped to ENUM('info', 'alert', 'success', 'warning')
----------------------------------------------------- */
const saveNotification = async (conn, userId, titleKey, bodyKey, placeholders = {}, type = 'info', action = null) => {
    try {
        await conn.query(`
            INSERT INTO notifications (
                user_id, title_key, body_key, body_placeholders, 
                notification_type, click_action, created_at
            ) VALUES (?, ?, ?, ?, ?, ?, NOW())`,
            [userId, titleKey, bodyKey, JSON.stringify(placeholders), type, action]
        );
    } catch (err) {
        console.error("[DB NOTIFICATION ERROR]", err.message);
    }
};
/**
 * 1. ASSIGN RIDER (DISPATCH)
 */
export const assignRiderController = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const { id: pickupId } = req.params;
        const { rider_id } = req.body;
        const changerId = req.user.id;

        await conn.beginTransaction();

        const [rows] = await conn.query(
            `SELECT r.id, r.agent_id, u.full_name as rider_name, 
                    cust_u.id as target_user_id, cust_u.fcm_token as customer_fcm, p.booking_code
             FROM pickups p
             JOIN riders r ON r.id = ?
             JOIN users u ON r.user_id = u.id
             JOIN customers c ON p.customer_id = c.id
             JOIN users cust_u ON c.user_id = cust_u.id
             WHERE p.id = ?`,
            [rider_id, pickupId]
        );

        if (!rows.length) throw new ApiError(404, "Data mismatch: Rider or Pickup not found");
        const data = rows[0];

        const [updateResult] = await conn.query(
            `UPDATE pickups SET 
                rider_id = ?, 
                agent_id = ?, 
                status = 'accepted', 
                assigned_at = NOW(),
                updated_at = NOW()
             WHERE id = ? AND status IN ('pending', 'assigned')`,
            [data.id, data.agent_id, pickupId]
        );

        if (updateResult.affectedRows === 0) {
            throw new ApiError(400, "Pickup is already processed or completed.");
        }

        await conn.query(
            "INSERT INTO pickup_timeline (pickup_id, status, changed_by, note) VALUES (?, 'accepted', ?, ?)",
            [pickupId, changerId, `Dispatched to Rider: ${data.rider_name}`]
        );

        // 🔥 DB NOTIFICATION: Rider Assigned
        await saveNotification(
            conn,
            data.target_user_id,
            'notif_rider_assigned_title',
            'notif_rider_assigned_body',
            { riderName: data.rider_name, bookingCode: data.booking_code },
            'success',
            `/(home)/activity/${pickupId}`
        );

        await conn.commit();

        if (data.customer_fcm) {
            await sendPushNotification(
                data.customer_fcm,
                "Rider Assigned! 🚚",
                `${data.rider_name} has accepted your pickup request ${data.booking_code}.`,
                { orderId: pickupId.toString(), type: "order_update" }
            );
        }

        res.json({ success: true, message: `Rider ${data.rider_name} has been dispatched.` });
    } catch (err) {
        await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};

/**
 * 2. UPDATE STATUS
 */
export const updatePickupStatus = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const { id } = req.params;
        const { status, note } = req.body;
        const allowedStatuses = ['rider_on_way', 'arrived', 'weighing', 'cancelled'];

        if (!allowedStatuses.includes(status)) throw new ApiError(400, "Invalid status transition");

        await conn.beginTransaction();

        const [pickupRows] = await conn.query(
            `SELECT p.booking_code, u.id as target_user_id, u.fcm_token 
             FROM pickups p
             JOIN customers c ON p.customer_id = c.id
             JOIN users u ON c.user_id = u.id
             WHERE p.id = ?`, [id]
        );

        await conn.query(`UPDATE pickups SET status = ?, updated_at = NOW() WHERE id = ?`, [status, id]);

        await conn.query(
            "INSERT INTO pickup_timeline (pickup_id, status, p_timestamp, note) VALUES (?, ?, NOW(), ?)",
            [id, status, note || `Status: ${status}`]
        );

        // 🔥 DB NOTIFICATION: Dynamic Status Mapping
        let titleKey = 'notif_status_update_title';
        let bodyKey = 'notif_status_update_body';
        let notifType = 'info';

        if (status === 'rider_on_way') notifType = 'success';
        if (status === 'cancelled') notifType = 'alert';

        await saveNotification(
            conn,
            pickupRows[0].target_user_id,
            `notif_${status}_title`, // Dynamic keys like notif_arrived_title
            `notif_${status}_body`,
            { bookingCode: pickupRows[0].booking_code },
            notifType,
            `/(home)/activity/${id}`
        );

        await conn.commit();

        if (pickupRows.length && pickupRows[0].fcm_token) {
            const customerToken = pickupRows[0].fcm_token;
            const bCode = pickupRows[0].booking_code;

            let title = "Pickup Update";
            let body = `Your request ${bCode} is now: ${status.replace(/_/g, ' ')}`;

            if (status === 'rider_on_way') { title = "Rider is coming! 🛵"; body = `Your rider is on the way for ${bCode}.`; }
            else if (status === 'arrived') { title = "Rider Arrived! 📍"; body = `Our rider has arrived for ${bCode}.`; }
            else if (status === 'cancelled') { title = "Pickup Cancelled ❌"; body = `Your request ${bCode} has been cancelled.`; }

            await sendPushNotification(customerToken, title, body, { orderId: id.toString(), type: "order_update" });
        }

        res.json({ success: true, message: `Status updated to ${status}` });
    } catch (err) {
        await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};

/**
 * 3. AGENT PICKUP LIST (Cleaned for Admin Fresh Start)
 */
export const agentPickupList = async (req, res, next) => {
    try {
        const [agent] = await db.query("SELECT id FROM agents WHERE owner_user_id = ?", [req.user.id]);
        if (!agent.length) return res.json({ success: true, data: [] });

        const [rows] = await db.query(
            `SELECT p.*, u.full_name AS customer_name, u.phone as customer_phone
             FROM pickups p 
             JOIN customers c ON c.id = p.customer_id 
             JOIN users u ON u.id = c.user_id 
             WHERE p.agent_id = ? 
             AND p.is_archived = 0 
             AND p.is_deleted = 0
             ORDER BY p.created_at DESC`,
            [agent[0].id]
        );

        res.json({ success: true, data: rows });
    } catch (err) {
        next(err);
    }
};

/**
 * 4. RIDER PICKUP LIST (Cleaned for Admin Fresh Start)
 */
export const riderPickupList = async (req, res, next) => {
    try {
        const [rider] = await db.query("SELECT id FROM riders WHERE user_id = ?", [req.user.id]);
        if (!rider.length) return res.json({ success: true, data: [] });

        const [rows] = await db.query(
            `SELECT p.*, u.full_name AS customer_name, u.phone as customer_phone
             FROM pickups p 
             JOIN customers c ON c.id = p.customer_id 
             JOIN users u ON u.id = c.user_id 
             WHERE p.rider_id = ? 
             AND p.status != 'completed'
             AND p.is_archived = 0 
             AND p.is_deleted = 0
             ORDER BY p.created_at DESC`,
            [rider[0].id]
        );

        res.json({ success: true, data: rows });
    } catch (err) {
        next(err);
    }
};

/**
 * 5. REASSIGN RIDER
 */
export const reassignSinglePickup = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const { id } = req.params;
        const { target_rider_id } = req.body;

        await conn.beginTransaction();

        const [rows] = await conn.query(
            `SELECT p.booking_code, u.id as target_user_id, u.fcm_token, r_u.full_name as rider_name
             FROM pickups p
             JOIN customers c ON p.customer_id = c.id
             JOIN users u ON c.user_id = u.id
             JOIN riders r ON r.id = ?
             JOIN users r_u ON r.user_id = r_u.id
             WHERE p.id = ?`, [target_rider_id, id]
        );

        if (!rows.length) throw new ApiError(404, "Pickup or target rider not found");

        await conn.query(
            "UPDATE pickups SET rider_id = ?, assigned_at = NOW(), status = 'assigned' WHERE id = ?",
            [target_rider_id, id]
        );

        await conn.query(
            "INSERT INTO pickup_timeline (pickup_id, status, note) VALUES (?, 'assigned', ?)",
            [id, `Job reassigned to Rider: ${rows[0].rider_name}`]
        );

        // 🔥 DB NOTIFICATION: Job Reassigned
        await saveNotification(
            conn,
            rows[0].target_user_id,
            'notif_rider_reassigned_title',
            'notif_rider_reassigned_body',
            { riderName: rows[0].rider_name, bookingCode: rows[0].booking_code },
            'warning',
            `/(home)/activity/${id}`
        );

        await conn.commit();

        if (rows[0].fcm_token) {
            await sendPushNotification(
                rows[0].fcm_token,
                "Rider Reassigned 🔄",
                `A new rider, ${rows[0].rider_name}, has been assigned to your request.`,
                { orderId: id.toString(), type: "order_update" }
            );
        }

        res.json({ success: true, message: "Rider reassigned successfully." });
    } catch (err) {
        await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};