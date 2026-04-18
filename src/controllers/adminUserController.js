// src/controllers/adminUserController.js
import bcrypt from "bcryptjs";
import { validationResult } from "express-validator";
import ApiError from "../utils/ApiError.js";
import db from "../config/db.js";
import { sendPushNotification } from "../utils/notificationHelper.js";

/* --------------------------------------------------
    INTERNAL HELPERS
-------------------------------------------------- */
function checkValidation(req) {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        throw new ApiError(422, errors.array()[0].msg);
    }
}

/**
 * Helper: Initialize Wallet for any new user
 * Essential for the Financial Circle logic
 */
const initializeWallet = async (conn, userId) => {
    await conn.query(
        "INSERT INTO wallet_accounts (user_id, balance, total_withdrawn, currency) VALUES (?, 0.00, 0.00, 'BDT')",
        [userId]
    );
};

/* --------------------------------------------------
    ADMIN → CREATE AGENT ACCOUNT
-------------------------------------------------- */
export const createAgentAccount = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        checkValidation(req);
        await conn.beginTransaction();

        let {
            full_name, phone, email, password,
            business_name, address_line,
            latitude, longitude,
            hub_commission_value, platform_fee_percent, default_rider_mode
        } = req.body;

        const [exists] = await conn.query(
            "SELECT id FROM users WHERE phone = ? OR (email IS NOT NULL AND email = ?)",
            [phone, email]
        );
        if (exists.length > 0) throw new ApiError(400, "Phone or Email already registered");

        const password_hash = await bcrypt.hash(password, 10);

        // Create User (role_id 2 = Agent)
        const [userResult] = await conn.query(
            "INSERT INTO users (full_name, phone, email, password_hash, role_id, is_active) VALUES (?, ?, ?, ?, 2, 1)",
            [full_name, phone, email || null, password_hash]
        );
        const userId = userResult.insertId;

        const agentCode = 'AG-' + Math.random().toString(36).substring(2, 7).toUpperCase();

        // Updated for Hybrid Model
        await conn.query(
            `INSERT INTO agents (
                owner_user_id, business_name, code, email, 
                phone, address_line, latitude, longitude, 
                hub_commission_value, platform_fee_percent, default_rider_mode, is_active
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)`,
            [
                userId, business_name, agentCode, email,
                phone, address_line, latitude, longitude,
                hub_commission_value || 10.00, platform_fee_percent || 5.00, default_rider_mode || 'salary'
            ]
        );

        await conn.query(
            `INSERT INTO addresses (user_id, label, address_line, latitude, longitude, is_default) VALUES (?, 'Business Hub', ?, ?, ?, 1)`,
            [userId, address_line, latitude, longitude]
        );

        await initializeWallet(conn, userId);

        await conn.commit();
        res.status(201).json({ success: true, message: "Agent Hub created with hybrid configuration." });

    } catch (err) {
        await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};

/**
 * UPDATE AGENT HUB
 * Synchronizes Users, Agents, and Addresses tables
 */
export const updateAgentAccount = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const { id } = req.params;
        const {
            full_name, phone, email, business_name, address_line,
            hub_commission_value, platform_fee_percent, default_rider_mode,
            latitude, longitude, is_active
        } = req.body;

        await conn.beginTransaction();

        const [agentRows] = await conn.query("SELECT owner_user_id FROM agents WHERE id = ?", [id]);
        if (agentRows.length === 0) throw new ApiError(404, "Agent not found");
        const ownerUserId = agentRows[0].owner_user_id;

        await conn.query(
            `UPDATE users SET full_name = COALESCE(?, full_name), phone = COALESCE(?, phone), 
             email = COALESCE(?, email), is_active = COALESCE(?, is_active) WHERE id = ?`,
            [full_name, phone, email, is_active, ownerUserId]
        );

        // Updated to support Hybrid Model global config
        await conn.query(
            `UPDATE agents SET 
                business_name = COALESCE(?, business_name), 
                address_line = COALESCE(?, address_line),
                latitude = COALESCE(?, latitude),
                longitude = COALESCE(?, longitude),
                hub_commission_value = COALESCE(?, hub_commission_value),
                platform_fee_percent = COALESCE(?, platform_fee_percent),
                default_rider_mode = COALESCE(?, default_rider_mode),
                is_active = COALESCE(?, is_active),
                phone = COALESCE(?, phone),
                email = COALESCE(?, email)
            WHERE id = ?`,
            [business_name, address_line, latitude, longitude, hub_commission_value, platform_fee_percent, default_rider_mode, is_active, phone, email, id]
        );

        await conn.query(
            `UPDATE addresses SET address_line = COALESCE(?, address_line), latitude = COALESCE(?, latitude), 
             longitude = COALESCE(?, longitude) WHERE user_id = ? AND label = 'Business Hub'`,
            [address_line, latitude, longitude, ownerUserId]
        );

        await conn.commit();
        res.json({ success: true, message: "Agent Hub and Hybrid Policy synchronized." });

    } catch (err) {
        await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};

