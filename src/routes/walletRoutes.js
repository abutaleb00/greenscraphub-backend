// src/routes/walletRoutes.js
import express from "express";
import { auth } from "../middlewares/auth.js";
import {
    getWalletSummary,
    getWalletTransactions,
    getAdminWalletStats
} from "../controllers/walletController.js";

const router = express.Router();

/**
 * @route   GET /api/v1/wallet/summary
 * @desc    Get current balance and last 15 transactions
 * @access  Private (Customer, Rider, Agent)
 */
router.get(
    "/summary",
    auth(["customer", "rider", "agent"]),
    getWalletSummary
);

/**
 * @route   GET /api/v1/wallet/transactions
 * @desc    Get full paginated transaction ledger
 * @access  Private (Customer, Rider, Agent)
 */
router.get(
    "/transactions",
    auth(["customer", "rider", "agent"]),
    getWalletTransactions
);

/* ============================================================
    ADMIN FINANCIAL OVERVIEW
============================================================ */

/**
 * @route   GET /api/v1/wallet/admin/stats
 * @desc    Get total platform balance and payout metrics
 * @access  Private (Admin Only)
 */
router.get(
    "/admin/stats",
    auth(["admin"]),
    getAdminWalletStats
);

export default router;