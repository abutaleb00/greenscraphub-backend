import db from "../../config/db.js";
import ApiError from "../../utils/ApiError.js";
import { sendUnifiedReceipt } from "../../services/mailService.js";

/**
 * GET UNIFIED RECEIPT
 * Fetches order, items, and triggers email dispatch.
 */
export const getUnifiedReceipt = async (req, res, next) => {
    try {
        const { id: pickupId } = req.params;
        const { id: userId, role: userRole } = req.user;

        // 1. Fetch Master Receipt Data
        const [rows] = await db.query(`
            SELECT 
                p.id, p.booking_code, p.status, p.payment_method, p.payment_status,
                p.net_payable_amount, p.completed_at, p.rider_collected_cash,
                -- Customer Details
                u_cust.full_name as customer_name, 
                u_cust.phone as customer_phone, 
                u_cust.email as customer_email,
                u_cust.id as customer_uid,
                -- Rider Details
                u_rider.full_name as rider_name, 
                u_rider.phone as rider_phone,
                r.id as rider_id,
                r.user_id as rider_uid,
                -- Hub/Agent Details
                a.business_name as hub_name, 
                a.address_line as hub_address, 
                a.owner_user_id as agent_uid,
                u_agent.email as agent_email
            FROM pickups p
            JOIN customers c ON p.customer_id = c.id
            JOIN users u_cust ON c.user_id = u_cust.id
            LEFT JOIN riders r ON p.rider_id = r.id
            LEFT JOIN users u_rider ON r.user_id = u_rider.id
            LEFT JOIN agents a ON p.agent_id = a.id
            LEFT JOIN users u_agent ON a.owner_user_id = u_agent.id
            WHERE p.id = ?`, [pickupId]);

        if (!rows.length) {
            throw new ApiError(404, "Transaction record not found.");
        }

        const receipt = rows[0];

        // 2. Security: Authorization Check
        const isAuthorized =
            userRole === 'admin' ||
            receipt.customer_uid === userId ||
            receipt.rider_uid === userId ||
            receipt.agent_uid === userId;

        if (!isAuthorized) {
            throw new ApiError(403, "Access Denied: You are not a party to this transaction.");
        }

        // 3. Fetch Itemized Breakdown
        const [items] = await db.query(`
            SELECT 
                pi.id, 
                pi.actual_weight, 
                pi.final_rate_per_unit, 
                pi.final_amount,
                si.name_en as item_name,
                cat.name_en as category_name
            FROM pickup_items pi
            JOIN scrap_items si ON pi.item_id = si.id
            JOIN scrap_categories cat ON si.category_id = cat.id
            WHERE pi.pickup_id = ?`, [pickupId]);

        // 4. Background Task: Trigger Email + PDF Generation
        // Using setImmediate so the user gets the JSON response instantly 
        // while the server processes the PDF/Email in the background.
        
        // if (receipt.status === 'completed') {
        //     setImmediate(() => {
        //         sendUnifiedReceipt(receipt, items).catch(err =>
        //             console.error("Background Mail Error:", err)
        //         );
        //     });
        // }

        // 5. Return Consolidated Response
        res.status(200).json({
            success: true,
            data: {
                ...receipt,
                items: items || []
            }
        });

    } catch (err) {
        next(err);
    }
};

/**
 * MANUALLY RESEND RECEIPT
 * Specifically for Admin/Agent to re-trigger the email service.
 */
export const resendReceiptEmail = async (req, res, next) => {
    try {
        const { id: pickupId } = req.params;

        // Fetch same data as above
        const [rows] = await db.query(`
             SELECT p.*, uc.full_name as customer_name, uc.email as customer_email, 
             ua.email as agent_email, a.business_name as hub_name
             FROM pickups p
             JOIN customers c ON p.customer_id = c.id JOIN users uc ON c.user_id = uc.id
             JOIN agents a ON p.agent_id = a.id JOIN users ua ON a.owner_user_id = ua.id
             WHERE p.id = ?`, [pickupId]);

        const [items] = await db.query(`
            SELECT pi.*, si.name_en as item_name 
            FROM pickup_items pi JOIN scrap_items si ON pi.item_id = si.id 
            WHERE pi.pickup_id = ?`, [pickupId]);

        if (!rows.length) throw new ApiError(404, "Order not found.");

        await sendUnifiedReceipt(rows[0], items);

        res.json({ success: true, message: "Receipt re-sent successfully." });
    } catch (err) {
        next(err);
    }
};