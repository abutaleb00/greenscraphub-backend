import db from '../../config/db.js';
import ApiError from '../../utils/ApiError.js';

/**
 * GET /api/v1/agents/inventory
 * Fetches item-wise stock levels for the Hub using exact schema fields
 */
export const getHubInventory = async (req, res, next) => {
    try {
        const [agentRows] = await db.query(
            "SELECT id FROM agents WHERE owner_user_id = ?",
            [req.user.id]
        );

        if (!agentRows.length) {
            return res.status(404).json({ success: false, message: "Agent Hub not found" });
        }

        const agentId = agentRows[0].id;

        /**
         * UPDATED LOGIC:
         * 1. Join hub_inventory (hi) with scrap_categories (sc) because hi stores category_id.
         * 2. Use a subquery to get the average buy price from pickup_items based on category.
         */
        const [inventory] = await db.query(`
            SELECT 
                sc.id as category_id,
                sc.name_en as category_name,
                hi.current_weight,
                -- Average buy price for all items in this category at this hub
                (SELECT AVG(pi.final_rate_per_unit) 
                 FROM pickup_items pi 
                 JOIN pickups p ON pi.pickup_id = p.id 
                 JOIN scrap_items si ON pi.item_id = si.id
                 WHERE si.category_id = sc.id 
                   AND p.agent_id = ? 
                   AND p.status = 'completed') as avg_buy_price
            FROM hub_inventory hi
            JOIN scrap_categories sc ON hi.category_id = sc.id
            WHERE hi.agent_id = ? AND hi.current_weight > 0
            ORDER BY hi.current_weight DESC`, [agentId, agentId]);

        // Calculate Totals for HUD
        const totalWeight = inventory.reduce((acc, item) => acc + parseFloat(item.current_weight || 0), 0);

        // Note: For valuation, you might want to join market rates from categories if available, 
        // otherwise we use avg_buy_price as a placeholder valuation
        const valuation = inventory.reduce((acc, item) => {
            const price = parseFloat(item.avg_buy_price || 0);
            const weight = parseFloat(item.current_weight || 0);
            return acc + (weight * price);
        }, 0);

        res.json({
            success: true,
            stats: {
                total_weight: totalWeight.toFixed(2),
                valuation: valuation.toFixed(2),
                category_count: inventory.length,
                last_stock_update: new Date().toISOString()
            },
            data: inventory
        });
    } catch (err) {
        console.error("Inventory Fetch Error:", err);
        next(err);
    }
};

/**
 * POST /api/v1/agents/inventory/release
 * Logic: Deducts weight from stock based on item_id
 */
export const releaseInventory = async (req, res, next) => {
    const { items } = req.body;
    if (!items || !Array.isArray(items)) {
        return res.status(400).json({ success: false, message: "Payload 'items' must be an array." });
    }

    const conn = await db.getConnection();
    try {
        await conn.beginTransaction();
        const [agent] = await conn.query("SELECT id FROM agents WHERE owner_user_id = ?", [req.user.id]);
        const agentId = agent[0].id;

        let totalRevenue = 0;

        for (const item of items) {
            const weight = parseFloat(item.weight_to_release);
            const price = parseFloat(item.sale_price_per_kg || 0);

            // Deduct from Hub Inventory using item_id (stored in category_id column of hi)
            await conn.query(
                `UPDATE hub_inventory 
                 SET current_weight = current_weight - ? 
                 WHERE agent_id = ? AND category_id = ?`,
                [weight, agentId, item.category_id]
            );

            totalRevenue += (weight * price);
        }

        await conn.query(
            `INSERT INTO hub_releases (agent_id, total_revenue, status) VALUES (?, ?, 'sold')`,
            [agentId, totalRevenue]
        );

        await conn.commit();
        res.json({ success: true, message: "Inventory released successfully." });
    } catch (err) {
        await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};

/**
 * GET /api/v1/agents/inventory/history
 * Shows the "Inflow" history—which bookings added weight to the stock.
 */
export const getStockHistory = async (req, res, next) => {
    try {
        const [agentRows] = await db.query(
            "SELECT id FROM agents WHERE owner_user_id = ?",
            [req.user.id]
        );
        const agentId = agentRows[0].id;

        const [history] = await db.query(`
            SELECT 
                p.booking_code,
                si.name_en as item_name,
                pi.actual_weight,
                si.unit,
                pi.final_rate_per_unit as buy_rate,
                p.completed_at as stocked_at,
                p.rider_collected_cash
            FROM pickup_items pi
            JOIN pickups p ON pi.pickup_id = p.id
            JOIN scrap_items si ON pi.item_id = si.id
            WHERE p.agent_id = ? AND p.is_settled_to_hub = 1
            ORDER BY p.completed_at DESC
            LIMIT 50`, [agentId]);

        res.json({ success: true, data: history });
    } catch (err) {
        next(err);
    }
};