import db from "../config/db.js";

/**
 * 1. REQUEST WITHDRAWAL (User: Customer, Rider, Agent)
 * Deducts balance immediately and creates a pending request.
 */
export const requestWithdrawal = async (req, res) => {
    const conn = await db.getConnection();
    try {
        await conn.beginTransaction();
        const { id: userId, role } = req.user;
        const { amount, method, account_details } = req.body;

        // Fetch and Lock Wallet
        const [wallet] = await conn.query(
            "SELECT id, balance FROM wallet_accounts WHERE user_id = ? AND user_type = ? FOR UPDATE",
            [userId, role]
        );

        if (!wallet.length || parseFloat(wallet[0].balance) < parseFloat(amount)) {
            return res.status(400).json({ success: false, message: "Insufficient balance." });
        }

        const balanceBefore = parseFloat(wallet[0].balance);
        const withdrawAmount = parseFloat(amount);
        const balanceAfter = balanceBefore - withdrawAmount;

        // A) Create Payout Request
        const [request] = await conn.query(
            `INSERT INTO payout_requests 
            (user_id, user_type, wallet_id, amount, method, account_details, status) 
            VALUES (?, ?, ?, ?, ?, ?, 'pending')`,
            [userId, role, wallet[0].id, withdrawAmount, method, JSON.stringify(account_details)]
        );

        // B) Update Wallet Balance (Immediate Debit)
        await conn.query(
            "UPDATE wallet_accounts SET balance = ?, updated_at = NOW() WHERE id = ?",
            [balanceAfter, wallet[0].id]
        );

        // C) Record Wallet Transaction
        await conn.query(
            `INSERT INTO wallet_transactions 
            (wallet_id, type, source, reference_type, reference_id, amount, balance_before, balance_after, description, status) 
            VALUES (?, 'debit', 'withdrawal', 'payout_request', ?, ?, ?, ?, ?, 'pending')`,
            [
                wallet[0].id,
                request.insertId,
                withdrawAmount,
                balanceBefore,
                balanceAfter,
                `Withdrawal request via ${method.toUpperCase()}`,
                'pending'
            ]
        );

        await conn.commit();
        res.status(201).json({ success: true, message: "Withdrawal request submitted." });
    } catch (err) {
        await conn.rollback();
        res.status(500).json({ success: false, message: err.message });
    } finally {
        conn.release();
    }
};

/**
 * 2. LIST USER PAYOUTS (Personal History)
 * Updated to handle potential schema mismatches
 */
export const listUserPayouts = async (req, res) => {
    try {
        const { id: userId, role } = req.user;

        // Log for debugging: Check if these values exist
        console.log(`[PAYOUT] Fetching for UserID: ${userId}, Role: ${role}`);

        const [rows] = await db.query(
            // Ensure these column names (user_id, user_type) match your SQL exactly
            "SELECT * FROM payout_requests WHERE user_id = ? ORDER BY created_at DESC",
            [userId]
        );

        res.json({ 
            success: true, 
            payouts: rows 
        });
    } catch (err) {
        // Detailed logging to your terminal so you can see the EXACT SQL error
        console.error("Database Error in listUserPayouts:", err.message);
        
        res.status(500).json({ 
            success: false, 
            message: "Failed to load payout history.",
            error: process.env.NODE_ENV === 'development' ? err.message : undefined
        });
    }
};

/**
 * 3. ADMIN: LIST ALL PAYOUTS
 */
export const adminListAllPayouts = async (req, res) => {
    try {
        const [rows] = await db.query(
            `SELECT p.*, u.full_name, u.phone 
             FROM payout_requests p 
             JOIN users u ON p.user_id = u.id 
             ORDER BY p.status = 'pending' DESC, p.created_at DESC`
        );
        res.json({ success: true, payouts: rows });
    } catch (err) {
        res.status(500).json({ success: false, message: "Server error." });
    }
};

/**
 * 4. ADMIN: PROCESS PAYOUT (Approve/Reject)
 */
export const processPayout = async (req, res) => {
    const conn = await db.getConnection();
    const { requestId } = req.params;
    const { status, admin_note, transaction_id } = req.body; // status: 'completed' or 'rejected'
    const adminId = req.user.id;

    try {
        await conn.beginTransaction();

        // Fetch Request
        const [request] = await conn.query(
            "SELECT * FROM payout_requests WHERE id = ? FOR UPDATE",
            [requestId]
        );

        if (!request.length || request[0].status !== 'pending') {
            throw new Error("Invalid request or already processed.");
        }

        const payout = request[0];

        if (status === 'completed') {
            // Finalize status (Balance was already deducted)
            await conn.query(
                `UPDATE payout_requests 
                 SET status = 'completed', transaction_id = ?, admin_note = ?, processed_by = ?, processed_at = NOW() 
                 WHERE id = ?`,
                [transaction_id, admin_note, adminId, requestId]
            );

            // Update original wallet transaction status
            await conn.query(
                "UPDATE wallet_transactions SET status = 'completed' WHERE reference_id = ? AND reference_type = 'payout_request'",
                [requestId]
            );
        }
        else if (status === 'rejected') {
            // REFUND LOGIC
            const [wallet] = await conn.query(
                "SELECT id, balance FROM wallet_accounts WHERE id = ? FOR UPDATE",
                [payout.wallet_id]
            );

            const balanceBefore = parseFloat(wallet[0].balance);
            const refundAmount = parseFloat(payout.amount);
            const balanceAfter = balanceBefore + refundAmount;

            // Update Wallet Balance
            await conn.query(
                "UPDATE wallet_accounts SET balance = ? WHERE id = ?",
                [balanceAfter, payout.wallet_id]
            );

            // Create Credit Transaction for Refund
            await conn.query(
                `INSERT INTO wallet_transactions 
                (wallet_id, type, source, reference_type, reference_id, amount, balance_before, balance_after, description, status) 
                VALUES (?, 'credit', 'refund', 'payout_request', ?, ?, ?, ?, ?, 'completed')`,
                [payout.wallet_id, requestId, refundAmount, balanceBefore, balanceAfter, `Refund: ${admin_note}`]
            );

            // Mark Request as Rejected
            await conn.query(
                "UPDATE payout_requests SET status = 'rejected', admin_note = ?, processed_by = ?, processed_at = NOW() WHERE id = ?",
                [admin_note, adminId, requestId]
            );
        }

        await conn.commit();
        res.json({ success: true, message: `Payout marked as ${status}.` });
    } catch (err) {
        await conn.rollback();
        res.status(500).json({ success: false, message: err.message });
    } finally {
        conn.release();
    }
};