import express from 'express';
import {
    getNotifications,
    getUnreadCount,
    markAsRead,
    markAllAsRead,
    deleteNotification
} from '../controllers/notificationController.js';
import { auth } from '../middlewares/auth.js';

const router = express.Router();

// Apply auth to all notification endpoints
router.use(auth());

/**
 * @route   GET /api/v1/notifications
 * @desc    Get notification history
 */
router.get('/', getNotifications);

/**
 * @route   GET /api/v1/notifications/unread-count
 * @desc    Get count for the app UI badge
 */
router.get('/unread-count', getUnreadCount);

/**
 * @route   PATCH /api/v1/notifications/:id/read
 * @desc    Mark a specific notification as seen
 */
router.patch('/:id/read', markAsRead);

/**
 * @route   POST /api/v1/notifications/mark-all-read
 * @desc    Clear all unread markers
 */
router.post('/mark-all-read', markAllAsRead);

/**
 * @route   DELETE /api/v1/notifications/:id
 * @desc    Remove a notification from history
 */
router.delete('/:id', deleteNotification);

export default router;