/**
 * DELETE AGENT (Deactivation)
 * Synchronizes deactivation across Users and Agents tables
 */
export const deleteAgentAccount = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const { id } = req.params; // This is the Agent ID
        await conn.beginTransaction();

        // 1. Fetch the owner_user_id using the correct column name
        // FIXED: Changed user_id to owner_user_id
        const [agentRows] = await conn.query(
            "SELECT owner_user_id FROM agents WHERE id = ?",
            [id]
        );

        if (agentRows.length === 0) {
            throw new ApiError(404, "Agent node not found in the system");
        }

        const ownerUserId = agentRows[0].owner_user_id;

        // 2. Deactivate the User Account (Identity Node)
        await conn.query(
            "UPDATE users SET is_active = 0 WHERE id = ?",
            [ownerUserId]
        );

        // 3. Deactivate the Agent Hub (Business Node)
        await conn.query(
            "UPDATE agents SET is_active = 0 WHERE id = ?",
            [id]
        );

        await conn.commit();

        res.json({
            success: true,
            message: "Agent hub and associated user account have been deactivated."
        });

    } catch (err) {
        // Rollback ensures that we don't deactivate the agent profile 
        // without also deactivating the login user (or vice versa).
        await conn.rollback();
        console.error("Agent Deactivation Error:", err);
        next(err);
    } finally {
        // Always release the connection back to the pool
        conn.release();
    }
};

/* --------------------------------------------------
    ADMIN/AGENT → CREATE RIDER ACCOUNT
-------------------------------------------------- */
export const createRiderAccount = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        checkValidation(req);
        await conn.beginTransaction();

        const {
            full_name, phone, email, password, agent_id,
            vehicle_type, vehicle_number, payment_mode
        } = req.body;
        const requester = req.user;

        let finalAgentId = null;
        if (requester.role === "agent") {
            const [agent] = await conn.query("SELECT id FROM agents WHERE owner_user_id = ?", [requester.id]);
            if (!agent.length) throw new ApiError(403, "Agent profile not found");
            finalAgentId = agent[0].id;
        } else {
            finalAgentId = agent_id;
        }

        if (!finalAgentId) throw new ApiError(400, "agent_id is required");

        const password_hash = await bcrypt.hash(password, 10);
        const [userResult] = await conn.query(
            "INSERT INTO users (full_name, phone, email, password_hash, role_id) VALUES (?, ?, ?, ?, 3)",
            [full_name, phone, email || null, password_hash]
        );
        const userId = userResult.insertId;

        // Updated to include payment_mode (salary, commission, or default)
        await conn.query(
            "INSERT INTO riders (user_id, agent_id, vehicle_type, vehicle_number, payment_mode) VALUES (?, ?, ?, ?, ?)",
            [userId, finalAgentId, vehicle_type || 'Bicycle', vehicle_number || null, payment_mode || 'default']
        );

        await initializeWallet(conn, userId);

        await conn.commit();
        res.status(201).json({ success: true, message: `Rider account created in ${payment_mode || 'default'} mode.` });

    } catch (err) {
        await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};

