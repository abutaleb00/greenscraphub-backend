import db from '../config/db.js';

/**
 * GET Admin Settings for Commissions
 * Fetches all agents with their platform fee and rider defaults
 */
export const getCommissionSettings = async (req, res, next) => {
    try {
        const [agents] = await db.query(`
            SELECT id, company_name_en, platform_fee_percent, 
            default_rider_mode, hub_commission_type, hub_commission_value 
            FROM agents ORDER BY company_name_en ASC
        `);
        res.json({ success: true, data: agents });
    } catch (err) { next(err); }
};

/**
 * UPDATE Agent/Hub Commission (Admin Only)
 */
export const updateAgentCommission = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { platform_fee_percent, default_rider_mode, hub_commission_type, hub_commission_value } = req.body;

        await db.query(`
            UPDATE agents SET 
                platform_fee_percent = ?, 
                default_rider_mode = ?, 
                hub_commission_type = ?, 
                hub_commission_value = ? 
            WHERE id = ?`,
            [platform_fee_percent, default_rider_mode, hub_commission_type, hub_commission_value, id]
        );

        res.json({ success: true, message: "Hub settings updated." });
    } catch (err) { next(err); }
};

/**
 * UPDATE Specific Rider Commission (Admin or Agent)
 */
export const updateRiderCommission = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { payment_mode, commission_type, commission_value } = req.body;

        // Note: setting values to NULL in SQL allows them to "default" to Hub settings
        await db.query(`
            UPDATE riders SET 
                payment_mode = ?, 
                commission_type = ?, 
                commission_value = ? 
            WHERE id = ?`,
            [payment_mode, commission_type || null, commission_value || null, id]
        );

        res.json({ success: true, message: "Rider contract updated." });
    } catch (err) { next(err); }
};