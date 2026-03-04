import express from 'express';
import {
    getUnifiedReceipt,
    resendReceiptEmail
} from '../controllers/logistics/receiptController.js';
import { auth } from '../middlewares/auth.js'; // Using your project's specific auth middleware

const router = express.Router();

/**
 * @route   GET /api/v1/receipts/:id
 * @desc    Fetch full digital receipt data for Web/PDF view
 * @access  Private (All authenticated users can request, controller handles ownership check)
 */
router.get(
    "/:id",
    auth(["customer", "rider", "agent", "admin"]),
    getUnifiedReceipt
);

/**
 * @route   POST /api/v1/receipts/:id/resend
 * @desc    Manually re-trigger the Email + PDF dispatch
 * @access  Private (Admin & Agent only)
 */
router.post(
    "/:id/resend",
    auth(["admin", "agent"]),
    resendReceiptEmail
);

export default router;