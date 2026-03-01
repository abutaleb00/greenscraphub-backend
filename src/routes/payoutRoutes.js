import express from "express";
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
 * @desc    Submit a new withdrawal request (Bank, bKash, etc.)
 */
router.post("/request", auth(["customer", "rider", "agent"]), requestWithdrawal);

/**
 * @route   GET /api/v1/payouts/my-requests
 * @desc    View personal payout history and status
 */
router.get("/my-requests", auth(["customer", "rider", "agent"]), listUserPayouts);


/* ============================================================
   ADMIN ROUTES (Management)
============================================================ */

/**
 * @route   GET /api/v1/payouts/admin/all
 * @desc    List all pending/completed payouts for the whole platform
 */
router.get("/admin/all", auth(["admin"]), adminListAllPayouts);

/**
 * @route   PUT /api/v1/payouts/admin/process/:requestId
 * @desc    Approve (Complete) or Reject a payout request
 */
router.put("/admin/process/:requestId", auth(["admin"]), processPayout);

export default router;