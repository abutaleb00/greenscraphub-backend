import db from "../../config/db.js";
import ApiError from "../../utils/ApiError.js";
import { sendPushNotification } from "../../utils/notificationHelper.js";
import axios from "axios";
import nodemailer from 'nodemailer';
import FormData from 'form-data'; // Ensure this package is installed: npm install form-data

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

/* -----------------------------------------------------
    HELPER: SEND RIDER EMAIL
----------------------------------------------------- */
const sendRiderAssignmentEmail = async (email, details) => {
    try {
        const transporter = nodemailer.createTransport({
            host: process.env.MAIL_HOST,
            port: parseInt(process.env.MAIL_PORT),
            secure: process.env.MAIL_SECURE === 'true',
            auth: {
                user: process.env.MAIL_USER,
                pass: process.env.MAIL_PASS,
            },
        });

        await transporter.sendMail({
            from: `"Smart Scrap Logistics" <${process.env.MAIL_USER}>`,
            to: email,
            subject: `New Task Assigned: ${details.bookingCode}`,
            html: `
                <div style="font-family: sans-serif; padding: 20px; border: 1px solid #10B981; border-radius: 15px; max-width: 600px;">
                    <h2 style="color: #10B981;">New Assignment!</h2>
                    <p>Hello <strong>${details.riderName}</strong>,</p>
                    <p>You have been assigned a new pickup mission.</p>
                    <div style="background: #f8fafc; padding: 20px; border-radius: 10px; margin: 20px 0;">
                        <p><strong>Booking Code:</strong> ${details.bookingCode}</p>
                        <p><strong>Address:</strong> ${details.address}</p>
                    </div>
                    <p>Please open the Rider App to initiate the journey.</p>
                </div>
            `,
        });
    } catch (err) {
        console.error("[MAIL ERROR]", err.message);
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

        // 1. Fetch Participant Details (Rider, Customer, and Address)
        const [rows] = await conn.query(
            `SELECT r.id, r.agent_id, u.full_name as rider_name, u.phone as rider_phone, 
                    u.email as rider_email, u.id as rider_user_id, u.fcm_token as rider_fcm,
                    cust_u.id as target_user_id, cust_u.fcm_token as customer_fcm, 
                    p.booking_code, addr.address_line
             FROM pickups p
             JOIN riders r ON r.id = ?
             JOIN users u ON r.user_id = u.id
             JOIN customers c ON p.customer_id = c.id
             JOIN users cust_u ON c.user_id = cust_u.id
             LEFT JOIN addresses addr ON p.customer_address_id = addr.id
             WHERE p.id = ?`,
            [rider_id, pickupId]
        );

        if (!rows.length) throw new ApiError(404, "Data mismatch: Rider or Pickup not found");
        const data = rows[0];

        // 2. Update Pickup Status
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

        // 3. Log Timeline
        await conn.query(
            "INSERT INTO pickup_timeline (pickup_id, status, changed_by, note) VALUES (?, 'accepted', ?, ?)",
            [pickupId, changerId, `Dispatched to Rider: ${data.rider_name}`]
        );

        // 4. 🔥 PERSISTENT NOTIFICATIONS
        // To Customer
        await saveNotification(conn, data.target_user_id, 'notif_rider_assigned_title', 'notif_rider_assigned_body',
            { riderName: data.rider_name, bookingCode: data.booking_code }, 'success', `/(home)/activity/${pickupId}`
        );

        // To Rider
        await saveNotification(conn, data.rider_user_id, 'notif_new_task_title', 'notif_new_task_body',
            { bookingCode: data.booking_code }, 'alert', `/(driver)/tasks/${pickupId}`
        );

        await conn.commit();

        // 5. --- ASYNC ALERTS (SMS, Push, Email) ---
        setImmediate(async () => {
            try {
                // A. SMS (Using form-data for multipart support)
                if (data.rider_phone) {
                    let formattedPhone = data.rider_phone.trim();
                    if (formattedPhone.startsWith('0')) formattedPhone = '88' + formattedPhone;

                    // Use a strict limit to ensure 1 SMS credit (staying under 70 for safety)
                    const bookingPart = `GSH Order: ${data.booking_code}.`; // approx 20 chars
                    const actionPart = ` Open App now.`; // 14 chars
                    const remainingSpace = 70 - (bookingPart.length + actionPart.length + 6); // approx 30 chars for address

                    const shortAddress = data.address_line ? data.address_line.substring(0, remainingSpace) : "N/A";
                    const smsMsg = `${bookingPart} Loc: ${shortAddress}.${actionPart}`;

                    const form = new FormData();
                    form.append('api_key', process.env.SMS_API_KEY);
                    form.append('msg', smsMsg); // The resulting string is guaranteed < 70 chars
                    form.append('to', formattedPhone);

                    await axios.post('https://api.sms.net.bd/sendsms', form, {
                        headers: form.getHeaders()
                    });
                }

                // To Customer (Target: customer)
                if (data.customer_fcm) {
                    await sendPushNotification(
                        data.customer_fcm,
                        "Rider Assigned! 🚚",
                        `${data.rider_name} is on the way for pickup ${data.booking_code}.`,
                        { orderId: pickupId.toString(), type: "order_update" },
                        'customer' // Explicitly target Customer App package
                    );
                }

                // To Rider (Target: rider)
                if (data.rider_fcm) {
                    await sendPushNotification(
                        data.rider_fcm,
                        "New Task! 📦",
                        `Task ${data.booking_code} assigned. Tap to view location.`,
                        {
                            orderId: pickupId.toString(),
                            type: "NEW_MISSION"
                        },
                        'rider' // Explicitly target Rider App package
                    );
                }
                // C. EMAIL
                if (data.rider_email && !data.rider_email.includes('example.com')) {
                    await sendRiderAssignmentEmail(data.rider_email, {
                        riderName: data.rider_name,
                        bookingCode: data.booking_code,
                        address: data.address_line
                    });
                }
            } catch (err) {
                console.error("[ASYNC ALERT ERROR]", err.message);
            }
        });

        res.json({ success: true, message: `Rider ${data.rider_name} has been dispatched.` });
    } catch (err) {
        if (conn) await conn.rollback();
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

        await saveNotification(conn, pickupRows[0].target_user_id, `notif_${status}_title`, `notif_${status}_body`,
            { bookingCode: pickupRows[0].booking_code }, status === 'cancelled' ? 'alert' : 'info', `/(home)/activity/${id}`
        );

        await conn.commit();

        if (pickupRows.length && pickupRows[0].fcm_token) {
            let title = "Pickup Update";
            let body = `Request ${pickupRows[0].booking_code} is now ${status.replace(/_/g, ' ')}`;
            if (status === 'rider_on_way') title = "Rider is coming! 🛵";
            else if (status === 'arrived') title = "Rider Arrived! 📍";

            sendPushNotification(pickupRows[0].fcm_token, title, body, { orderId: id.toString(), type: "order_update" });
        }

        res.json({ success: true, message: `Status updated to ${status}` });
    } catch (err) {
        if (conn) await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};

/**
 * 3. AGENT PICKUP LIST
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
 * 4. RIDER PICKUP LIST
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

        await saveNotification(conn, rows[0].target_user_id, 'notif_rider_reassigned_title', 'notif_rider_reassigned_body',
            { riderName: rows[0].rider_name, bookingCode: rows[0].booking_code }, 'warning', `/(home)/activity/${id}`
        );

        await conn.commit();

        if (rows[0].fcm_token) {
            await sendPushNotification(rows[0].fcm_token, "Rider Reassigned 🔄",
                `A new rider, ${rows[0].rider_name}, has been assigned to your request.`,
                { orderId: id.toString(), type: "order_update" }
            );
        }

        res.json({ success: true, message: "Rider reassigned successfully." });
    } catch (err) {
        if (conn) await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};