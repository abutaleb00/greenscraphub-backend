// src/controllers/payoutController.js
import db from '../config/db.js';
import ApiError from '../utils/ApiError.js';

/**
 * NEW: GET WITHDRAWAL SETTINGS
 * Fetches the dynamic minimum withdrawal amount from system_settings table.
 */
export const getWithdrawalSettings = async (req, res) => {
    try {
        const [rows] = await db.query(
            "SELECT setting_value FROM system_settings WHERE setting_key = 'min_withdrawal_amount'"
        );
        // Fallback to 500 if not set in DB
        const minAmount = rows.length ? parseFloat(rows[0].setting_value) : 500;

        res.json({
            success: true,
            min_withdrawal_amount: minAmount
        });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};
/**
 * 1. REQUEST WITHDRAWAL (Customer, Rider, Agent)
 * Deducts balance immediately to prevent double-spending.
 */
export const requestWithdrawal = async (req, res) => {
    const conn = await db.getConnection();
    try {
        await conn.beginTransaction();
        const { id: userId } = req.user;
        const { amount, method, account_details } = req.body;

        // --- A. FETCH DYNAMIC LIMIT FROM APP_SETTINGS ---
        // We changed the source table to 'app_settings' and the column name to 'min_withdrawal_amount'
        const [settings] = await conn.query(
            "SELECT min_withdrawal_amount FROM app_settings WHERE id = 1 LIMIT 1"
        );

        // Fallback to 500 if the table is empty for some reason
        const dynamicMin = settings.length ? parseFloat(settings[0].min_withdrawal_amount) : 500;

        if (parseFloat(amount) < dynamicMin) {
            // This will now correctly say ৳10 if that's what you set in the Admin Panel
            throw new ApiError(400, `Minimum withdrawal amount is ৳${dynamicMin}`);
        }

        // --- B. FETCH AND LOCK WALLET ---
        const [wallet] = await conn.query(
            "SELECT id, balance FROM wallet_accounts WHERE user_id = ? FOR UPDATE",
            [userId]
        );

        if (!wallet.length || parseFloat(wallet[0].balance) < parseFloat(amount)) {
            throw new ApiError(400, "Insufficient balance for this withdrawal.");
        }

        const balanceBefore = parseFloat(wallet[0].balance);
        const withdrawAmount = parseFloat(amount);
        const balanceAfter = balanceBefore - withdrawAmount;

        // --- C. CREATE PAYOUT REQUEST ---
        const [request] = await conn.query(
            `INSERT INTO payout_requests 
            (user_id, amount, payment_method, account_details, status, requested_at) 
            VALUES (?, ?, ?, ?, 'pending', NOW())`,
            [userId, withdrawAmount, method, JSON.stringify(account_details)]
        );
        const requestId = request.insertId;

        // --- D. UPDATE WALLET BALANCE ---
        await conn.query(
            "UPDATE wallet_accounts SET balance = ?, updated_at = NOW() WHERE id = ?",
            [balanceAfter, wallet[0].id]
        );

        // --- E. RECORD TRANSACTION ---
        await conn.query(
            `INSERT INTO wallet_transactions 
            (wallet_id, type, source, reference_type, reference_id, amount, balance_before, balance_after, description_en, description_bn, status, created_at) 
            VALUES (?, 'debit', 'withdrawal', 'payout_request', ?, ?, ?, ?, ?, ?, 'pending', NOW())`,
            [
                wallet[0].id, requestId, withdrawAmount, balanceBefore, balanceAfter,
                `Withdrawal request via ${method.toUpperCase()}`,
                `${method.toUpperCase()} এর মাধ্যমে উত্তোলনের অনুরোধ`,
            ]
        );

        await conn.commit();
        res.status(201).json({
            success: true,
            message: "Withdrawal request submitted successfully.",
            data: { request_id: requestId, remaining_balance: balanceAfter }
        });
    } catch (err) {
        await conn.rollback();
        // Standardizing error handling
        if (err instanceof ApiError) {
            res.status(err.statusCode).json({ success: false, message: err.message });
        } else {
            res.status(500).json({ success: false, message: err.message });
        }
    } finally {
        conn.release();
    }
};

/**
 * 2. LIST USER PAYOUTS (Personal History)
 */
export const listUserPayouts = async (req, res) => {
    try {
        const { id: userId } = req.user;

        // MATCHING SQL TO YOUR TABLE FIELDS:
        // 'payment_method' becomes 'method'
        // 'requested_at' becomes 'created_at'
        const [rows] = await db.query(
            `SELECT 
                p.id, 
                p.amount, 
                p.payment_method AS method, 
                p.status, 
                p.account_details AS account_details, 
                p.admin_note, 
                p.transaction_id,
                p.requested_at AS created_at 
             FROM payout_requests p 
             WHERE p.user_id = ? 
             ORDER BY p.requested_at DESC`,
            [userId]
        );

        res.json({ success: true, data: rows });
    } catch (err) {
        console.error("PAYOUT_HISTORY_ERROR:", err.message);
        res.status(500).json({ success: false, message: "Database error: " + err.message });
    }
};

/**
 * 3. ADMIN: LIST ALL PAYOUTS
 */
export const adminListAllPayouts = async (req, res) => {
    try {
        const { status } = req.query;

        // Note: Change 'u.full_name' to 'u.name' if your users table uses 'name'
        let query = `
            SELECT 
                p.*, 
                u.full_name AS full_name, 
                u.phone, 
                COALESCE(w.balance, 0) as current_wallet_balance
            FROM payout_requests p 
            JOIN users u ON p.user_id = u.id 
            LEFT JOIN wallet_accounts w ON u.id = w.user_id
        `;

        const params = [];
        // Handle the 'all' case or specific status filters
        if (status && status !== 'all') {
            query += " WHERE p.status = ?";
            params.push(status);
        }

        // Professional Sorting: Pending first, then by date
        query += " ORDER BY (p.status = 'pending') DESC";

        const [rows] = await db.query(query, params);

        res.json({
            success: true,
            data: rows
        });
    } catch (err) {
        // Log the exact error to your terminal for debugging
        console.error("ADMIN PAYOUT FETCH ERROR:", err.message);
        res.status(500).json({
            success: false,
            message: "Internal Server Error: " + err.message
        });
    }
};

/**
 * 4. ADMIN: PROCESS PAYOUT (Approve/Reject)
 */
export const processPayout = async (req, res, next) => {
    const conn = await db.getConnection();
    const { requestId } = req.params;
    const { status, admin_note, transaction_id } = req.body; // status: 'completed' or 'rejected'
    const adminId = req.user.id;

    try {
        await conn.beginTransaction();

        // 1. Fetch Request with Row Lock
        const [request] = await conn.query(
            "SELECT * FROM payout_requests WHERE id = ? FOR UPDATE",
            [requestId]
        );

        if (!request.length || request[0].status !== 'pending') {
            throw new ApiError(400, "Request not found or already processed.");
        }

        const payout = request[0];

        if (status === 'completed') {
            // MANUAL CHECK: Admin must provide the bKash/Bank TrxID
            if (!transaction_id) {
                throw new ApiError(400, "Transaction ID is required for manual payout completion.");
            }

            // A) Finalize Payout Record
            await conn.query(
                `UPDATE payout_requests 
                 SET status = 'completed', transaction_id = ?, admin_note = ?, processed_by = ?, processed_at = NOW() 
                 WHERE id = ?`,
                [transaction_id, admin_note, adminId, requestId]
            );

            // B) Mark the wallet transaction as completed (Balance was deducted during request)
            await conn.query(
                "UPDATE wallet_transactions SET status = 'completed' WHERE reference_id = ? AND reference_type = 'payout_request'",
                [requestId]
            );
        }
        else if (status === 'rejected') {
            // REFUND LOGIC: Give money back to user wallet
            const [wallet] = await conn.query(
                "SELECT id, balance FROM wallet_accounts WHERE id = ? FOR UPDATE",
                [payout.wallet_id]
            );

            const balanceBefore = parseFloat(wallet[0].balance);
            const refundAmount = parseFloat(payout.amount);
            const balanceAfter = balanceBefore + refundAmount;

            await conn.query(
                "UPDATE wallet_accounts SET balance = ?, updated_at = NOW() WHERE id = ?",
                [balanceAfter, payout.wallet_id]
            );

            // Create Refund Transaction Log (Bilingual)
            await conn.query(
                `INSERT INTO wallet_transactions 
                (wallet_id, type, source, reference_type, reference_id, amount, balance_before, balance_after, description_en, description_bn, status) 
                VALUES (?, 'credit', 'refund', 'payout_request', ?, ?, ?, ?, ?, ?, 'completed')`,
                [
                    payout.wallet_id, requestId, refundAmount, balanceBefore, balanceAfter,
                    `Refund for rejected payout #${requestId}`,
                    `বাতিলকৃত পেমেন্ট #${requestId} এর রিফান্ড`
                ]
            );

            // Mark Request as Rejected
            await conn.query(
                "UPDATE payout_requests SET status = 'rejected', admin_note = ?, processed_by = ?, processed_at = NOW() WHERE id = ?",
                [admin_note, adminId, requestId]
            );
        }

        await conn.commit();
        res.json({ success: true, message: `Payout successfully marked as ${status}.` });

    } catch (err) {
        await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};