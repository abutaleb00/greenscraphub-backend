// src/routes/payoutRoutes.js
import express from "express";
import { body } from "express-validator";
import { auth } from "../middlewares/auth.js";
import {
   requestWithdrawal,
   listUserPayouts,
   adminListAllPayouts,
   processPayout
} from "../controllers/payoutController.js";

const router = express.Router();

/* ============================================================
    USER ROUTES (Customer, Rider, Agent)
============================================================ */

/**
 * @route   POST /api/v1/payouts/request
 * @desc    Submit a new withdrawal request (Bank, bKash, Nagad, etc.)
 * @access  Private (All Users with Balance)
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
         .withMessage("Account details (e.g., phone number or bank info) are required")
   ],
   requestWithdrawal
);

/**
 * @route   GET /api/v1/payouts/my-requests
 * @desc    View personal payout history and status
 * @access  Private (Owner only)
 */
router.get("/my-requests", auth(["customer", "rider", "agent"]), listUserPayouts);


/* ============================================================
    ADMIN ROUTES (Management)
============================================================ */

/**
 * @route   GET /api/v1/payouts/admin/all
 * @desc    List all payouts for the whole platform (Filterable by status)
 * @access  Private (Admin Only)
 */
router.get("/admin/all", auth(["admin"]), adminListAllPayouts);

/**
 * @route   PUT /api/v1/payouts/admin/process/:requestId
 * @desc    Approve (Complete) or Reject a payout request with Transaction ID
 * @access  Private (Admin Only)
 */
router.put(
   "/admin/process/:requestId",
   auth(["admin"]),
   [
      body("status")
         .isIn(["completed", "rejected"])
         .withMessage("Status must be either completed or rejected"),
      body("admin_note")
         .optional()
         .isString(),
      // transaction_id is mandatory if completing the payout
      body("transaction_id").custom((value, { req }) => {
         if (req.body.status === 'completed' && !value) {
            throw new Error("Transaction ID is required to complete a payout");
         }
         return true;
      })
   ],
   processPayout
);

export default router;