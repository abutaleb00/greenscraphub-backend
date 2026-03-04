import db from "../config/db.js";
import ApiError from "../utils/ApiError.js";

/**
 * 1. REDEEM POINTS TO CASH (Customer Only)
 * Logic: 10 Points = 1 BDT (৳) | Minimum: 100 Points
 */
export const redeemPoints = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        await conn.beginTransaction();
        const { id: userId, role } = req.user;
        const { pointsToRedeem } = req.body;

        // Role Protection: Only customers typically earn/redeem green points
        if (role !== 'customer') {
            throw new ApiError(403, "Only customers can redeem green points for cash.");
        }

        if (!pointsToRedeem || pointsToRedeem < 100) {
            throw new ApiError(400, "Minimum 100 points required to redeem (৳10 value).");
        }

        // 1. Fetch Customer Points with Row Lock
        const [customer] = await conn.query(
            "SELECT id, total_points FROM customers WHERE user_id = ? FOR UPDATE",
            [userId]
        );

        if (!customer.length || customer[0].total_points < pointsToRedeem) {
            throw new ApiError(400, "Insufficient points balance.");
        }

        // 2. Conversion Formula (10:1)
        const cashValue = pointsToRedeem / 10;

        // 3. Deduct Points & Log Point Transaction
        await conn.query(
            "UPDATE customers SET total_points = total_points - ? WHERE id = ?",
            [pointsToRedeem, customer[0].id]
        );

        const [pointTx] = await conn.query(
            `INSERT INTO point_transactions (customer_id, amount, type, description, created_at) 
             VALUES (?, ?, 'redemption', ?, NOW())`,
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
            throw new ApiError(404, "Wallet account not found. Please contact support.");
        }

        const balanceBefore = parseFloat(wallet[0].balance);
        const balanceAfter = balanceBefore + cashValue;

        // 5. Update Wallet Balance
        await conn.query(
            "UPDATE wallet_accounts SET balance = ?, updated_at = NOW() WHERE id = ?",
            [balanceAfter, wallet[0].id]
        );

        // 6. Log Wallet Transaction for Audit Trail
        await conn.query(
            `INSERT INTO wallet_transactions 
            (wallet_id, type, source, reference_type, reference_id, amount, balance_before, balance_after, description_en, description_bn, status, created_at) 
            VALUES (?, 'credit', 'point_redemption', 'point_transaction', ?, ?, ?, ?, ?, ?, 'completed', NOW())`,
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
        res.status(200).json({
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
        next(err);
    } finally {
        conn.release();
    }
};

/**
 * 2. AWARD REFERRAL BONUS
 * Triggered internally when a new customer registers with a ref code
 */
export const awardReferralBonus = async (referrerId, conn) => {
    const bonusPoints = 50;

    // Update Referrer Points
    await conn.query(
        "UPDATE customers SET total_points = total_points + ? WHERE id = ?",
        [bonusPoints, referrerId]
    );

    // Log the transaction
    await conn.query(
        `INSERT INTO point_transactions (customer_id, amount, type, description, created_at) 
         VALUES (?, ?, 'referral_bonus', ?, NOW())`,
        [referrerId, bonusPoints, "Referral bonus for inviting a new member"]
    );
};

/**
 * 3. GET GLOBAL LEADERBOARD
 * Accessible by all users to encourage competition
 */
export const getLeaderboard = async (req, res, next) => {
    try {
        const [rows] = await db.query(`
            SELECT 
                u.id as user_id,
                u.full_name as name, 
                c.total_points as points,
                -- Count how many people this specific customer referred
                (SELECT COUNT(*) FROM customers WHERE referred_by = c.id) as referral_count
            FROM customers c
            INNER JOIN users u ON c.user_id = u.id
            -- Join roles table to filter by the name 'customer' dynamically
            INNER JOIN roles r ON u.role_id = r.id
            WHERE u.is_active = 1 
              AND r.name = 'customer' 
            ORDER BY c.total_points DESC
            LIMIT 10
        `);

        res.json({
            success: true,
            data: rows
        });
    } catch (err) {
        // Log the error for internal debugging
        console.error("Leaderboard Fetch Error:", err);
        next(err);
    }
};

/**
 * 4. GET POINT HISTORY (Specific to Logged in User)
 */
export const getMyPointHistory = async (req, res, next) => {
    try {
        const { id: userId, role } = req.user;

        // Find customer ID first
        const [customer] = await db.query("SELECT id FROM customers WHERE user_id = ?", [userId]);
        if (!customer.length) throw new ApiError(404, "Customer profile not found.");

        const [history] = await db.query(
            "SELECT * FROM point_transactions WHERE customer_id = ? ORDER BY created_at DESC",
            [customer[0].id]
        );

        res.json({ success: true, data: history });
    } catch (err) {
        next(err);
    }
};

/**
 * 5. ADMIN: MANUAL POINT ADJUSTMENT
 * For customer support issues or special rewards
 */
export const adminAdjustPoints = async (req, res, next) => {
    try {
        const { customer_id, amount, reason } = req.body;

        if (req.user.role !== 'admin') {
            throw new ApiError(403, "Unauthorized: Admin access only.");
        }

        await db.query(
            "UPDATE customers SET total_points = total_points + ? WHERE id = ?",
            [amount, customer_id]
        );

        await db.query(
            `INSERT INTO point_transactions (customer_id, amount, type, description, created_at) 
             VALUES (?, ?, 'adjustment', ?, NOW())`,
            [customer_id, amount, `Admin Adjustment: ${reason}`]
        );

        res.json({ success: true, message: "Points adjusted successfully." });
    } catch (err) {
        next(err);
    }
};