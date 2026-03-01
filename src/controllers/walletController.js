import db from "../config/db.js";

export const getWalletSummary = async (req, res) => {
    const conn = await db.getConnection();
    try {
        const { id: userId, role } = req.user;

        // 1. Get or Auto-Create Wallet Account
        let [account] = await conn.query(
            "SELECT * FROM wallet_accounts WHERE user_id = ? AND user_type = ?",
            [userId, role]
        );

        if (!account.length) {
            const [ins] = await conn.query(
                "INSERT INTO wallet_accounts (user_id, user_type, balance, currency) VALUES (?, ?, 0, 'BDT')",
                [userId, role]
            );
            account = [{ id: ins.insertId, balance: 0, currency: 'BDT' }];
        }

        const walletId = account[0].id;

        // 2. Fetch Transactions using your reference_id logic
        const [transactions] = await conn.query(
            `SELECT * FROM wallet_transactions 
             WHERE wallet_id = ? 
             ORDER BY created_at DESC LIMIT 50`,
            [walletId]
        );

        res.json({
            success: true,
            account: account[0],
            transactions: transactions
        });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    } finally {
        conn.release();
    }
};