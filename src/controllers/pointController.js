// src/controllers/pointController.js
import db from "../config/db.js";

/**
 * REDEEM POINTS TO CASH
 * Logic: 10 Points = 1 BDT (৳)
 * Minimum: 100 Points
 */
export const redeemPoints = async (req, res) => {
    const conn = await db.getConnection();
    try {
        await conn.beginTransaction();
        const { id: userId } = req.user;
        const { pointsToRedeem } = req.body;

        if (!pointsToRedeem || pointsToRedeem < 100) {
            return res.status(400).json({
                success: false,
                message: "Minimum 100 points required to redeem (৳10 value)."
            });
        }

        // 1. Fetch Customer Points with Row Lock
        const [customer] = await conn.query(
            "SELECT id, total_points FROM customers WHERE user_id = ? FOR UPDATE",
            [userId]
        );

        if (!customer.length || customer[0].total_points < pointsToRedeem) {
            return res.status(400).json({
                success: false,
                message: "Insufficient points balance."
            });
        }

        // 2. Conversion Formula (10:1)
        const cashValue = pointsToRedeem / 10;

        // 3. Deduct Points & Log Point Transaction
        await conn.query(
            "UPDATE customers SET total_points = total_points - ? WHERE id = ?",
            [pointsToRedeem, customer[0].id]
        );

        const [pointTx] = await conn.query(
            `INSERT INTO point_transactions (customer_id, amount, type, description) 
             VALUES (?, ?, 'redemption', ?)`,
            [
                customer[0].id,
                -pointsToRedeem,
                `Converted ${pointsToRedeem} points to ৳${cashValue} cash`
            ]
        );

        // 4. Credit Wallet Account with Row Lock
        const [wallet] = await conn.query(
            "SELECT id, balance FROM wallet_accounts WHERE user_id = ? FOR UPDATE",
            [userId]
        );

        if (!wallet.length) {
            throw new Error("Wallet account not found.");
        }

        const balanceBefore = parseFloat(wallet[0].balance);
        const balanceAfter = balanceBefore + cashValue;

        // 5. Update Wallet Balance
        await conn.query(
            "UPDATE wallet_accounts SET balance = ?, updated_at = NOW() WHERE id = ?",
            [balanceAfter, wallet[0].id]
        );

        // 6. Log Wallet Transaction (Bilingual for Audit Trail)
        await conn.query(
            `INSERT INTO wallet_transactions 
            (wallet_id, type, source, reference_type, reference_id, amount, balance_before, balance_after, description_en, description_bn, status) 
            VALUES (?, 'credit', 'point_redemption', 'point_transaction', ?, ?, ?, ?, ?, ?, 'completed')`,
            [
                wallet[0].id,
                pointTx.insertId,
                cashValue,
                balanceBefore,
                balanceAfter,
                `Redeemed ${pointsToRedeem} Green Points`,
                `${pointsToRedeem} গ্রিন পয়েন্ট রিডিম করা হয়েছে`,
            ]
        );

        await conn.commit();
        res.json({
            success: true,
            message: `Success! ৳${cashValue} has been added to your wallet.`,
            data: {
                new_points_balance: customer[0].total_points - pointsToRedeem,
                added_cash: cashValue,
                current_wallet_balance: balanceAfter
            }
        });

    } catch (err) {
        await conn.rollback();
        console.error("Redeem Error:", err);
        res.status(500).json({ success: false, message: "Internal server error during redemption." });
    } finally {
        conn.release();
    }
};

/**
 * AWARD REFERRAL BONUS
 * Logic: Award points to the referrer when a new user joins
 * Can be called internally from verifyAndRegister
 */
export const awardReferralBonus = async (referrerId, conn) => {
    const bonusPoints = 50; // Example: 50 points per referral

    await conn.query(
        "UPDATE customers SET total_points = total_points + ? WHERE id = ?",
        [bonusPoints, referrerId]
    );

    await conn.query(
        `INSERT INTO point_transactions (customer_id, amount, type, description) 
         VALUES (?, ?, 'referral_bonus', ?)`,
        [referrerId, bonusPoints, "Referral bonus for inviting a new member"]
    );
};

/**
 * GET LEADERBOARD
 */
export const getLeaderboard = async (req, res) => {
    try {
        const [rows] = await db.query(`
            SELECT 
                u.id as user_id,
                u.full_name as name, 
                c.total_points as points,
                (SELECT COUNT(*) FROM customers WHERE referred_by = c.id) as referral_count
            FROM customers c
            INNER JOIN users u ON c.user_id = u.id
            WHERE u.is_active = 1
            ORDER BY c.total_points DESC
            LIMIT 10
        `);

        res.json({
            success: true,
            data: rows
        });
    } catch (err) {
        res.status(500).json({ success: false, message: "Failed to fetch leaderboard." });
    }
};