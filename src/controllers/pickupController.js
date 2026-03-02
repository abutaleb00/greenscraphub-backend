// src/controllers/pickupController.js

import db from "../config/db.js";
import path from "path";
import fs from "fs";

/**
 * Helper: Find nearest available rider using Haversine formula
 */
const getNearestRider = async (conn, lat, lng) => {
    try {
        const [riders] = await conn.query(`
            SELECT r.id, r.agent_id, 
            (6371 * acos(cos(radians(?)) * cos(radians(r.current_latitude)) * cos(radians(r.current_longitude) - radians(?)) + sin(radians(?)) * sin(radians(r.current_latitude)))) AS distance 
            FROM riders r 
            WHERE r.status = 'active' AND r.is_available = 1
            ORDER BY distance ASC LIMIT 1
        `, [lat, lng, lat]);
        return riders.length ? riders[0] : null;
    } catch (err) {
        console.error("Rider lookup error:", err.message);
        return null; // Don't crash the request if the distance math fails
    }
};

/**
 * CREATE PICKUP REQUEST (With Indexed Image Support)
 */
export const createPickup = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        await conn.beginTransaction();
        const userId = req.user.id;

        const {
            address_id, pickup_address, latitude, longitude,
            items, scheduled_date, scheduled_time_slot, customer_note
        } = req.body;

        // 1. Get Customer ID
        const [customer] = await conn.query("SELECT id FROM customers WHERE user_id = ?", [userId]);
        if (!customer.length) return res.status(404).json({ success: false, message: "Customer profile not found" });
        const customerId = customer[0].id;

        const parsedItems = typeof items === 'string' ? JSON.parse(items) : items;
        const bookingCode = "GS" + Date.now().toString().slice(-6);

        // 2. Insert Master Pickup
        const [pickupResult] = await conn.query(
            `INSERT INTO pickups (
                booking_code, customer_id, customer_address_id, pickup_address, 
                status, scheduled_date, scheduled_time_slot, pickup_latitude, 
                pickup_longitude, customer_note, pickup_type, created_at
            ) VALUES (?, ?, ?, ?, 'pending', ?, ?, ?, ?, ?, 'scheduled', NOW())`,
            [bookingCode, customerId, address_id, pickup_address, scheduled_date, scheduled_time_slot, latitude, longitude, customer_note]
        );
        const pickupId = pickupResult.insertId;

        // 3. Process Items & Map Files
        const files = req.files || [];
        let masterTotalMin = 0;
        let masterTotalMax = 0;

        for (let i = 0; i < parsedItems.length; i++) {
            const item = parsedItems[i];

            // Get live prices
            const [scrap] = await conn.query(
                "SELECT min_price_per_unit, max_price_per_unit FROM scrap_items WHERE id = ?",
                [item.scrap_item_id]
            );

            const weight = parseFloat(item.estimated_weight) || 0;
            const itemMin = scrap[0].min_price_per_unit * weight;
            const itemMax = scrap[0].max_price_per_unit * weight;
            masterTotalMin += itemMin;
            masterTotalMax += itemMax;

            // --- 📸 DYNAMIC FILE MAPPING ---
            // Matches frontend key: item_photos[0], item_photos[1], etc.
            const targetField = `item_photos[${i}]`;
            const photoPaths = files
                .filter(f => f.fieldname === targetField)
                .map(f => `/uploads/pickups/${f.filename}`); // Standard relative path

            await conn.query(
                `INSERT INTO pickup_items (
                    pickup_id, scrap_item_id, category_id, item_id, 
                    estimated_weight, estimated_min_amount, estimated_max_amount, 
                    photo_url, created_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())`,
                [
                    pickupId, item.scrap_item_id, item.category_id, item.item_id,
                    weight, itemMin, itemMax, JSON.stringify(photoPaths)
                ]
            );
        }

        // 4. Update Final Totals
        await conn.query(
            "UPDATE pickups SET estimated_min_amount = ?, estimated_max_amount = ? WHERE id = ?",
            [masterTotalMin, masterTotalMax, pickupId]
        );

        await conn.commit();
        res.status(201).json({
            success: true,
            message: "Pickup Created!",
            data: { booking_code: bookingCode, pickup_id: pickupId }
        });

    } catch (err) {
        await conn.rollback();
        console.error("Pickup Error:", err);
        res.status(500).json({ success: false, message: err.message });
    } finally {
        conn.release();
    }
};

