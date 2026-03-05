import db from "../../config/db.js";
import ApiError from "../../utils/ApiError.js";

export const assignRiderController = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const { id: pickupId } = req.params;
        const { rider_id } = req.body;
        const changerId = req.user.id;

        await conn.beginTransaction();

        // 1. Get Rider and their Hub Info
        const [riderRows] = await conn.query(
            "SELECT r.id, r.agent_id, u.full_name FROM riders r JOIN users u ON r.user_id = u.id WHERE r.id = ?",
            [rider_id]
        );
        if (!riderRows.length) throw new ApiError(404, "Rider not found");
        const rider = riderRows[0];

        // 2. Update Pickup
        // We allow 'pending' (Direct) or 'assigned' (Hub-led)
        // We change status to 'accepted' so the Rider knows they have work
        const [updateResult] = await conn.query(
            `UPDATE pickups SET 
                rider_id = ?, 
                agent_id = ?, 
                status = 'accepted', 
                assigned_at = NOW(),
                updated_at = NOW()
             WHERE id = ? AND status IN ('pending', 'assigned')`,
            [rider.id, rider.agent_id, pickupId]
        );

        if (updateResult.affectedRows === 0) {
            throw new ApiError(400, "Pickup is already being processed by a rider or has been completed.");
        }

        // 3. Timeline
        await conn.query(
            "INSERT INTO pickup_timeline (pickup_id, status, changed_by, note) VALUES (?, 'accepted', ?, ?)",
            [pickupId, changerId, `Dispatched to Rider: ${rider.full_name}`]
        );

        await conn.commit();
        res.json({ success: true, message: `Rider ${rider.full_name} has been dispatched.` });
    } catch (err) {
        await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};

export const updatePickupStatus = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { status, note } = req.body;
        const allowedStatuses = ['rider_on_way', 'arrived', 'weighing', 'cancelled'];

        if (!allowedStatuses.includes(status)) throw new ApiError(400, "Invalid status transition");

        await db.query(`UPDATE pickups SET status = ?, updated_at = NOW() WHERE id = ?`, [status, id]);
        await db.query(
            "INSERT INTO pickup_timeline (pickup_id, status, p_timestamp, note) VALUES (?, ?, NOW(), ?)",
            [id, status, note || `Status: ${status}`]
        );

        res.json({ success: true, message: `Status updated to ${status}` });
    } catch (err) { next(err); }
};

/**
 * AGENT PICKUP LIST
 * Shows all pickups assigned to a specific hub/agent
 */
export const agentPickupList = async (req, res, next) => {
    try {
        // 1. Get Agent ID from the logged-in user
        const [agent] = await db.query(
            "SELECT id FROM agents WHERE owner_user_id = ?",
            [req.user.id]
        );

        if (!agent.length) return res.json({ success: true, data: [] });

        // 2. Fetch pickups for this agent
        const [rows] = await db.query(
            `SELECT p.*, u.full_name AS customer_name, u.phone as customer_phone
             FROM pickups p 
             JOIN customers c ON c.id = p.customer_id 
             JOIN users u ON u.id = c.user_id 
             WHERE p.agent_id = ? 
             ORDER BY p.created_at DESC`,
            [agent[0].id]
        );

        res.json({ success: true, data: rows });
    } catch (err) {
        next(err);
    }
};

/**
 * RIDER PICKUP LIST
 * Shows active tasks assigned to the specific rider
 */
export const riderPickupList = async (req, res, next) => {
    try {
        // 1. Get Rider ID from the logged-in user
        const [rider] = await db.query(
            "SELECT id FROM riders WHERE user_id = ?",
            [req.user.id]
        );

        if (!rider.length) return res.json({ success: true, data: [] });

        // 2. Fetch active (non-completed) pickups for this rider
        const [rows] = await db.query(
            `SELECT p.*, u.full_name AS customer_name, u.phone as customer_phone
             FROM pickups p 
             JOIN customers c ON c.id = p.customer_id 
             JOIN users u ON u.id = c.user_id 
             WHERE p.rider_id = ? AND p.status != 'completed' 
             ORDER BY p.created_at DESC`,
            [rider[0].id]
        );

        res.json({ success: true, data: rows });
    } catch (err) {
        next(err);
    }
};

/**
 * REASSIGN SINGLE PICKUP
 */
export const reassignSinglePickup = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const { id } = req.params;
        const { target_rider_id } = req.body;

        await conn.beginTransaction();

        const [pickup] = await conn.query("SELECT status FROM pickups WHERE id = ?", [id]);
        if (!pickup.length) throw new ApiError(404, "Pickup not found");
        if (['completed', 'cancelled'].includes(pickup[0].status)) {
            throw new ApiError(400, "Cannot reassign a finished job");
        }

        await conn.query(
            "UPDATE pickups SET rider_id = ?, assigned_at = NOW(), status = 'assigned' WHERE id = ?",
            [target_rider_id, id]
        );

        await conn.query(
            "INSERT INTO pickup_timeline (pickup_id, status, note) VALUES (?, 'assigned', ?)",
            [id, `Job reassigned to Rider ID: ${target_rider_id}`]
        );

        await conn.commit();
        res.json({ success: true, message: "Rider reassigned successfully." });
    } catch (err) {
        await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};