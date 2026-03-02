import express from "express";
import { auth } from "../middlewares/auth.js";
import { redeemPoints, getLeaderboard } from "../controllers/pointController.js";
import db from "../config/db.js";

const router = express.Router();

// 1. Get points balance and history (Existing)
router.get("/history", auth(["customer"]), async (req, res) => {
    try {
        const [customer] = await db.query("SELECT id, total_points FROM customers WHERE user_id = ?", [req.user.id]);

        if (!customer.length) return res.status(404).json({ success: false, message: "Customer not found" });

        const [history] = await db.query(
            "SELECT * FROM point_transactions WHERE customer_id = ? ORDER BY created_at DESC",
            [customer[0].id]
        );

        // Ensure keys match frontend expectation: data: { total_points, history }
        res.json({
            success: true,
            data: {
                total_points: customer[0].total_points,
                history
            }
        });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
});

// 2. Redeem points (Must be POST as it modifies data)
router.post("/redeem", auth(["customer"]), redeemPoints);

// 3. Leaderboard (Change from POST to GET)
// Your frontend uses apiClient.get('/points/leaderboard'), so this must be .get
router.get("/leaderboard", auth(["customer"]), getLeaderboard);

export default router;