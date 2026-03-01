// src/controllers/pickupController.js

import db from "../config/db.js";
import path from "path";
import fs from "fs";

/**
 * Helper: Find nearest available rider using Haversine formula
 */
const getNearestRider = async (conn, lat, lng) => {
    const [riders] = await conn.query(`
        SELECT r.id, r.agent_id, 
        (6371 * acos(cos(radians(?)) * cos(radians(r.current_latitude)) * cos(radians(r.current_longitude) - radians(?)) + sin(radians(?)) * sin(radians(r.current_latitude)))) AS distance 
        FROM riders r 
        WHERE r.status = 'active' AND r.is_available = 1
        ORDER BY distance ASC LIMIT 1
    `, [lat, lng, lat]);
    return riders.length ? riders[0] : null;
};

/**
 * 1. CREATE PICKUP REQUEST
 */
export const createPickup = async (req, res) => {
    const conn = await db.getConnection();
    try {
        await conn.beginTransaction();
        const userId = req.user.id;

        const {
            pickup_address,
            latitude,
            longitude,
            items,
            scheduled_date,
            scheduled_time_slot,
            customer_note,
            area,
            city
        } = req.body;

        if (!pickup_address || !latitude || !longitude) {
            return res.status(400).json({ success: false, message: "Pickup location is mandatory." });
        }

        let parsedItems = JSON.parse(items);

        // Ensure Customer Profile
        let [customer] = await conn.query("SELECT id FROM customers WHERE user_id = ?", [userId]);
        if (!customer.length) {
            const [insert] = await conn.query("INSERT INTO customers (user_id) VALUES (?)", [userId]);
            customer = [{ id: insert.insertId }];
        }
        const customerId = customer[0].id;

        // Auto-assign nearest rider
        const nearest = await getNearestRider(conn, latitude, longitude);
        const riderId = nearest ? nearest.id : null;
        const agentId = nearest ? nearest.agent_id : null;

        // Financial Calculation
        let totalMin = 0;
        let totalMax = 0;
        let totalWeight = 0;

        for (const item of parsedItems) {
            const [scrap] = await conn.query(
                "SELECT min_price_per_unit, max_price_per_unit FROM scrap_items WHERE id = ?",
                [item.scrap_item_id]
            );
            const weight = parseFloat(item.estimated_weight) || 0;
            totalMin += scrap[0].min_price_per_unit * weight;
            totalMax += scrap[0].max_price_per_unit * weight;
            totalWeight += weight;
        }

        // Create Master Pickup
        const bookingCode = "PK" + Date.now();
        const [pickupResult] = await conn.query(
            `INSERT INTO pickups (
                booking_code, customer_id, pickup_address, agent_id, rider_id, 
                status, scheduled_date, scheduled_time_slot, pickup_latitude, 
                pickup_longitude, customer_note, estimated_min_amount, 
                estimated_max_amount, pickup_type, created_at
            ) VALUES (?, ?, ?, ?, ?, 'pending', ?, ?, ?, ?, ?, ?, ?, 'scheduled', NOW())`,
            [bookingCode, customerId, pickup_address, agentId, riderId, scheduled_date, scheduled_time_slot, latitude, longitude, customer_note, totalMin, totalMax]
        );
        const pickupId = pickupResult.insertId;

        // Process Items & Photos
        const files = req.files || [];
        for (let i = 0; i < parsedItems.length; i++) {
            const fieldName = `item_photos[${i}]`;
            const photoPaths = files
                .filter(f => f.fieldname === fieldName)
                .map(f => f.path.replace(/\\/g, '/').replace('public/', ''));

            await conn.query(
                `INSERT INTO pickup_items (
                    pickup_id, scrap_item_id, estimated_weight, 
                    estimated_min_amount, estimated_max_amount, photo_url
                ) VALUES (?, ?, ?, ?, ?, ?)`,
                [pickupId, parsedItems[i].scrap_item_id, parsedItems[i].estimated_weight, totalMin, totalMax, JSON.stringify(photoPaths)]
            );
        }

        // Update Stats
        await conn.query(
            `INSERT INTO pickup_area_stats (area, city, agent_id, total_pickups, total_weight, total_amount, period_date, created_at) 
             VALUES (?, ?, ?, 1, ?, ?, CURDATE(), NOW())
             ON DUPLICATE KEY UPDATE total_pickups = total_pickups + 1, total_weight = total_weight + VALUES(total_weight), total_amount = total_amount + VALUES(total_amount)`,
            [area || "General", city || "Unknown", agentId, totalWeight, totalMax]
        );

        await conn.commit();
        res.status(201).json({ success: true, message: "Request Live!", data: { booking_code: bookingCode, pickup_id: pickupId } });
    } catch (err) {
        await conn.rollback();
        res.status(500).json({ success: false, message: err.message });
    } finally {
        conn.release();
    }
};

