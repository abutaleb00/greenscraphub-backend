// src/routes/pointRoutes.js
import express from "express";
import { auth } from "../middlewares/auth.js";
import { redeemPoints, getLeaderboard } from "../controllers/pointController.js";
import db from "../config/db.js";

const router = express.Router();

/**
 * @route   GET /api/v1/points/history
 * @desc    Get customer's current point balance and full transaction history
 * @access  Private (Customer)
 */
router.get("/history", auth(["customer"]), async (req, res) => {
    try {
        // 1. Fetch current balance
        const [customer] = await db.query(
            "SELECT id, total_points FROM customers WHERE user_id = ?",
            [req.user.id]
        );

        if (!customer.length) {
            return res.status(404).json({ success: false, message: "Customer profile not found" });
        }

        // 2. Fetch point ledger
        const [history] = await db.query(
            "SELECT id, amount, type, description, created_at FROM point_transactions WHERE customer_id = ? ORDER BY created_at DESC",
            [customer[0].id]
        );

        // Standardized response for frontend charts and lists
        res.json({
            success: true,
            data: {
                total_points: customer[0].total_points,
                history: history
            }
        });
    } catch (err) {
        console.error("Points History Error:", err);
        res.status(500).json({ success: false, message: "Failed to load point history" });
    }
});

/**
 * @route   POST /api/v1/points/redeem
 * @desc    Convert accumulated Green Points into Wallet Balance (৳)
 * @access  Private (Customer)
 */
router.post("/redeem", auth(["customer"]), redeemPoints);

/**
 * @route   GET /api/v1/points/leaderboard
 * @desc    Get top recyclers based on points (Encourages community engagement)
 * @access  Private (Authenticated Users)
 */
router.get("/leaderboard", auth(["customer", "rider", "agent", "admin"]), getLeaderboard);

export default router;