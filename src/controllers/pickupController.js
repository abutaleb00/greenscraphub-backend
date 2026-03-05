import db from "../config/db.js";
import ApiError from "../utils/ApiError.js";

/**
 * HELPER: Atomic Wallet Update & Ledger Entry
 * Ensures balance_before and balance_after are recorded for audits.
 */
const updateWallet = async (conn, userId, amount, type, source, refType, refId, descEn, descBn) => {
    // 1. Get Wallet with Row Lock to prevent race conditions
    let [wallet] = await conn.query(
        "SELECT id, balance FROM wallet_accounts WHERE user_id = ? FOR UPDATE",
        [userId]
    );

    if (!wallet.length) {
        const [ins] = await conn.query(
            "INSERT INTO wallet_accounts (user_id, balance, total_withdrawn, currency) VALUES (?, 0, 0, 'BDT')",
            [userId]
        );
        wallet = [{ id: ins.insertId, balance: 0 }];
    }

    const balanceBefore = parseFloat(wallet[0].balance);
    const balanceAfter = type === 'credit' ? balanceBefore + amount : balanceBefore - amount;

    // 2. Update Balance
    await conn.query(
        "UPDATE wallet_accounts SET balance = ?, updated_at = NOW() WHERE id = ?",
        [balanceAfter, wallet[0].id]
    );

    // 3. Log Detailed Transaction (Bilingual)
    await conn.query(
        `INSERT INTO wallet_transactions 
        (wallet_id, type, source, reference_type, reference_id, amount, balance_before, balance_after, description_en, description_bn, status) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'completed')`,
        [wallet[0].id, type, source, refType, refId, amount, balanceBefore, balanceAfter, descEn, descBn]
    );

    // 4. Record in General Financial Ledger (Audit Table)
    await conn.query(
        `INSERT INTO financial_ledger (type, category, amount, reference_id, description) 
         VALUES (?, ?, ?, ?, ?)`,
        [type, source, amount, refId, descEn]
    );
};

/**
 * 1. CREATE PICKUP REQUEST (Customer)
 */
export const createPickup = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        await conn.beginTransaction();
        const userId = req.user.id;

        const {
            address_id, division_id, district_id, upazila_id,
            items, scheduled_date, scheduled_time_slot, customer_note, pickup_type
        } = req.body;

        const [customer] = await conn.query("SELECT id FROM customers WHERE user_id = ?", [userId]);
        if (!customer.length) throw new ApiError(404, "Customer profile not found");
        const customerId = customer[0].id;

        const bookingCode = `GS-${upazila_id}-${Date.now().toString().slice(-4)}`;
        const parsedItems = typeof items === 'string' ? JSON.parse(items) : items;

        // A) Insert Master Pickup
        const [pickupResult] = await conn.query(
            `INSERT INTO pickups (
                booking_code, customer_id, address_id, 
                division_id, district_id, upazila_id,
                status, scheduled_date, scheduled_time_slot, 
                customer_note, pickup_type, created_at
            ) VALUES (?, ?, ?, ?, ?, ?, 'pending', ?, ?, ?, ?, NOW())`,
            [bookingCode, customerId, address_id, division_id, district_id, upazila_id, scheduled_date, scheduled_time_slot, customer_note, pickup_type || 'standard']
        );
        const pickupId = pickupResult.insertId;

        // B) Process Items & Estimates
        let totalEstMin = 0;
        for (const item of parsedItems) {
            const [scrap] = await conn.query(
                "SELECT current_min_rate, category_id FROM scrap_items WHERE id = ?", [item.item_id]
            );

            const weight = parseFloat(item.estimated_weight) || 0;
            totalEstMin += (scrap[0].current_min_rate * weight);

            await conn.query(
                `INSERT INTO pickup_items (pickup_id, category_id, scrap_item_id, estimated_weight) VALUES (?, ?, ?, ?)`,
                [pickupId, scrap[0].category_id, item.item_id, weight]
            );
        }

        // C) Log Timeline
        await conn.query(
            "INSERT INTO pickup_timeline (pickup_id, status, p_timestamp, note) VALUES (?, 'pending', NOW(), 'Request created by customer')",
            [pickupId]
        );

        await conn.query("UPDATE pickups SET base_amount = ? WHERE id = ?", [totalEstMin, pickupId]);

        await conn.commit();
        res.status(201).json({ success: true, message: "Pickup created successfully!", booking_code: bookingCode });
    } catch (err) {
        await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};