/**
 * 2. LIST PICKUPS (Customer)
 */
export const listCustomerPickups = async (req, res) => {
    try {
        const userId = req.user.id;
        const [rows] = await db.query(
            `SELECT p.id, p.booking_code, p.status, p.estimated_min_amount, p.estimated_max_amount, p.scheduled_date, p.scheduled_time_slot, p.created_at
             FROM pickups p JOIN customers c ON c.id = p.customer_id
             WHERE c.user_id = ? ORDER BY p.created_at DESC`, [userId]
        );
        res.json({ success: true, pickups: rows });
    } catch (err) {
        res.status(500).json({ success: false, message: "Server error" });
    }
};

/**
 * 3. GET PICKUP DETAILS
 */
export const getPickupDetails = async (req, res) => {
    try {
        const [pickupRows] = await db.query(
            `SELECT p.*, u.full_name AS customer_name, au.full_name AS rider_name, ag.name AS agent_name
             FROM pickups p 
             JOIN customers c ON c.id = p.customer_id JOIN users u ON u.id = c.user_id
             LEFT JOIN riders r ON r.id = p.rider_id LEFT JOIN users au ON au.id = r.user_id
             LEFT JOIN agents ag ON ag.id = p.agent_id WHERE p.id = ?`, [req.params.id]
        );

        if (!pickupRows.length) return res.status(404).json({ success: false, message: "Not found" });

        const [items] = await db.query(
            `SELECT pi.*, si.name AS scrap_item_name, si.unit 
             FROM pickup_items pi JOIN scrap_items si ON si.id = pi.scrap_item_id
             WHERE pi.pickup_id = ?`, [req.params.id]
        );

        items.forEach(item => { item.photo_urls = JSON.parse(item.photo_url || "[]"); });
        res.json({ success: true, pickup: pickupRows[0], items });
    } catch (err) {
        res.status(500).json({ success: false, message: "Server error" });
    }
};

/**
 * 4. UPDATE STATUS
 */
export const updatePickupStatus = async (req, res) => {
    try {
        const { status } = req.body;
        const timestampMap = {
            assigned: "assigned_at",
            rider_on_way: "assigned_at",
            arrived: "rider_arrived_at",
            weighing: "weighing_started_at",
            completed: "completed_at"
        };

        await db.query(
            `UPDATE pickups SET status = ?, ${timestampMap[status] || 'updated_at'} = NOW() WHERE id = ?`,
            [status, req.params.id]
        );
        res.json({ success: true, message: "Status updated" });
    } catch (err) {
        res.status(500).json({ success: false, message: "Server error" });
    }
};

/**
 * HELPER: Atomic Wallet Update
 * Handles balance math and transaction logging for any user role.
 */
const updateWallet = async (conn, userId, role, amount, type, source, refId, desc) => {
    // 1. Lock the wallet row to prevent balance race conditions
    let [wallet] = await conn.query(
        "SELECT id, balance FROM wallet_accounts WHERE user_id = ? AND user_type = ? FOR UPDATE",
        [userId, role]
    );

    // Auto-create wallet if it doesn't exist for this user
    if (!wallet.length) {
        const [ins] = await conn.query(
            "INSERT INTO wallet_accounts (user_id, user_type, balance) VALUES (?, ?, 0)",
            [userId, role]
        );
        wallet = [{ id: ins.insertId, balance: 0 }];
    }

    const balanceBefore = parseFloat(wallet[0].balance);
    const balanceAfter = type === 'credit' ? balanceBefore + amount : balanceBefore - amount;

    // 2. Update the account balance
    await conn.query(
        "UPDATE wallet_accounts SET balance = ?, updated_at = NOW() WHERE id = ?",
        [balanceAfter, wallet[0].id]
    );

    // 3. Record the movement in wallet_transactions
    await conn.query(
        `INSERT INTO wallet_transactions 
        (wallet_id, type, source, reference_type, reference_id, amount, balance_before, balance_after, description, status) 
        VALUES (?, ?, ?, 'pickup', ?, ?, ?, ?, ?, 'completed')`,
        [wallet[0].id, type, source, refId, amount, balanceBefore, balanceAfter, desc]
    );
};

