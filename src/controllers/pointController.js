import db from "../config/db.js";

/**
 * REDEEM POINTS TO CASH
 * Logic: 10 Points = ₹1 (Adjust this ratio as needed)
 */
export const redeemPoints = async (req, res) => {
    const conn = await db.getConnection();
    try {
        await conn.beginTransaction();
        const { id: userId } = req.user;
        const { pointsToRedeem } = req.body; // e.g., 500 points

        if (!pointsToRedeem || pointsToRedeem < 100) {
            return res.status(400).json({ success: false, message: "Minimum 100 points required to redeem." });
        }

        // 1. Fetch Customer Points
        const [customer] = await conn.query(
            "SELECT id, total_points FROM customers WHERE user_id = ? FOR UPDATE",
            [userId]
        );

        if (!customer.length || customer[0].total_points < pointsToRedeem) {
            return res.status(400).json({ success: false, message: "Insufficient points balance." });
        }

        // 2. Conversion Formula (10:1)
        const cashValue = pointsToRedeem / 10;

        // 3. Deduct Points & Log Transaction
        await conn.query(
            "UPDATE customers SET total_points = total_points - ? WHERE id = ?",
            [pointsToRedeem, customer[0].id]
        );

        await conn.query(
            `INSERT INTO point_transactions (customer_id, amount, type, description) 
             VALUES (?, ?, 'redemption', ?)`,
            [customer[0].id, -pointsToRedeem, `Converted ${pointsToRedeem} points to ₹${cashValue} cash`]
        );

        // 4. Credit Wallet Account
        // Fetch wallet ID
        const [wallet] = await conn.query(
            "SELECT id, balance FROM wallet_accounts WHERE user_id = ? AND user_type = 'customer' FOR UPDATE",
            [userId]
        );

        const balanceBefore = parseFloat(wallet[0].balance);
        const balanceAfter = balanceBefore + cashValue;

        await conn.query(
            "UPDATE wallet_accounts SET balance = ? WHERE id = ?",
            [balanceAfter, wallet[0].id]
        );

        // Log Wallet Transaction
        await conn.query(
            `INSERT INTO wallet_transactions 
            (wallet_id, type, source, reference_type, amount, balance_before, balance_after, description, status) 
            VALUES (?, 'credit', 'point_redemption', 'point_transaction', ?, ?, ?, ?, 'completed')`,
            [wallet[0].id, cashValue, balanceBefore, balanceAfter, `Points Redemption: ${pointsToRedeem} pts`]
        );

        await conn.commit();
        res.json({
            success: true,
            message: `Redemption successful! ₹${cashValue} added to your wallet.`,
            new_points_balance: customer[0].total_points - pointsToRedeem
        });

    } catch (err) {
        await conn.rollback();
        res.status(500).json({ success: false, message: err.message });
    } finally {
        conn.release();
    }
};

/**
 * GET REFERRAL LEADERBOARD
 * Ranks users based on the number of successful referrals.
 */
export const getLeaderboard = async (req, res) => {
    try {
        const [rows] = await db.query(`
            SELECT 
                u.full_name, 
                u.id as user_id,
                COUNT(c_referred.id) as referral_count,
                MAX(c.total_points) as points
            FROM users u
            JOIN customers c ON u.id = c.user_id
            JOIN customers c_referred ON c.id = c_referred.referred_by
            GROUP BY u.id
            ORDER BY referral_count DESC
            LIMIT 10
        `);

        res.json({
            success: true,
            leaderboard: rows
        });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};