/* --------------------------------------------------
    ADMIN/AGENT → UPDATE RIDER ACCOUNT
-------------------------------------------------- */
export const updateRiderAccount = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const { id } = req.params; // Rider ID
        const {
            full_name, phone, email,
            vehicle_type, vehicle_number, payment_mode,
            is_active
        } = req.body;
        const requester = req.user;

        await conn.beginTransaction();

        // 1. Verify Rider exists and get their user_id
        const [riderRows] = await conn.query(
            "SELECT user_id, agent_id FROM riders WHERE id = ?",
            [id]
        );
        if (riderRows.length === 0) throw new ApiError(404, "Rider node not found");
        const riderData = riderRows[0];

        // 2. AGENT SECURITY: Ensure the agent owns this rider
        if (requester.role === "agent") {
            const [agent] = await conn.query(
                "SELECT id FROM agents WHERE owner_user_id = ?",
                [requester.id]
            );
            if (!agent.length || agent[0].id !== riderData.agent_id) {
                throw new ApiError(403, "Access Denied: This rider belongs to another Hub Node.");
            }
        }

        // 3. Update User Identity (users table)
        await conn.query(
            `UPDATE users SET 
                full_name = COALESCE(?, full_name), 
                phone = COALESCE(?, phone), 
                email = COALESCE(?, email), 
                is_active = COALESCE(?, is_active),
                updated_at = CURRENT_TIMESTAMP
             WHERE id = ?`,
            [full_name, phone, email, is_active, riderData.user_id]
        );

        // 4. Update Rider Profile (riders table)
        // Note: Agents cannot change a rider's agent_id, only Admins can.
        await conn.query(
            `UPDATE riders SET 
                vehicle_type = COALESCE(?, vehicle_type),
                vehicle_number = COALESCE(?, vehicle_number),
                payment_mode = COALESCE(?, payment_mode),
                is_active = COALESCE(?, is_active),
                updated_at = CURRENT_TIMESTAMP
            WHERE id = ?`,
            [vehicle_type, vehicle_number, payment_mode, is_active, id]
        );

        await conn.commit();
        res.json({
            success: true,
            message: `Rider ${full_name || 'profile'} updated successfully.`
        });

    } catch (err) {
        await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};

export const deleteRiderAccount = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const { id } = req.params;
        await conn.beginTransaction();

        // 1. Get user_id associated with this rider
        const [riderRows] = await conn.query("SELECT user_id FROM riders WHERE id = ?", [id]);
        if (riderRows.length === 0) throw new ApiError(404, "Rider not found");
        const userId = riderRows[0].user_id;

        // 2. Deactivate both nodes
        await conn.query("UPDATE users SET is_active = 0 WHERE id = ?", [userId]);
        await conn.query("UPDATE riders SET is_active = 0 WHERE id = ?", [id]);

        await conn.commit();
        res.json({ success: true, message: "Rider node deactivated (Offline)." });
    } catch (err) {
        await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};

export const permanentDeleteRider = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const { id } = req.params;
        await conn.beginTransaction();

        // 1. Fetch dependencies
        const [riderRows] = await conn.query("SELECT user_id FROM riders WHERE id = ?", [id]);
        if (riderRows.length === 0) throw new ApiError(404, "Rider not found");
        const userId = riderRows[0].user_id;

        // 2. SAFETY CHECK: Check for active or historical pickups
        const [pickups] = await conn.query(
            "SELECT id FROM pickups WHERE rider_id = ? AND status NOT IN ('completed', 'cancelled') LIMIT 1",
            [id]
        );
        if (pickups.length > 0) {
            throw new ApiError(400, "Cannot purge: Rider has active pickup assignments. Complete or reassign them first.");
        }

        // 3. Purge Child Nodes first (Addresses, Wallets)
        await conn.query("DELETE FROM addresses WHERE user_id = ?", [userId]);
        await conn.query("DELETE FROM wallet_accounts WHERE user_id = ?", [userId]);

        // 4. Purge Primary Nodes
        await conn.query("DELETE FROM riders WHERE id = ?", [id]);
        await conn.query("DELETE FROM users WHERE id = ?", [userId]);

        await conn.commit();
        res.json({ success: true, message: "Rider identity and logistics node purged successfully." });
    } catch (err) {
        await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};

export const reassignRiderPickups = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const { source_rider_id, target_rider_id } = req.body;

        if (!source_rider_id || !target_rider_id) {
            throw new ApiError(400, "Both Source and Target riders are required");
        }

        await conn.beginTransaction();

        // 1. Update the pickups table
        // Included 'assigned' status and updated the assigned_at timestamp
        const [result] = await conn.query(
            `UPDATE pickups 
             SET rider_id = ?, 
                 assigned_at = CURRENT_TIMESTAMP,
                 status = 'assigned' 
             WHERE rider_id = ? 
             AND status IN ('pending', 'assigned', 'accepted', 'started')
             AND is_deleted = 0`,
            [target_rider_id, source_rider_id]
        );

        if (result.affectedRows === 0) {
            await conn.rollback();
            return res.json({
                success: false,
                message: "No active pickups found for the source rider to migrate."
            });
        }

        await conn.commit();

        res.json({
            success: true,
            message: `Successfully migrated ${result.affectedRows} pickups to the new rider Node.`,
            affectedCount: result.affectedRows
        });
    } catch (err) {
        await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};