/**
 * MAIN: Complete Pickup
 * Includes: Commissions, Loyalty Points, and Delayed Referral Rewards
 */
export const completePickup = async (req, res) => {
    const conn = await db.getConnection();
    const { id: pickupId } = req.params;

    try {
        await conn.beginTransaction();

        // 1. Fetch Pickup & Participants (Added referred_by and customer_name)
        const [p] = await conn.query(`
            SELECT p.*, 
                   c.id as customer_id, c.user_id as customer_uid, c.referred_by,
                   u.full_name as customer_name,
                   r.user_id as rider_uid, a.owner_user_id as agent_uid 
            FROM pickups p
            JOIN customers c ON p.customer_id = c.id
            JOIN users u ON c.user_id = u.id
            LEFT JOIN riders r ON p.rider_id = r.id
            LEFT JOIN agents a ON p.agent_id = a.id
            WHERE p.id = ? FOR UPDATE`, [pickupId]);

        if (!p.length) throw new Error("Pickup request not found.");
        const pickup = p[0];

        if (pickup.status === 'completed') throw new Error("Pickup already finalized.");

        const { items } = req.body;

        // 2. Calculate Final Amounts & Weight
        let netTotal = 0;
        let totalActualWeight = 0;

        for (const it of items) {
            const finalAmount = it.actual_weight * it.actual_rate;
            netTotal += finalAmount;
            totalActualWeight += parseFloat(it.actual_weight);

            await conn.query(
                `UPDATE pickup_items SET actual_weight = ?, actual_rate_per_unit = ?, final_amount = ? WHERE id = ?`,
                [it.actual_weight, it.actual_rate, finalAmount, it.id]
            );
        }

        // 3. Logic Constants
        const riderComm = netTotal * 0.10; // 10%
        const agentComm = netTotal * 0.05; // 5%
        const pointsEarned = Math.floor(totalActualWeight); // 1 Pt per 1kg

        // 4. Update Wallets

        // A) Customer Cash Payout
        await updateWallet(conn, pickup.customer_uid, 'customer', netTotal, 'credit', 'pickup_payout', pickupId, `Cash for scrap sale ${pickup.booking_code}`);

        // B) Standard Loyalty Points (For the Customer)
        if (pointsEarned > 0) {
            await conn.query(
                "UPDATE customers SET total_points = total_points + ? WHERE id = ?",
                [pointsEarned, pickup.customer_id]
            );
            await conn.query(
                "INSERT INTO point_transactions (customer_id, amount, type, description, reference_id) VALUES (?, ?, 'bonus', ?, ?)",
                [pickup.customer_id, pointsEarned, `Earned points for recycling ${totalActualWeight}kg`, pickupId]
            );
        }

        // C) 🛡️ Delayed Referral Reward (For the Referrer)
        // Check if this is the customer's first-ever completed sale
        const [history] = await conn.query(
            "SELECT COUNT(*) as total FROM pickups WHERE customer_id = ? AND status = 'completed'",
            [pickup.customer_id]
        );

        if (history[0].total === 0 && pickup.referred_by) {
            const referralBonus = 200; // Reward for inviter

            // Award points to referrer
            await conn.query(
                "UPDATE customers SET total_points = total_points + ? WHERE id = ?",
                [referralBonus, pickup.referred_by]
            );

            // Log Point Transaction for referrer
            await conn.query(
                `INSERT INTO point_transactions (customer_id, amount, type, description, reference_id) 
                 VALUES (?, ?, 'referral', ?, ?)`,
                [
                    pickup.referred_by,
                    referralBonus,
                    `Referral reward: ${pickup.customer_name} finished their first sale!`,
                    pickup.customer_id
                ]
            );

            // TODO: Trigger Push Notification here to the referrer's user_id
            console.log(`NOTIFY: Referrer ${pickup.referred_by} earned ${referralBonus} points!`);
        }

        // D) Rider & Agent Commissions
        if (pickup.rider_uid) {
            await updateWallet(conn, pickup.rider_uid, 'rider', riderComm, 'credit', 'commission', pickupId, `Commission for ${pickup.booking_code}`);
        }
        if (pickup.agent_uid) {
            await updateWallet(conn, pickup.agent_uid, 'agent', agentComm, 'credit', 'commission', pickupId, `Area commission for ${pickup.booking_code}`);
        }

        // 5. Finalize Pickup Record
        const proofImage = req.file ? req.file.path.replace(/\\/g, '/').replace('public/', '') : null;

        await conn.query(
            `UPDATE pickups SET 
                status = 'completed', 
                net_payable_amount = ?, 
                rider_commission_amount = ?, 
                agent_commission_amount = ?,
                payment_status = 'paid',
                proof_image_after = ?,
                completed_at = NOW() 
             WHERE id = ?`,
            [netTotal, riderComm, agentComm, proofImage, pickupId]
        );

        await conn.commit();
        res.json({
            success: true,
            message: "Pickup finalized. Points and commissions awarded.",
            data: { payout: netTotal, points: pointsEarned }
        });

    } catch (err) {
        await conn.rollback();
        console.error("Finalization Error:", err);
        res.status(500).json({ success: false, message: "Completion Failed: " + err.message });
    } finally {
        conn.release();
    }
};

