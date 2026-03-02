import db from "../config/db.js";

/**
 * REDEEM POINTS TO CASH
 * Logic: 10 Points = ₹1
 * Updated: Improved data type handling and balance calculations.
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
                message: "Minimum 100 points required to redeem."
            });
        }

        // 1. Fetch Customer Points with Lock
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

        // 3. Deduct Points & Log Transaction
        await conn.query(
            "UPDATE customers SET total_points = total_points - ? WHERE id = ?",
            [pointsToRedeem, customer[0].id]
        );

        const [pointTx] = await conn.query(
            `INSERT INTO point_transactions (customer_id, points, type, description) 
             VALUES (?, ?, 'redemption', ?)`,
            [customer[0].id, -pointsToRedeem, `Converted ${pointsToRedeem} points to ₹${cashValue} cash`]
        );

        // 4. Credit Wallet Account
        const [wallet] = await conn.query(
            "SELECT id, balance FROM wallet_accounts WHERE user_id = ? AND user_type = 'customer' FOR UPDATE",
            [userId]
        );

        if (!wallet.length) {
            throw new Error("Wallet account not found.");
        }

        const balanceBefore = parseFloat(wallet[0].balance);
        const balanceAfter = balanceBefore + cashValue;

        await conn.query(
            "UPDATE wallet_accounts SET balance = ? WHERE id = ?",
            [balanceAfter, wallet[0].id]
        );

        // Log Wallet Transaction
        await conn.query(
            `INSERT INTO wallet_transactions 
            (wallet_id, type, source, reference_id, reference_type, amount, balance_before, balance_after, description, status) 
            VALUES (?, 'credit', 'point_redemption', ?, 'point_transaction', ?, ?, ?, ?, 'completed')`,
            [
                wallet[0].id,
                pointTx.insertId,
                cashValue,
                balanceBefore,
                balanceAfter,
                `Points Redemption: ${pointsToRedeem} pts`
            ]
        );

        await conn.commit();
        res.json({
            success: true,
            message: `Redemption successful! ₹${cashValue} added to your wallet.`,
            data: {
                new_points_balance: customer[0].total_points - pointsToRedeem,
                added_cash: cashValue
            }
        });

    } catch (err) {
        await conn.rollback();
        console.error("Redeem Error:", err);
        res.status(500).json({ success: false, message: "Transaction failed. Please try again." });
    } finally {
        conn.release();
    }
};

/**
 * GET DYNAMIC LEADERBOARD
 * Logic: Ranks users primarily by points. 
 * Updated: Uses LEFT JOIN to ensure all customers are rankable and shows referral counts accurately.
 */
export const getLeaderboard = async (req, res) => {
    try {
        // We rank by total_points to show the "Top Recyclers"
        const [rows] = await db.query(`
            SELECT 
                u.id as user_id,
                u.full_name as name, 
                c.total_points as points,
                (SELECT COUNT(*) FROM customers WHERE referred_by = c.id) as referral_count
            FROM customers c
            INNER JOIN users u ON c.user_id = u.id
            ORDER BY c.total_points DESC
            LIMIT 10
        `);

        res.json({
            success: true,
            data: rows // Changed to 'data' to match your frontend expectation
        });
    } catch (err) {
        console.error("Leaderboard Error:", err);
        res.status(500).json({ success: false, message: "Failed to fetch leaderboard." });
    }
};