// src/routes/payoutRoutes.js
import express from "express";
import { body } from "express-validator";
import { auth } from "../middlewares/auth.js";
import {
   requestWithdrawal,
   listUserPayouts,
   adminListAllPayouts,
   processPayout,
   getWithdrawalSettings
} from "../controllers/payoutController.js";

const router = express.Router();

/* ============================================================
    USER ROUTES (Customer, Rider, Agent)
============================================================ */

/**
 * @route   GET /api/v1/payouts/settings
 * @desc    Fetch dynamic system settings for withdrawals (e.g., min amount)
 * @access  Private
 */
router.get("/settings", auth(["customer", "rider", "agent", "admin"]), getWithdrawalSettings);

/**
 * @route   POST /api/v1/payouts/request
 */
router.post(
   "/request",
   auth(["customer", "rider", "agent"]),
   [
      body("amount")
         .isFloat({ gt: 0 })
         .withMessage("Withdrawal amount must be greater than zero"),
      body("method")
         .isIn(["bkash", "nagad", "bank", "rocket"])
         .withMessage("Please select a valid payment method"),
      body("account_details")
         .notEmpty()
         .withMessage("Account details are required")
   ],
   requestWithdrawal
);

router.get("/my-requests", auth(["customer", "rider", "agent"]), listUserPayouts);

/* ============================================================
    ADMIN ROUTES
============================================================ */
router.get("/admin/all", auth(["admin"]), adminListAllPayouts);
router.put("/admin/process/:requestId", auth(["admin"]), processPayout);

export default router;