/**
 * PERMANENT DELETE
 * Cleans up wallet_accounts, addresses, agents, and users
 */
export const permanentDeleteAgent = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const { id } = req.params; // Agent ID
        await conn.beginTransaction();

        // 1. Find the owner_user_id
        const [agentRows] = await conn.query("SELECT owner_user_id FROM agents WHERE id = ?", [id]);
        if (agentRows.length === 0) throw new ApiError(404, "Agent node not found");
        const userId = agentRows[0].owner_user_id;

        // 2. CHECK FOR LOGISTICS DEPENDENCIES (Pickups/Riders)
        // Check for Riders attached to this Agent Hub
        const [riders] = await conn.query("SELECT id FROM riders WHERE agent_id = ? LIMIT 1", [id]);
        if (riders.length > 0) {
            throw new ApiError(400, "Migration Required: Move active riders to another hub before deleting this node.");
        }

        // Check for Pickups processed by this Agent Hub
        const [pickups] = await conn.query("SELECT id FROM pickups WHERE agent_id = ? LIMIT 1", [id]);
        if (pickups.length > 0) {
            throw new ApiError(400, "Historical Data Conflict: Hub has processed pickups. Please use 'Deactivate' to preserve records.");
        }

        // 3. DELETE DEPENDENCIES IN ORDER (Child rows first)
        // Delete geographic nodes
        await conn.query("DELETE FROM addresses WHERE user_id = ?", [userId]);

        // Delete wallet nodes (This fixes your current error)
        await conn.query("DELETE FROM wallet_accounts WHERE user_id = ?", [userId]);

        // 4. DELETE PRIMARY NODES (Parent rows last)
        // Delete from agents table
        await conn.query("DELETE FROM agents WHERE id = ?", [id]);

        // Finally, delete the identity record from users
        await conn.query("DELETE FROM users WHERE id = ?", [userId]);

        await conn.commit();
        res.json({ success: true, message: "Agent node and all associated financial/identity data purged." });

    } catch (err) {
        await conn.rollback();
        console.error("Purge Error:", err.message);
        next(err);
    } finally {
        conn.release();
    }
};

/**
 * REASSIGN RIDERS
 * Move all riders from one agent to another
 */
export const reassignRiders = async (req, res, next) => {
    try {
        const { old_agent_id, new_agent_id } = req.body;

        if (!old_agent_id || !new_agent_id) {
            throw new ApiError(400, "Both Source and Target Hub IDs are required");
        }

        // Update all riders in one query
        const [result] = await db.query(
            "UPDATE riders SET agent_id = ? WHERE agent_id = ?",
            [new_agent_id, old_agent_id]
        );

        res.json({
            success: true,
            message: `Successfully migrated ${result.affectedRows} riders to the new Hub node.`
        });
    } catch (err) {
        next(err);
    }
};

export const assignPickupToAgent = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const { pickup_id, agent_id } = req.body;
        await conn.beginTransaction();

        // 1. Verify pickup and Fetch Customer FCM Token
        const [pickup] = await conn.query(`
            SELECT p.id, p.booking_code, u.fcm_token, u.id as user_id 
            FROM pickups p
            JOIN customers c ON p.customer_id = c.id
            JOIN users u ON c.user_id = u.id
            WHERE p.id = ?
        `, [pickup_id]);

        if (!pickup.length) throw new ApiError(404, "Pickup request not found.");

        // 2. Perform the assignment
        await conn.query(
            `UPDATE pickups SET 
                agent_id = ?, 
                status = 'assigned', 
                assigned_at = CURRENT_TIMESTAMP,
                updated_at = CURRENT_TIMESTAMP
             WHERE id = ?`,
            [agent_id, pickup_id]
        );

        await conn.commit();

        // 3. NOTIFY CUSTOMER via Firebase
        if (pickup[0].fcm_token) {
            await sendPushNotification(
                pickup[0].fcm_token,
                "Order Update 🚛",
                `Your request ${pickup[0].booking_code} has been assigned to a local hub.`,
                { orderId: pickup_id.toString(), type: "order_update" }
            );
        }

        res.json({ success: true, message: "Assigned to Agent and Customer notified." });
    } catch (err) {
        await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};
