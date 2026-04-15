// src/controllers/walletController.js
import db from '../config/db.js';

/**
 * 1. GET WALLET SUMMARY (Balance + Recent History)
 * Auto-creates wallet if missing and returns localized transaction descriptions.
 */
export const getWalletSummary = async (req, res) => {
    const conn = await db.getConnection();
    try {
        const { id: userId, role } = req.user;

        // 1. Fetch Wallet Account with Row Lock for precision
        let [account] = await conn.query(
            "SELECT * FROM wallet_accounts WHERE user_id = ? FOR UPDATE",
            [userId]
        );

        // Auto-create wallet if it doesn't exist (e.g., legacy users)
        if (!account.length) {
            const [ins] = await conn.query(
                "INSERT INTO wallet_accounts (user_id, balance, currency) VALUES (?, 0, 'BDT')",
                [userId]
            );
            account = [{
                id: ins.insertId,
                balance: 0,
                currency: 'BDT',
                total_withdrawn: 0
            }];
        }

        const walletId = account[0].id;

        // 2. Fetch Recent Transactions (Limit 15 for a "Summary" view)
        // We select both EN and BN descriptions for frontend flexibility
        const [transactions] = await conn.query(
            `SELECT 
                id, type, source, amount, 
                balance_before, balance_after, 
                description_en, description_bn, 
                status, created_at 
             FROM wallet_transactions 
             WHERE wallet_id = ? 
             ORDER BY created_at DESC LIMIT 15`,
            [walletId]
        );

        res.json({
            success: true,
            data: {
                wallet: {
                    id: account[0].id,
                    balance: parseFloat(account[0].balance),
                    total_withdrawn: parseFloat(account[0].total_withdrawn || 0),
                    currency: account[0].currency,
                    last_updated: account[0].updated_at
                },
                recent_transactions: transactions
            }
        });
    } catch (err) {
        console.error("Wallet Summary Error:", err);
        res.status(500).json({ success: false, message: "Failed to retrieve wallet data" });
    } finally {
        conn.release();
    }
};

/**
 * 2. GET ALL TRANSACTIONS (Paginated)
 * Full ledger history for the user.
 */
export const getWalletTransactions = async (req, res, next) => {
    try {
        const { id: userId } = req.user;
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 20;
        const offset = (page - 1) * limit;

        // Fetch wallet ID
        const [wallet] = await db.query(
            "SELECT id FROM wallet_accounts WHERE user_id = ?",
            [userId]
        );

        if (!wallet.length) {
            return res.json({ success: true, data: [], pagination: { page, total: 0 } });
        }

        // Fetch paginated transactions
        const [transactions] = await db.query(
            `SELECT * FROM wallet_transactions 
             WHERE wallet_id = ? 
             ORDER BY created_at DESC 
             LIMIT ? OFFSET ?`,
            [wallet[0].id, limit, offset]
        );

        // Get total count for frontend pagination
        const [count] = await db.query(
            "SELECT COUNT(*) as total FROM wallet_transactions WHERE wallet_id = ?",
            [wallet[0].id]
        );

        res.json({
            success: true,
            data: transactions,
            pagination: {
                current_page: page,
                per_page: limit,
                total_records: count[0].total
            }
        });
    } catch (err) {
        next(err);
    }
};

/**
 * 3. GET ADMIN WALLET OVERVIEW (Admin Only)
 * Allows Admin to see total platform liability (sum of all balances).
 */
export const getAdminWalletStats = async (req, res) => {
    try {
        const [stats] = await db.query(`
            SELECT 
                SUM(balance) as total_platform_balance,
                COUNT(id) as total_wallets,
                (SELECT SUM(amount) FROM wallet_transactions WHERE type = 'credit' AND status = 'completed') as total_earnings_processed,
                (SELECT SUM(amount) FROM wallet_transactions WHERE source = 'withdrawal' AND status = 'completed') as total_payouts_made
            FROM wallet_accounts
        `);

        res.json({
            success: true,
            data: stats[0]
        });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};

/**
 * GET WALLET BALANCE
 * Specific for Agent/Rider/Customer to see real-time balance + pending withdrawals
 */
export const getWalletBalance = async (req, res) => {
    try {
        const userId = req.user.id;

        // 1. Fetch main wallet data
        const [wallets] = await db.query(
            "SELECT balance, total_withdrawn FROM wallet_accounts WHERE user_id = ?",
            [userId]
        );

        // If no wallet exists yet, return a clean zeroed object
        if (!wallets.length) {
            return res.json({
                success: true,
                data: { balance: 0, pending: 0, total_withdrawn: 0 }
            });
        }

        // 2. Fetch pending payouts to calculate "Money in Transit"
        const [pendingPayouts] = await db.query(
            "SELECT SUM(amount) as pending FROM payout_requests WHERE user_id = ? AND status = 'pending'",
            [userId]
        );

        res.json({
            success: true,
            data: {
                balance: wallets[0].balance,
                total_withdrawn: wallets[0].total_withdrawn,
                pending: pendingPayouts[0].pending || 0
            }
        });
    } catch (err) {
        console.error("Wallet Balance Error:", err.message);
        res.status(500).json({ success: false, message: "Server error fetching balance" });
    }
};