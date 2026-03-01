import express from "express";
import { auth } from "../middlewares/auth.js";
import { redeemPoints, getLeaderboard } from "../controllers/pointController.js";
import db from "../config/db.js";

const router = express.Router();

// Get points balance and history
router.get("/history", auth(["customer"]), async (req, res) => {
    try {
        const [customer] = await db.query("SELECT id, total_points FROM customers WHERE user_id = ?", [req.user.id]);
        const [history] = await db.query(
            "SELECT * FROM point_transactions WHERE customer_id = ? ORDER BY created_at DESC",
            [customer[0].id]
        );
        res.json({ success: true, total_points: customer[0].total_points, history });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
});

// Redeem points to cash
router.post("/redeem", auth(["customer"]), redeemPoints);
router.post("/leaderboard", auth(["customer"]), getLeaderboard);

export default router;