/**
 * 2. ASSIGN RIDER (Agent/Admin)
 * URL: PUT /api/v1/pickups/:id/assign-rider
 */
export const assignRiderController = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const { id: pickupId } = req.params;
        const { rider_id } = req.body;
        const changerId = req.user.id; // Logged in Admin/Agent ID

        await conn.beginTransaction();

        // 1. Verify Rider exists
        const [riderRows] = await conn.query(
            "SELECT id, agent_id FROM riders WHERE id = ?",
            [rider_id]
        );

        if (!riderRows.length) {
            throw new ApiError(404, "Rider not found");
        }

        const rider = riderRows[0];

        // 2. Update Pickup status (Only allowed if current status is 'pending')
        const [updateResult] = await conn.query(
            `UPDATE pickups SET 
                rider_id = ?, 
                agent_id = ?, 
                status = 'assigned', 
                assigned_at = NOW() 
            WHERE id = ? AND status = 'pending'`,
            [rider.id, rider.agent_id, pickupId]
        );

        if (updateResult.affectedRows === 0) {
            // This prevents re-assigning an order that is already in progress or cancelled
            throw new ApiError(400, "Pickup is not in 'pending' state or does not exist.");
        }

        // 3. Record in Timeline (Now including your new 'note' column)
        await conn.query(
            `INSERT INTO pickup_timeline 
            (pickup_id, status, changed_by, note, created_at) 
            VALUES (?, ?, ?, ?, NOW())`,
            [
                pickupId,
                'assigned',
                changerId,
                `Rider ID ${rider.id} was assigned by Admin/Agent ID ${changerId}`
            ]
        );

        await conn.commit();

        res.json({
            success: true,
            message: "Success! Rider dispatched and timeline logged."
        });

    } catch (err) {
        await conn.rollback();
        console.error("Assignment Transaction Failed:", err);
        next(err);
    } finally {
        conn.release();
    }
};

export const reassignSinglePickup = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const { id } = req.params; // Pickup ID
        const { target_rider_id } = req.body;

        if (!target_rider_id) throw new ApiError(400, "Target rider is required");

        await conn.beginTransaction();

        // 1. Check if pickup exists and current status
        const [pickup] = await conn.query("SELECT id, status, rider_id FROM pickups WHERE id = ?", [id]);
        if (!pickup.length) throw new ApiError(404, "Pickup record not found");

        // 2. Prevent reassigning if already completed or cancelled
        if (['completed', 'cancelled'].includes(pickup[0].status)) {
            throw new ApiError(400, `Cannot reassign a ${pickup[0].status} pickup.`);
        }

        // 3. Perform Reassignment
        await conn.query(
            `UPDATE pickups 
             SET rider_id = ?, 
                 assigned_at = CURRENT_TIMESTAMP,
                 status = 'assigned' 
             WHERE id = ?`,
            [target_rider_id, id]
        );

        // 4. (Optional) Log the change in a pickup_logs table if you have one

        await conn.commit();
        res.json({ success: true, message: "Rider reassigned successfully." });
    } catch (err) {
        await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};
/**
 * 3. UPDATE STATUS (Logistics Flow)
 */
