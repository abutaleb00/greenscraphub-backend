import db from "../config/db.js";
import ApiError from "../utils/ApiError.js";

// 1. Get current settings (To show in the Admin Panel form)
export const getSettings = async (req, res, next) => {
    try {
        const [rows] = await db.query("SELECT * FROM app_settings WHERE id = 1");
        if (!rows.length) throw new ApiError(404, "Settings not found");

        res.json({ success: true, data: rows[0] });
    } catch (err) {
        next(err);
    }
};

// 2. Update settings (When Admin clicks "Save" in the panel)
export const updateSettings = async (req, res, next) => {
    try {
        const {
            signup_bonus_points,
            referral_bonus_points,
            point_to_cash_rate,
            min_redeem_points,
            min_withdrawal_amount // 🔥 Added this
        } = req.body;

        await db.query(
            `UPDATE app_settings SET 
                signup_bonus_points = ?, 
                referral_bonus_points = ?, 
                point_to_cash_rate = ?, 
                min_redeem_points = ?,
                min_withdrawal_amount = ? 
             WHERE id = 1`,
            [signup_bonus_points, referral_bonus_points, point_to_cash_rate, min_redeem_points, min_withdrawal_amount]
        );

        res.json({ success: true, message: "Global settings deployed successfully!" });
    } catch (err) {
        next(err);
    }
};