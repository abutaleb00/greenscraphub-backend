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
 * 2. GET USER NOTIFICATIONS
 */
export const getMyNotifications = async (req, res) => {
    const [rows] = await db.query(
        "SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT 50",
        [req.user.id]
    );
    res.json({ success: true, data: rows });
};