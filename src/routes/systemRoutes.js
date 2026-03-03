import express from 'express';
import { auth } from '../middlewares/auth.js';
import { settleRiderCash } from '../controllers/financeController.js';
import { saveDeviceToken, getMyNotifications } from '../controllers/notificationController.js';
import { getPriceHistory, updateAgentCoverage } from '../controllers/auditController.js';

const router = express.Router();

// Finance & Settlement
router.post('/settle-rider', auth(['agent', 'admin']), settleRiderCash);

// Notifications
router.post('/device-token', auth(), saveDeviceToken);
router.get('/notifications', auth(), getMyNotifications);

// Audit & Prices
router.get('/scrap/price-history/:itemId', getPriceHistory);
router.post('/admin/hub-coverage', auth(['admin']), updateAgentCoverage);

export default router;