import express from "express";
import { auth } from "../middlewares/auth.js";
import { uploadPickupPhotos } from "../middlewares/pickupUpload.js";

// 1. Logistics: Booking & Creation
import {
    createPickup,
    listCustomerPickups,
    listAllPickupsAdmin
} from "../controllers/logistics/bookingController.js";

// 2. Logistics: Dispatch & Rider Assignment
import {
    assignRiderController,
    reassignSinglePickup,
    updatePickupStatus,
    agentPickupList,
    riderPickupList
} from "../controllers/logistics/dispatchController.js";

// 3. Logistics: Settlement & Details
import {
    completePickup,
    getReceipt,
    getPickupDetails
} from "../controllers/logistics/settlementController.js";

// 4. Rewards: Points & Leaderboard
import {
    redeemPoints,
    getLeaderboard,
    getMyPointHistory,
    adminAdjustPoints
} from "../controllers/pointController.js";

const router = express.Router();

/* ============================================================
    ADMIN ROUTES (Global Oversight & Audit)
============================================================ */

/** @desc Admin views every pickup across all divisions */
router.get("/admin/all", auth(["admin"]), listAllPickupsAdmin);

/** @desc Admin manually adjusts customer points (e.g. Support resolution) */
router.patch("/admin/points/adjust", auth(["admin"]), adminAdjustPoints);


/* ============================================================
    MANAGEMENT ROUTES (Admin & Agent Hubs)
============================================================ */

/** @desc Assign a rider (Agent: only hub staff | Admin: global) */
router.put("/:id/assign-rider", auth(["admin", "agent"]), assignRiderController);

/** @desc Reassign a pickup to a different rider */
router.put("/:id/reassign", auth(["admin", "agent"]), reassignSinglePickup);

/** @desc Agent sees pickups assigned to their specific Hub/Upazila */
router.get("/agent/list", auth(["agent"]), agentPickupList);


/* ============================================================
    CUSTOMER ROUTES (Rewards & Bookings)
============================================================ */

/** @desc Customer creates a new request with optional photos */
router.post("/", auth(["customer"]), uploadPickupPhotos.any(), createPickup);

/** @desc Customer views their own booking history */
router.get("/customer", auth(["customer"]), listCustomerPickups);

/** @desc View final digital receipt/invoice after completion */
router.get("/:id/receipt", auth(["customer", "admin"]), getReceipt);

/** @desc Redeem points to Wallet Balance (10:1 Ratio) */
router.post("/points/redeem", auth(["customer"]), redeemPoints);

/** @desc Customer views their specific point earning/spending history */
router.get("/points/my-history", auth(["customer"]), getMyPointHistory);


/* ============================================================
    RIDER (LOGISTICS) ROUTES
=========================================================== */

/** @desc Rider sees their specific daily tasks */
router.get("/rider/list", auth(["rider"]), riderPickupList);

/** @desc Update status (e.g. 'rider_on_way', 'arrived', 'weighing') */
router.put("/:id/status", auth(["rider", "agent", "admin"]), updatePickupStatus);

/** @desc Final Financial Settlement with proof of weight/image */
router.post(
    "/:id/complete",
    auth(["rider", "admin"]),
    uploadPickupPhotos.single('proof_image'),
    completePickup
);


/* ============================================================
    GENERAL UTILITY & COMPETITION (Shared)
============================================================ */

/** @desc Global Leaderboard (Accessible to all for gamification) */
router.get("/rewards/leaderboard", auth(["customer", "agent", "rider", "admin"]), getLeaderboard);

/** @desc Detailed view of a pickup, items, and full activity timeline */
router.get("/:id", auth(["customer", "agent", "rider", "admin"]), getPickupDetails);

export default router;