export const listAllPickupsAdmin = async (req, res, next) => {
    try {
        const { status, city, page = 1, limit = 10 } = req.query;
        const offset = (page - 1) * limit;

        // Base Query
        let query = `SELECT p.*, u.full_name as customer_name 
                     FROM pickups p 
                     JOIN users u ON p.customer_id = u.id`;

        // Dynamic Filtering
        const params = [];
        if (status) {
            query += ` WHERE p.status = ?`;
            params.push(status);
        }

        query += ` ORDER BY p.created_at DESC LIMIT ? OFFSET ?`;
        params.push(parseInt(limit), parseInt(offset));

        const [rows] = await db.query(query, params);

        res.json({ success: true, data: rows, page: parseInt(page) });
    } catch (err) {
        next(err);
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
    let [wallet] = await conn.query(
        "SELECT id, balance FROM wallet_accounts WHERE user_id = ? AND user_type = ? FOR UPDATE",
        [userId, role]
    );

    if (!wallet.length) {
        const [ins] = await conn.query(
            "INSERT INTO wallet_accounts (user_id, user_type, balance) VALUES (?, ?, 0)",
            [userId, role]
        );
        wallet = [{ id: ins.insertId, balance: 0 }];
    }

    const balanceBefore = parseFloat(wallet[0].balance);
    const balanceAfter = type === 'credit' ? balanceBefore + amount : balanceBefore - amount;

    await conn.query(
        "UPDATE wallet_accounts SET balance = ?, updated_at = NOW() WHERE id = ?",
        [balanceAfter, wallet[0].id]
    );

    await conn.query(
        `INSERT INTO wallet_transactions 
        (wallet_id, type, source, reference_type, reference_id, amount, balance_before, balance_after, description, status) 
        VALUES (?, ?, ?, 'pickup', ?, ?, ?, ?, ?, 'completed')`,
        [wallet[0].id, type, source, refId, amount, balanceBefore, balanceAfter, desc]
    );
};

export const assignRiderController = async (req, res, next) => {
    try {
        const { id: pickupId } = req.params; // The Pickup ID from URL
        const { rider_id } = req.body;       // The Rider's ID from Body
        const user = req.user;               // Logged-in user (Admin or Agent)

        if (!rider_id) {
            throw new ApiError(400, "Rider ID is required for assignment.");
        }

        // 1. Fetch Rider info using the correct primary key 'id'
        const [riderRows] = await db.query(
            `SELECT id, agent_id FROM riders WHERE id = ? LIMIT 1`,
            [rider_id]
        );

        if (riderRows.length === 0) {
            throw new ApiError(404, "Rider not found in the system.");
        }

        const rider = riderRows[0];

        // 2. Security Check: Agents are restricted to their own staff
        if (user.role === 'agent') {
            // Find the agent_id owned by the logged-in user
            const [agentRows] = await db.query(
                `SELECT agent_id FROM agents WHERE owner_id = ? LIMIT 1`,
                [user.id]
            );

            const agent = agentRows[0];

            if (!agent || rider.agent_id !== agent.agent_id) {
                throw new ApiError(403, "Access Denied: You can only assign riders registered under your agency.");
            }
        }

        // 3. Update the Pickup Record
        // Note: We use rider.id (the PK from riders table) to update the pickups table
        const [result] = await db.query(
            `UPDATE pickups 
             SET rider_id = ?, 
                 agent_id = ?, 
                 status = 'assigned', 
                 assigned_at = NOW() 
             WHERE id = ? AND status = 'pending'`,
            [rider.id, rider.agent_id, pickupId]
        );

        if (result.affectedRows === 0) {
            throw new ApiError(400, "Pickup assignment failed. Ensure the pickup is still 'pending'.");
        }

        res.json({
            success: true,
            message: `Pickup successfully assigned to rider #${rider.id}`,
            data: {
                pickup_id: pickupId,
                rider_id: rider.id,
                agent_id: rider.agent_id,
                status: 'assigned'
            }
        });

    } catch (err) {
        next(err);
    }
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

        if (!p.length) throw new Error("Pickup not found.");
        const pickup = p[0];
        if (pickup.status === 'completed') throw new Error("Already completed.");

        const { items } = req.body;
        let netTotal = 0;
        let totalWeight = 0;

        for (const it of items) {
            const amount = it.actual_weight * it.actual_rate;
            netTotal += amount;
            totalWeight += parseFloat(it.actual_weight);

            await conn.query(
                `UPDATE pickup_items SET actual_weight = ?, actual_rate_per_unit = ?, final_amount = ? WHERE id = ?`,
                [it.actual_weight, it.actual_rate, amount, it.id]
            );
        }

        const pointsEarned = Math.floor(totalWeight);

        // 1. Pay Customer
        await updateWallet(conn, pickup.customer_uid, 'customer', netTotal, 'credit', 'pickup_payout', pickupId, `Sale payout: ${pickup.booking_code}`);

        // 2. Loyalty Points
        if (pointsEarned > 0) {
            await conn.query("UPDATE customers SET total_points = total_points + ? WHERE id = ?", [pointsEarned, pickup.customer_id]);
            await conn.query("INSERT INTO point_transactions (customer_id, amount, type, description, reference_id) VALUES (?, ?, 'bonus', ?, ?)",
                [pickup.customer_id, pointsEarned, `Recycled ${totalWeight}kg`, pickupId]);
        }

        // 3. Referral Logic (Delayed Reward)
        const [history] = await conn.query("SELECT COUNT(*) as total FROM pickups WHERE customer_id = ? AND status = 'completed'", [pickup.customer_id]);
        if (history[0].total === 0 && pickup.referred_by) {
            const bonus = 200;
            await conn.query("UPDATE customers SET total_points = total_points + ? WHERE id = ?", [bonus, pickup.referred_by]);
            await conn.query("INSERT INTO point_transactions (customer_id, amount, type, description, reference_id) VALUES (?, ?, 'referral', ?, ?)",
                [pickup.referred_by, bonus, `Referral reward for ${pickup.customer_name}`, pickup.customer_id]);
        }

        // 4. Update Status
        const img = req.file ? req.file.path.replace(/\\/g, '/').replace('public/', '') : null;
        await conn.query(`UPDATE pickups SET status = 'completed', net_payable_amount = ?, proof_image_after = ?, completed_at = NOW() WHERE id = ?`,
            [netTotal, img, pickupId]);

        await conn.commit();

        // 5. Trigger Socket Notification
        const io = req.app.get('io');
        if (io) {
            io.to(`pickup_${pickupId}`).emit('status_updated', {
                status: 'completed',
                points: pointsEarned,
                cash: netTotal
            });
        }

        res.json({ success: true, message: "Sale finalized!", data: { payout: netTotal, points: pointsEarned } });
    } catch (err) {
        await conn.rollback();
        res.status(500).json({ success: false, message: err.message });
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
