// src/routes/adminUserRoutes.js
import express from "express";
import { body } from "express-validator";
import { auth } from "../middlewares/auth.js";

import {
    createAgentAccount,
    listAgents,
    createRiderAccount,
    listRiders,
    createCustomerAccount,
} from "../controllers/adminUserController.js";

const router = express.Router();

/* ============================================================
   AGENTS (ADMIN ONLY)
============================================================ */

// Admin creates an Agent
router.post(
    "/agents",
    auth(["admin"]),
    [
        body("full_name").notEmpty().withMessage("Full name is required"),
        body("phone").notEmpty().withMessage("Phone is required"),
        body("password")
            .isLength({ min: 6 })
            .withMessage("Password must be at least 6 characters"),
        body("email").optional().isEmail().withMessage("Invalid email"),
        body("company_name").optional(),
    ],
    createAgentAccount
);

// Admin gets list of all Agents
router.get("/agents", auth(["admin"]), listAgents);

/* ============================================================
   RIDERS (ADMIN + AGENT)
============================================================ */

// Create Rider
router.post(
    "/riders",
    auth(["admin", "agent"]),
    [
        body("full_name").notEmpty().withMessage("Full name is required"),
        body("phone").notEmpty().withMessage("Phone is required"),
        body("password")
            .isLength({ min: 6 })
            .withMessage("Password must be at least 6 characters"),
        body("email").optional().isEmail().withMessage("Invalid email"),
        body("vehicle_type").optional(),
        body("vehicle_number").optional(),

        // Only Admin should provide agent_id
        body("agent_id")
            .optional()
            .custom((value, { req }) => {
                if (req.user.role === "admin" && !value) {
                    throw new Error("agent_id is required for admin");
                }
                return true;
            }),
    ],
    createRiderAccount
);

// List Riders
router.get("/riders", auth(["admin", "agent"]), listRiders);

/* ============================================================
   CUSTOMERS (ADMIN + AGENT)
============================================================ */

// Create Customer
router.post(
    "/customers",
    auth(["admin", "agent"]),
    [
        body("full_name").notEmpty().withMessage("Full name is required"),
        body("phone").notEmpty().withMessage("Phone is required"),
        body("password")
            .isLength({ min: 6 })
            .withMessage("Password must be at least 6 characters"),
        body("email").optional().isEmail().withMessage("Invalid email"),
    ],
    createCustomerAccount
);

export default router;
