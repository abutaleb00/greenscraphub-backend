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
         * LOGIC:
         * - Join hub_inventory with scrap_items (si) to get names and market rates.
         * - Use a subquery on pickup_items (pi) to get the average price paid.
         * - Columns matched to your schema: si.current_min_rate, pi.final_rate_per_unit, si.name_en
         */
        const [inventory] = await db.query(`
            SELECT 
                si.id as item_id,
                si.name_en as item_name,
                si.unit as unit, 
                hi.current_weight,
                si.current_min_rate as market_price, 
                (SELECT AVG(pi.final_rate_per_unit) 
                 FROM pickup_items pi 
                 JOIN pickups p ON pi.pickup_id = p.id 
                 WHERE pi.item_id = si.id 
                   AND p.agent_id = ? 
                   AND p.status = 'completed') as avg_buy_price
            FROM hub_inventory hi
            JOIN scrap_items si ON hi.category_id = si.id
            WHERE hi.agent_id = ? AND hi.current_weight > 0
            ORDER BY hi.current_weight DESC`, [agentId, agentId]);

        // Calculate Totals for HUD
        const totalWeight = inventory.reduce((acc, item) => acc + parseFloat(item.current_weight || 0), 0);

        // Valuation: Current Weight * Market Price (current_min_rate)
        const valuation = inventory.reduce((acc, item) => {
            const mPrice = parseFloat(item.market_price || 0);
            const weight = parseFloat(item.current_weight || 0);
            return acc + (weight * mPrice);
        }, 0);

        res.json({
            success: true,
            stats: {
                total_weight: totalWeight.toFixed(2),
                valuation: valuation.toFixed(2),
                item_count: inventory.length,
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