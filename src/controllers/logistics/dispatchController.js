import db from "../../config/db.js";
import ApiError from "../../utils/ApiError.js";
import { sendPushNotification } from "../../utils/notificationHelper.js";

export const assignRiderController = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const { id: pickupId } = req.params;
        const { rider_id } = req.body;
        const changerId = req.user.id;

        await conn.beginTransaction();

        // 1. Get Rider, Hub Info, and Customer FCM Token
        const [rows] = await conn.query(
            `SELECT r.id, r.agent_id, u.full_name as rider_name, 
                    cust_u.fcm_token as customer_fcm, p.booking_code
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

        // 2. Update Pickup
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

        // 3. Timeline
        await conn.query(
            "INSERT INTO pickup_timeline (pickup_id, status, changed_by, note) VALUES (?, 'accepted', ?, ?)",
            [pickupId, changerId, `Dispatched to Rider: ${data.rider_name}`]
        );

        await conn.commit();

        // 4. FIREBASE NOTIFICATION
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

export const updatePickupStatus = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { status, note } = req.body;
        const allowedStatuses = ['rider_on_way', 'arrived', 'weighing', 'cancelled'];

        if (!allowedStatuses.includes(status)) throw new ApiError(400, "Invalid status transition");

        // Fetch token and booking code before update
        const [pickupRows] = await db.query(
            `SELECT p.booking_code, u.fcm_token 
             FROM pickups p
             JOIN customers c ON p.customer_id = c.id
             JOIN users u ON c.user_id = u.id
             WHERE p.id = ?`, [id]
        );

        await db.query(`UPDATE pickups SET status = ?, updated_at = NOW() WHERE id = ?`, [status, id]);

        await db.query(
            "INSERT INTO pickup_timeline (pickup_id, status, p_timestamp, note) VALUES (?, ?, NOW(), ?)",
            [id, status, note || `Status: ${status}`]
        );

        // FIREBASE NOTIFICATION - STATUS UPDATE
        if (pickupRows.length && pickupRows[0].fcm_token) {
            const customerToken = pickupRows[0].fcm_token;
            const bCode = pickupRows[0].booking_code;

            let title = "Pickup Update";
            let body = `Your request ${bCode} status is now: ${status.replace(/_/g, ' ')}`;

            if (status === 'rider_on_way') {
                title = "Rider is coming! 🛵";
                body = `Your rider is on the way for request ${bCode}.`;
            } else if (status === 'arrived') {
                title = "Rider Arrived! 📍";
                body = `Our rider has arrived for your pickup ${bCode}.`;
            } else if (status === 'cancelled') {
                title = "Pickup Cancelled ❌";
                body = `Your request ${bCode} has been cancelled.`;
            }

            await sendPushNotification(
                customerToken,
                title,
                body,
                { orderId: id.toString(), type: "order_update" }
            );
        }

        res.json({ success: true, message: `Status updated to ${status}` });
    } catch (err) {
        next(err);
    }
};

/**
 * AGENT PICKUP LIST
 * Shows all pickups assigned to a specific hub/agent
 */
export const agentPickupList = async (req, res, next) => {
    try {
        // 1. Get Agent ID from the logged-in user
        const [agent] = await db.query(
            "SELECT id FROM agents WHERE owner_user_id = ?",
            [req.user.id]
        );

        if (!agent.length) return res.json({ success: true, data: [] });

        // 2. Fetch pickups for this agent
        const [rows] = await db.query(
            `SELECT p.*, u.full_name AS customer_name, u.phone as customer_phone
             FROM pickups p 
             JOIN customers c ON c.id = p.customer_id 
             JOIN users u ON u.id = c.user_id 
             WHERE p.agent_id = ? 
             ORDER BY p.created_at DESC`,
            [agent[0].id]
        );

        res.json({ success: true, data: rows });
    } catch (err) {
        next(err);
    }
};

/**
 * RIDER PICKUP LIST
 * Shows active tasks assigned to the specific rider
 */
export const riderPickupList = async (req, res, next) => {
    try {
        // 1. Get Rider ID from the logged-in user
        const [rider] = await db.query(
            "SELECT id FROM riders WHERE user_id = ?",
            [req.user.id]
        );

        if (!rider.length) return res.json({ success: true, data: [] });

        // 2. Fetch active (non-completed) pickups for this rider
        const [rows] = await db.query(
            `SELECT p.*, u.full_name AS customer_name, u.phone as customer_phone
             FROM pickups p 
             JOIN customers c ON c.id = p.customer_id 
             JOIN users u ON u.id = c.user_id 
             WHERE p.rider_id = ? AND p.status != 'completed' 
             ORDER BY p.created_at DESC`,
            [rider[0].id]
        );

        res.json({ success: true, data: rows });
    } catch (err) {
        next(err);
    }
};

/**
 * REASSIGN SINGLE PICKUP
 */
export const reassignSinglePickup = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const { id } = req.params;
        const { target_rider_id } = req.body;

        await conn.beginTransaction();

        // Get Customer Token and Rider Name for context
        const [rows] = await conn.query(
            `SELECT p.booking_code, u.fcm_token, r_u.full_name as rider_name
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

        await conn.commit();

        // FIREBASE NOTIFICATION
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