/**
 * 6. GET FINAL RECEIPT
 */
export const getReceipt = async (req, res) => {
    try {
        const [pickup] = await db.query(
            `SELECT p.*, r.full_name as rider_name FROM pickups p 
             LEFT JOIN users r ON p.rider_id = r.id WHERE p.id = ? AND p.status = 'completed'`, [req.params.id]
        );
        if (!pickup.length) return res.status(404).json({ success: false, message: "Receipt not found" });

        const [items] = await db.query(
            `SELECT pi.*, si.name as scrap_item_name, si.unit FROM pickup_items pi 
             JOIN scrap_items si ON pi.scrap_item_id = si.id WHERE pi.pickup_id = ?`, [req.params.id]
        );

        res.json({ success: true, pickup: pickup[0], items });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};
export const agentPickupList = async (req, res) => {
    try {
        const userId = req.user.id;

        const [agent] = await db.query(
            `SELECT id FROM agents WHERE owner_user_id = ?`,
            [userId]
        );

        if (!agent.length)
            return res.status(403).json({ success: false, message: "Not an agent" });

        const agentId = agent[0].id;

        const [rows] = await db.query(
            `
      SELECT 
        p.id, p.booking_code, p.status, 
        p.estimated_min_amount, p.estimated_max_amount,
        p.scheduled_date, p.scheduled_time_slot,
        u.full_name AS customer_name,
        ru.full_name AS rider_name
      FROM pickups p
      JOIN customers c ON c.id = p.customer_id
      JOIN users u ON u.id = c.user_id
      LEFT JOIN riders r ON r.id = p.rider_id
      LEFT JOIN users ru ON ru.id = r.user_id
      WHERE p.agent_id = ?
      ORDER BY p.created_at DESC
    `,
            [agentId]
        );

        return res.json({ success: true, pickups: rows });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: "Server error" });
    }
};

export const riderPickupList = async (req, res) => {
    try {
        const userId = req.user.id;

        const [rider] = await db.query(
            `SELECT id FROM riders WHERE user_id = ?`,
            [userId]
        );

        if (!rider.length)
            return res.status(403).json({ success: false, message: "Not a rider" });

        const riderId = rider[0].id;

        const [rows] = await db.query(
            `
      SELECT 
        p.id, p.booking_code, p.status,
        p.estimated_min_amount, p.estimated_max_amount,
        p.scheduled_date, p.scheduled_time_slot,
        u.full_name AS customer_name
      FROM pickups p
      JOIN customers c ON c.id = p.customer_id
      JOIN users u ON u.id = c.user_id
      WHERE p.rider_id = ?
      ORDER BY p.created_at DESC
    `,
            [riderId]
        );

        return res.json({ success: true, pickups: rows });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: "Server error" });
    }
};