export const updatePickupStatus = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { status, note } = req.body;

        const timeFields = {
            'rider_on_way': 'updated_at',
            'arrived': 'rider_arrived_at',
            'weighing': 'weighing_started_at',
            'cancelled': 'cancelled_at'
        };

        const field = timeFields[status] || 'updated_at';

        await db.query(`UPDATE pickups SET status = ?, ${field} = NOW() WHERE id = ?`, [status, id]);

        await db.query(
            "INSERT INTO pickup_timeline (pickup_id, status, p_timestamp, note) VALUES (?, ?, NOW(), ?)",
            [id, status, note || `Status changed to ${status}`]
        );

        res.json({ success: true, message: `Status updated to ${status}` });
    } catch (err) {
        next(err);
    }
};

/**
 * 4. COMPLETE PICKUP (The Grand Transaction)
 */
export const completePickup = async (req, res, next) => {
    const conn = await db.getConnection();
    const { id: pickupId } = req.params;
    const { items, payment_method } = req.body; // items: [{id, actual_weight, final_rate}]

    try {
        await conn.beginTransaction();

        const [p] = await conn.query(`
            SELECT p.*, c.user_id as customer_uid, r.user_id as rider_uid, a.owner_user_id as agent_uid 
            FROM pickups p
            JOIN customers c ON p.customer_id = c.id
            LEFT JOIN riders r ON p.rider_id = r.id
            LEFT JOIN agents a ON p.agent_id = a.id
            WHERE p.id = ? FOR UPDATE`, [pickupId]);

        if (!p.length || p[0].status === 'completed') throw new ApiError(400, "Invalid pickup or already completed.");
        const pickup = p[0];

        let netPayable = 0;
        let totalWeight = 0;

        // A) Process Weights & Items
        for (const it of items) {
            const amount = parseFloat(it.actual_weight) * parseFloat(it.final_rate);
            netPayable += amount;
            totalWeight += parseFloat(it.actual_weight);

            await conn.query(
                `UPDATE pickup_items SET actual_weight = ?, final_rate = ?, subtotal = ?, updated_at = NOW() WHERE id = ?`,
                [it.actual_weight, it.final_rate, amount, it.id]
            );
        }

        // B) Calculate Commissions (Admin 5%, Agent 5%, Rider 2% incentive)
        const adminComm = netPayable * 0.05;
        const agentComm = netPayable * 0.05;
        const riderComm = netPayable * 0.02;

        // C) Financial Credits (Wallets)
        if (pickup.agent_uid) {
            await updateWallet(conn, pickup.agent_uid, agentComm, 'credit', 'pickup_commission', 'pickup', pickupId,
                `Commission for #${pickup.booking_code}`, `পিকআপ #${pickup.booking_code} এর কমিশন`);
        }

        if (pickup.rider_uid) {
            await updateWallet(conn, pickup.rider_uid, riderComm, 'credit', 'pickup_commission', 'pickup', pickupId,
                `Incentive for #${pickup.booking_code}`, `পিকআপ #${pickup.booking_code} এর ইনসেনটিভ`);
        }

        // D) Customer Payment Logic
        if (payment_method === 'wallet') {
            await updateWallet(conn, pickup.customer_uid, netPayable, 'credit', 'pickup_payment', 'pickup', pickupId,
                `Payment for Pickup #${pickup.booking_code}`, `পিকআপ #${pickup.booking_code} পেমেন্ট`);
        }

        // E) Loyalty Points (1 point for every ৳50)
        const points = Math.floor(netPayable / 50);
        await conn.query("UPDATE customers SET total_points = total_points + ? WHERE id = ?", [points, pickup.customer_id]);

        // F) Finalize Master Record
        const proof = req.file ? req.file.filename : null;
        await conn.query(
            `UPDATE pickups SET 
                status = 'completed', actual_weight_kg = ?, net_payable_amount = ?, 
                admin_commission_amount = ?, agent_commission_amount = ?, rider_commission_amount = ?,
                payment_method = ?, proof_image_after = ?, completed_at = NOW() 
            WHERE id = ?`,
            [totalWeight, netPayable, adminComm, agentComm, riderComm, payment_method, proof, pickupId]
        );

        // G) Log Earnings & Timeline
        await conn.query(
            "INSERT INTO platform_earnings (pickup_id, admin_amount, agent_amount) VALUES (?, ?, ?)",
            [pickupId, adminComm, agentComm]
        );

        await conn.query(
            "INSERT INTO pickup_timeline (pickup_id, status, p_timestamp, note) VALUES (?, 'completed', NOW(), 'Pickup finalized by rider')",
            [pickupId]
        );

        await conn.commit();
        res.json({ success: true, message: "Pickup Finalized!", total_weight: totalWeight, points_earned: points });
    } catch (err) {
        await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};

/**
 * 5. DATA FETCHING (Lists & Details)
 */
export const listAllPickupsAdmin = async (req, res, next) => {
    try {
        const { status, page = 1, limit = 10 } = req.query;
        const offset = (page - 1) * limit;

        // FIXED: Using 'addresses' table and concatenating address fields
        let query = `
            SELECT 
                p.*, 
                u.full_name as customer_name,
                addr.address_line,
                addr.house_no,
                addr.road_no,
                addr.landmark,
                -- Create a clean formatted address string
                CONCAT(
                    COALESCE(addr.address_line, ''), 
                    IF(addr.house_no IS NOT NULL, CONCAT(', House: ', addr.house_no), ''),
                    IF(addr.road_no IS NOT NULL, CONCAT(', Road: ', addr.road_no), '')
                ) as pickup_address,
                upz.name_en as upazila_name
            FROM pickups p 
            JOIN customers c ON p.customer_id = c.id 
            JOIN users u ON c.user_id = u.id
            LEFT JOIN addresses addr ON p.customer_address_id = addr.id
            LEFT JOIN upazilas upz ON addr.upazila_id = upz.id
        `;

        const params = [];
        if (status && status !== 'all') {
            query += " WHERE p.status = ?";
            params.push(status);
        }

        query += " ORDER BY p.created_at DESC LIMIT ? OFFSET ?";
        params.push(parseInt(limit), parseInt(offset));

        const [rows] = await db.query(query, params);

        res.json({
            success: true,
            data: rows
        });
    } catch (err) {
        console.error("SQL Error in listAllPickupsAdmin:", err);
        next(err);
    }
};
/**
 * 10. GET RECEIPT (Post-Completion Invoice)
 * Provides a final summary of weights, rates, and totals for the customer.
 */
export const getReceipt = async (req, res, next) => {
    try {
        const { id } = req.params;

        // 1. Fetch the finalized pickup record
        const [pickup] = await db.query(
            `SELECT 
                p.id, p.booking_code, p.status, p.payment_method, p.payment_status,
                p.total_amount, p.actual_weight_kg, p.net_payable_amount,
                p.completed_at, u.full_name as customer_name, u.phone as customer_phone,
                r_u.full_name as rider_name, ag.name as hub_name
             FROM pickups p 
             JOIN customers c ON p.customer_id = c.id
             JOIN users u ON c.user_id = u.id
             LEFT JOIN riders r ON p.rider_id = r.id
             LEFT JOIN users r_u ON r.user_id = r_u.id
             LEFT JOIN agents ag ON p.agent_id = ag.id
             WHERE p.id = ? AND p.status = 'completed'`,
            [id]
        );

        if (!pickup.length) {
            return res.status(404).json({
                success: false,
                message: "Receipt not found or pickup not yet completed."
            });
        }

        // 2. Fetch the line items with final weights and rates
        const [items] = await db.query(
            `SELECT 
                pi.actual_weight, pi.final_rate, pi.subtotal,
                si.name_en, si.name_bn, si.unit 
             FROM pickup_items pi 
             JOIN scrap_items si ON pi.scrap_item_id = si.id 
             WHERE pi.pickup_id = ?`,
            [id]
        );

        // 3. Return a professional receipt object
        res.json({
            success: true,
            data: {
                receipt_header: {
                    invoice_no: `INV-${pickup[0].booking_code}`,
                    date: pickup[0].completed_at,
                    hub: pickup[0].hub_name
                },
                customer: {
                    name: pickup[0].customer_name,
                    phone: pickup[0].customer_phone
                },
                rider: pickup[0].rider_name,
                items: items,
                totals: {
                    total_weight: pickup[0].actual_weight_kg,
                    net_amount: pickup[0].net_payable_amount,
                    currency: "BDT",
                    payment_method: pickup[0].payment_method
                }
            }
        });
    } catch (err) {
        next(err);
    }
};

export const getPickupDetails = async (req, res, next) => {
    try {
        const { id } = req.params;

        // 1. Fetch main pickup info with Customer, Rider, and Address details
        const [pickup] = await db.query(
            `SELECT 
                p.*, 
                u.full_name as customer_name, 
                u.phone as customer_phone, 
                r_u.full_name as rider_name,
                addr.address_line,
                addr.house_no,
                addr.road_no,
                addr.landmark
             FROM pickups p 
             JOIN customers c ON p.customer_id = c.id 
             JOIN users u ON c.user_id = u.id
             LEFT JOIN riders r ON p.rider_id = r.id 
             LEFT JOIN users r_u ON r.user_id = r_u.id
             LEFT JOIN addresses addr ON p.customer_address_id = addr.id
             WHERE p.id = ?`, [id]
        );

        if (!pickup.length) throw new ApiError(404, "Pickup not found");

        // 2. Fetch Items
        const [items] = await db.query(
            `SELECT pi.*, si.name_en, si.name_bn, si.unit 
             FROM pickup_items pi 
             JOIN scrap_items si ON pi.item_id = si.id 
             WHERE pi.pickup_id = ?`, [id]
        );

        // 3. Fetch Timeline with Assigner Name (JOINED with users)
        const [timeline] = await db.query(
            `SELECT 
                pt.*, 
                u.full_name as changer_name,
                u.role_id as changer_role
             FROM pickup_timeline pt
             LEFT JOIN users u ON pt.changed_by = u.id
             WHERE pt.pickup_id = ? 
             ORDER BY pt.created_at ASC`, [id]
        );

        res.json({
            success: true,
            data: {
                pickup: pickup[0],
                items,
                timeline
            }
        });
    } catch (err) {
        console.error("Detailed Pickup Error:", err);
        next(err);
    }
};

/**
 * 6. ROLE SPECIFIC LISTS
 */
export const listCustomerPickups = async (req, res) => {
    const [rows] = await db.query(
        "SELECT p.* FROM pickups p JOIN customers c ON p.customer_id = c.id WHERE c.user_id = ? ORDER BY p.created_at DESC", [req.user.id]
    );
    res.json({ success: true, data: rows });
};

export const agentPickupList = async (req, res) => {
    const [agent] = await db.query("SELECT id FROM agents WHERE owner_user_id = ?", [req.user.id]);
    const [rows] = await db.query("SELECT p.*, u.full_name AS customer_name FROM pickups p JOIN customers c ON c.id = p.customer_id JOIN users u ON u.id = c.user_id WHERE p.agent_id = ? ORDER BY p.created_at DESC", [agent[0].id]);
    res.json({ success: true, data: rows });
};

export const riderPickupList = async (req, res) => {
    const [rider] = await db.query("SELECT id FROM riders WHERE user_id = ?", [req.user.id]);
    const [rows] = await db.query("SELECT p.*, u.full_name AS customer_name FROM pickups p JOIN customers c ON c.id = p.customer_id JOIN users u ON u.id = c.user_id WHERE p.rider_id = ? AND p.status != 'completed' ORDER BY p.created_at DESC", [rider[0].id]);
    res.json({ success: true, data: rows });
};