/* --------------------------------------------------
    LISTINGS (With Rider Count & Wallet Sync)
-------------------------------------------------- */
export const listAgents = async (req, res, next) => {
    try {
        const query = `
            SELECT a.*, u.full_name, u.phone, u.email, w.balance,
                (SELECT COUNT(*) FROM riders r WHERE r.agent_id = a.id) as rider_count
            FROM agents a
            JOIN users u ON a.owner_user_id = u.id
            LEFT JOIN wallet_accounts w ON u.id = w.user_id
            ORDER BY a.created_at DESC`;
        const [rows] = await db.query(query);
        res.json({ success: true, data: rows });
    } catch (err) { next(err); }
};

/* --------------------------------------------------
    LIST RIDERS (Backend Controller Update)
-------------------------------------------------- */
export const listRiders = async (req, res, next) => {
    try {
        const query = `
            SELECT r.*, u.full_name, u.phone, u.email, u.is_active as user_active,
                a.business_name as agency_name, a.default_rider_mode as hub_default_mode
            FROM riders r
            JOIN users u ON r.user_id = u.id
            LEFT JOIN agents a ON r.agent_id = a.id
            ORDER BY r.created_at DESC`;
        const [rows] = await db.query(query);
        res.json({ success: true, data: rows });
    } catch (err) { next(err); }
}

/* --------------------------------------------------
    ADMIN/AGENT → CREATE CUSTOMER (With Address)
-------------------------------------------------- */
export const createCustomerAccount = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        // Validation check (express-validator)
        const errors = validationResult(req);
        if (!errors.isEmpty()) return next(new ApiError(400, errors.array()[0].msg));

        await conn.beginTransaction();

        const {
            full_name, phone, email, password,
            address_line, division_id, district_id, upazila_id
        } = req.body;

        // 1. Check if user already exists
        const [exists] = await conn.query("SELECT id FROM users WHERE phone = ?", [phone]);
        if (exists.length > 0) throw new ApiError(400, 'A user with this phone number already exists.');

        const password_hash = await bcrypt.hash(password, 10);

        // 2. Create User (Role 4 = Customer)
        const [userResult] = await conn.query(
            "INSERT INTO users (full_name, phone, email, password_hash, role_id, is_active) VALUES (?, ?, ?, ?, 4, 1)",
            [full_name, phone, email || null, password_hash]
        );
        const userId = userResult.insertId;

        // 3. Create Primary Address Node (Link to Geography)
        await conn.query(
            `INSERT INTO addresses (user_id, label, address_line, division_id, district_id, upazila_id, is_default) 
             VALUES (?, 'Home', ?, ?, ?, ?, 1)`,
            [userId, address_line || 'Primary Address', division_id, district_id, upazila_id]
        );

        // 4. Create Customer Profile
        const refCode = 'GS-' + Math.random().toString(36).substring(2, 7).toUpperCase();
        await conn.query(
            "INSERT INTO customers (user_id, referral_code, total_points) VALUES (?, ?, 20)",
            [userId, refCode]
        );

        // 5. Initialize Wallet
        await conn.query("INSERT INTO wallet_accounts (user_id, balance) VALUES (?, 0)", [userId]);

        await conn.commit();
        res.status(201).json({ success: true, message: "Customer account and address initialized successfully." });

    } catch (err) {
        await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};

export const listCustomers = async (req, res, next) => {
    try {
        const query = `
            SELECT 
                u.id, u.full_name, u.phone, u.email, u.is_active, u.created_at,
                w.balance,
                
                -- Geographic IDs (Crucial for Edit Modal pre-filling)
                addr.division_id, 
                addr.district_id, 
                addr.upazila_id,
                addr.address_line,
                addr.latitude,
                addr.longitude,

                -- Geographic Names (For Table Display)
                divs.name_en as division_name,
                dist.name_en as district_name,
                upz.name_en as upazila_name,
                
                -- Summary Stats
                (SELECT COUNT(*) FROM pickups WHERE customer_id = u.id) as total_bookings,
                (SELECT COUNT(*) FROM pickups WHERE customer_id = u.id AND status NOT IN ('completed', 'cancelled')) as active_bookings,
                (SELECT MAX(created_at) FROM pickups WHERE customer_id = u.id) as last_order_date
                
            FROM users u
            LEFT JOIN wallet_accounts w ON u.id = w.user_id
            
            -- Improved Geographic Joins 
            -- We fetch the 'Default' address or the most recent one if no default exists
            LEFT JOIN (
                SELECT * FROM addresses 
                WHERE id IN (
                    SELECT MAX(id) FROM addresses GROUP BY user_id
                )
            ) addr ON u.id = addr.user_id
            
            LEFT JOIN divisions divs ON addr.division_id = divs.id
            LEFT JOIN districts dist ON addr.district_id = dist.id
            LEFT JOIN upazilas upz ON addr.upazila_id = upz.id
            
            WHERE u.role_id = 4
            ORDER BY u.created_at DESC
        `;

        const [rows] = await db.query(query);
        res.json({ success: true, data: rows });
    } catch (err) {
        next(err);
    }
};

