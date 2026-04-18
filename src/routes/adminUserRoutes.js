// src/routes/adminUserRoutes.js
import express from "express";
import { body } from "express-validator";
import { auth } from "../middlewares/auth.js";

import {
    createAgentAccount,
    listAgents,
    updateAgentAccount,    // NEW
    deleteAgentAccount,    // NEW
    createRiderAccount,
    updateRiderAccount,
    listRiders,
    reassignRiders,
    reassignRiderPickups,
    deleteRiderAccount,
    permanentDeleteRider,
    permanentDeleteAgent,
    createCustomerAccount,
    listCustomers,
    updateCustomer,
    permanentDeleteCustomer,
    assignPickupToAgent,
    getActivityLogs
} from "../controllers/adminUserController.js";
import { upsertPriceOverride, getItemOverrides, getAdminPriceIndex, getPriceHistory } from "../controllers/priceOverrideController.js";
import { getCommissionSettings, updateAgentCommission } from '../controllers/commissionController.js';
const router = express.Router();

/* ============================================================
    AGENTS (ADMIN ONLY)
============================================================ */

/**
 * @route   POST /api/v1/admin-users/agents
 * @desc    Admin creates a new Agent Hub
 * @access  Private (Admin)
 */
router.post(
    "/agents",
    auth(["admin"]),
    [
        body("full_name").notEmpty().withMessage("Full name is required"),
        body("phone")
            .notEmpty().withMessage("Phone is required")
            .isLength({ min: 11, max: 15 }).withMessage("Valid phone number required"),
        body("password")
            .isLength({ min: 6 })
            .withMessage("Password must be at least 6 characters"),
        body("email").optional().isEmail().withMessage("Invalid email format"),
        body("business_name").notEmpty().withMessage("Business/Agency name is required"),
        body("area_coverage").optional().isString().withMessage("Area coverage must be text"),
    ],
    createAgentAccount
);

// GET all hub commission settings
router.get('/settings/commissions', auth(["admin"]), getCommissionSettings);

// UPDATE a specific hub's rates (Platform fee, default rider mode)
router.patch('/agents/:id/rates', auth(["admin"]), updateAgentCommission);
/**
 * @route   GET /api/v1/admin-users/agents
 * @desc    Get list of all Agents with their wallet balances
 * @access  Private (Admin)
 */
router.get("/agents", auth(["admin"]), listAgents);

/**
 * @route   PUT /api/v1/management/agents/:id
 * @desc    Update Agent and associated User info
 */
router.put(
    "/agents/:id",
    auth(["admin"]),
    [
        body("full_name").optional().notEmpty(),
        body("business_name").optional().notEmpty(),
    ],
    updateAgentAccount
);

/**
 * @route   DELETE /api/v1/management/agents/:id
 * @desc    Soft-delete or deactivate Agent
 */
router.post(
    '/admin/assign-to-agent',
    auth(['admin']), // Security: Only Admins can force assign
    [
        body('pickup_id').isInt().withMessage('Valid Pickup ID required'),
        body('agent_id').isInt().withMessage('Valid Agent ID required')
    ],
    assignPickupToAgent
);
router.post("/agents/reassign-riders", auth(["admin"]), reassignRiders);
router.delete("/agents/:id", auth(["admin"]), deleteAgentAccount);
router.delete("/agents/:id/permanent", auth(["admin"]), permanentDeleteAgent);
/* ============================================================
    RIDERS (ADMIN + AGENT)
============================================================ */

/**
 * @route   POST /api/v1/admin-users/riders
 * @desc    Admin or Agent creates a Rider account
 * @access  Private (Admin, Agent)
 */
router.post(
    "/riders",
    auth(["admin", "agent"]),
    [
        body("full_name").notEmpty().withMessage("Full name is required"),
        body("phone").notEmpty().withMessage("Phone is required"),
        body("password")
            .isLength({ min: 6 })
            .withMessage("Password must be at least 6 characters"),
        body("email").optional().isEmail().withMessage("Invalid email format"),
        body("vehicle_type").notEmpty().withMessage("Vehicle type is required (e.g., Van, Rickshaw, Bicycle)"),
        body("vehicle_number").optional().isString(),

        // Validation Logic: If Admin is creating, agent_id is mandatory. 
        // If Agent is creating, it's pulled from their session in the controller.
        body("agent_id")
            .optional()
            .custom((value, { req }) => {
                if (req.user.role === "admin" && !value) {
                    throw new Error("As an Admin, you must assign this rider to an agent_id");
                }
                return true;
            }),
    ],
    createRiderAccount
);

router.put(
    "/riders/:id",
    auth(["admin", "agent"]),
    [
        body("full_name").optional().notEmpty(),
        body("phone").optional().notEmpty(),
        body("email").optional().isEmail(),
        body("vehicle_type").optional().isIn(['bicycle', 'van', 'motorcycle', 'truck', 'rickshaw']),
        body("payment_mode").optional().isIn(['commission', 'salary', 'default']),
        body("is_active").optional().isIn([0, 1])
    ],
    updateRiderAccount
);
/**
 * @route   GET /api/v1/admin-users/riders
 * @desc    List Riders (Admins see all, Agents see only their own staff)
 * @access  Private (Admin, Agent)
 */
router.get("/riders", auth(["admin", "agent"]), listRiders);
router.post("/riders/reassign-pickups", auth(["admin", "agent"]), reassignRiderPickups);
// Soft Delete: Just marks as inactive
router.delete("/riders/:id", auth(["admin", "agent"]), deleteRiderAccount);

// Permanent Purge: Removes all data nodes
router.delete("/riders/:id/permanent", auth(["admin"]), permanentDeleteRider);

/* ============================================================
    CUSTOMERS (ADMIN + AGENT)
============================================================ */

/**
 * @route   POST /api/v1/admin-users/customers
 * @desc    Manually create a customer account (e.g., for walk-in users)
 * @access  Private (Admin, Agent)
 */
router.post(
    "/customers",
    auth(["admin", "agent"]),
    [
        body("full_name").notEmpty().withMessage("Full name is required"),
        body("phone").notEmpty().withMessage("Phone is required"),
        body("password")
            .isLength({ min: 6 })
            .withMessage("Password must be at least 6 characters"),
        body("email").optional().isEmail().withMessage("Invalid email format"),
    ],
    createCustomerAccount
);

// Customer Management
router.get("/customers", auth(["admin", "agent"]), listCustomers);
router.put("/customers/:id", auth(["admin"]), updateCustomer); // Also handles deactivation
router.delete("/customers/:id/permanent", auth(["admin"]), permanentDeleteCustomer);
// Price Override
router.post("/price-overrides", auth(["admin"]), upsertPriceOverride);
router.get("/price-overrides/list", auth(["admin"]), getAdminPriceIndex);
router.get("/prices/history/:item_id", auth(["admin"]), getPriceHistory);
router.get("/price-overrides/:item_id", auth(["admin"]), getItemOverrides);
router.get("/activity-logs", auth(["admin"]), getActivityLogs);
export default router;