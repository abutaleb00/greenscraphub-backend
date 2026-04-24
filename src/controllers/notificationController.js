// src/controllers/notificationController.js
import db from '../config/db.js';

/**
 * 1. REGISTER DEVICE TOKEN
 * Called by Mobile App on login to store FCM/Expo tokens.
 */
export const saveDeviceToken = async (req, res) => {
    try {
        const { token, device_type } = req.body;
        await db.query(
            "INSERT INTO device_tokens (user_id, token, device_type) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE token = ?",
            [req.user.id, token, device_type, token]
        );
        res.json({ success: true });
    } catch (err) { res.status(500).json({ error: err.message }); }
};

/**
 * 1. Get all notifications for the logged-in user
 */
export const getNotifications = async (req, res, next) => {
    try {
        const userId = req.user.id;

        const [rows] = await db.query(`
            SELECT * FROM notifications 
            WHERE user_id = ? 
            ORDER BY created_at DESC 
            LIMIT 50`,
            [userId]
        );

        res.status(200).json({
            success: true,
            data: rows
        });
    } catch (err) {
        next(err);
    }
};

/**
 * 2. Get unread count (For the Dashboard Bell Badge)
 */
export const getUnreadCount = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const [rows] = await db.query(
            "SELECT COUNT(*) as unread_count FROM notifications WHERE user_id = ? AND is_read = 0",
            [userId]
        );

        res.status(200).json({
            success: true,
            unread_count: rows[0].unread_count
        });
    } catch (err) {
        next(err);
    }
};

/**
 * 3. Mark single notification as read
 */
export const markAsRead = async (req, res, next) => {
    try {
        const { id } = req.params;
        const userId = req.user.id;

        const [result] = await db.query(
            "UPDATE notifications SET is_read = 1, read_at = NOW() WHERE id = ? AND user_id = ?",
            [id, userId]
        );

        if (result.affectedRows === 0) throw new ApiError(404, "Notification not found");

        res.json({ success: true, message: "Notification marked as read" });
    } catch (err) {
        next(err);
    }
};

/**
 * 4. Mark all as read
 */
export const markAllAsRead = async (req, res, next) => {
    try {
        const userId = req.user.id;

        await db.query(
            "UPDATE notifications SET is_read = 1, read_at = NOW() WHERE user_id = ? AND is_read = 0",
            [userId]
        );

        res.json({ success: true, message: "All notifications marked as read" });
    } catch (err) {
        next(err);
    }
};

/**
 * 5. Delete a notification
 */
export const deleteNotification = async (req, res, next) => {
    try {
        const { id } = req.params;
        const userId = req.user.id;

        const [result] = await db.query(
            "DELETE FROM notifications WHERE id = ? AND user_id = ?",
            [id, userId]
        );

        if (result.affectedRows === 0) throw new ApiError(404, "Notification not found");

        res.json({ success: true, message: "Notification deleted" });
    } catch (err) {
        next(err);
    }
};