/* --------------------------------------------------
    ADMIN -> UPDATE CUSTOMER (Identity + Geography)
-------------------------------------------------- */
export const updateCustomer = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const { id } = req.params;
        const {
            full_name, phone, email, is_active,
            address_line, division_id, district_id, upazila_id,
            latitude, longitude // Capture these from your payload
        } = req.body;

        await conn.beginTransaction();

        // 1. Update Identity (users table)
        // We use COALESCE to keep the old value if the new one is undefined/null
        const [userUpdate] = await conn.query(
            `UPDATE users SET 
                full_name = COALESCE(?, full_name),
                phone = COALESCE(?, phone),
                email = COALESCE(?, email),
                is_active = COALESCE(?, is_active),
                updated_at = CURRENT_TIMESTAMP
            WHERE id = ? AND role_id = 4`,
            [full_name, phone, email, is_active, id]
        );

        if (userUpdate.affectedRows === 0) {
            throw new ApiError(404, "Customer not found.");
        }

        // 2. Check if an address already exists for this user
        const [existingAddr] = await conn.query(
            "SELECT id FROM addresses WHERE user_id = ? LIMIT 1",
            [id]
        );

        if (existingAddr.length > 0) {
            // 3a. UPDATE existing address including Geospatial data
            await conn.query(
                `UPDATE addresses SET 
                    address_line = COALESCE(?, address_line),
                    division_id = COALESCE(?, division_id),
                    district_id = COALESCE(?, district_id),
                    upazila_id = COALESCE(?, upazila_id),
                    latitude = COALESCE(?, latitude),
                    longitude = COALESCE(?, longitude),
                    updated_at = CURRENT_TIMESTAMP
                WHERE user_id = ?`,
                [address_line, division_id, district_id, upazila_id, latitude, longitude, id]
            );
        } else {
            // 3b. INSERT a new address if one doesn't exist
            await conn.query(
                `INSERT INTO addresses (
                    user_id, label, address_line, division_id, 
                    district_id, upazila_id, latitude, longitude, is_default
                ) VALUES (?, 'Home', ?, ?, ?, ?, ?, ?, 1)`,
                [id, address_line, division_id, district_id, upazila_id, latitude, longitude]
            );
        }

        await conn.commit();
        res.json({
            success: true,
            message: "Customer profile and precise location updated."
        });

    } catch (err) {
        await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};
/* --------------------------------------------------
    ADMIN -> PERMANENT DELETE (PURGE)
-------------------------------------------------- */
export const permanentDeleteCustomer = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const { id } = req.params;
        await conn.beginTransaction();

        // 1. Safety Check: Don't delete if they have active bookings
        const [active] = await conn.query(
            "SELECT id FROM pickups WHERE customer_id = ? AND status NOT IN ('completed', 'cancelled') LIMIT 1",
            [id]
        );
        if (active.length > 0) {
            throw new ApiError(400, "Cannot purge: Customer has active pickup requests.");
        }

        // 2. Cascade Delete related data
        await conn.query("DELETE FROM addresses WHERE user_id = ?", [id]);
        await conn.query("DELETE FROM wallet_accounts WHERE user_id = ?", [id]);
        await conn.query("DELETE FROM customers WHERE user_id = ?", [id]);
        await conn.query("DELETE FROM users WHERE id = ?", [id]);

        await conn.commit();
        res.json({ success: true, message: "Customer and all associated data purged." });
    } catch (err) {
        await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
}

export const getActivityLogs = async (req, res) => {
    try {
        const query = `
            SELECT 
                al.id,
                al.action,
                al.platform,
                al.browser,
                al.os,
                al.device,
                al.ip_address,
                al.metadata,
                al.created_at,
                u.full_name as user_name,
                u.phone as user_phone
            FROM activity_logs al
            LEFT JOIN users u ON al.user_id = u.id
            ORDER BY al.created_at DESC
            LIMIT 250
        `;

        const [logs] = await db.execute(query);

        return res.status(200).json({
            success: true,
            data: logs
        });
    } catch (error) {
        console.error("Fetch Logs Error:", error);
        return res.status(500).json({ success: false, message: "Error loading logs" });
    }
};