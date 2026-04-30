import express from "express";
import { auth } from "../middlewares/auth.js";
import { uploadPickupPhotos } from "../middlewares/pickupUpload.js";

// 1. Logistics: Booking & Creation
import {
    createPickup,
    listCustomerPickups,
    listAllPickupsAdmin,
    archivePickup,
    deletePickupAdmin,
    bulkDeletePickups,
    createOrderAsAdmin
} from "../controllers/logistics/bookingController.js";

// 2. Logistics: Dispatch & Rider Assignment
import {
    assignRiderController,
    reassignSinglePickup,
    updatePickupStatus,
    agentPickupList,
    riderPickupList
} from "../controllers/logistics/dispatchController.js";

// 3. Logistics: Settlement, Details & Leader System
import {
    completePickup,
    getReceipt,
    getPickupDetails,
    getPickupTimeline,
    openRiderShift,
    settleRiderShift,
    settleRiderIntent,
    getHubRiderStatus,
    reconcileRiderAccount,
    getHubTransactionHistory
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
    ADMIN & AUDIT ROUTES
============================================================ */

/** @desc Admin views every pickup across all divisions */
router.get("/admin/all", auth(["admin"]), listAllPickupsAdmin);

/** @desc Admin manually adjusts customer points */
router.patch("/admin/points/adjust", auth(["admin"]), adminAdjustPoints);

/** @desc Archive a single pickup request (Soft delete) */
router.patch('/admin/archive/:id', auth(["admin"]), archivePickup);

/** @desc Permanent delete a pickup (Admin only) */
router.delete('/admin/delete/:id', auth(["admin"]), deletePickupAdmin);

/** @desc Bulk cleanup of pickup requests */
router.post('/admin/bulk-cleanup', auth(["admin"]), bulkDeletePickups);

/** @desc Place an order manually from the Admin panel */
router.post('/admin/place-order', auth(["admin"]), uploadPickupPhotos.any(), createOrderAsAdmin);


/* ============================================================
    LEADER SYSTEM (Shift & Cash Management)
============================================================ */

/** @desc Morning: Admin/Agent issues cash to Rider and starts shift */
router.post("/shift/open", auth(["admin", "agent"]), openRiderShift);

/** @desc Admin views the live status of all riders for cash/load management */
router.get("/hub/rider-status", auth(["admin", "agent"]), getHubRiderStatus);
router.get("/hub/transaction-history", auth(["admin", "agent"]), getHubTransactionHistory);
/** @desc Rider: Declaration of returning cash/scrap from the App */
router.post("/shift/settle-intent", auth(["rider"]), settleRiderIntent);

/** @desc Evening: Admin/Agent finalizes cash and scrap return (Deducts from liability) */
router.post("/shift/settle", auth(["admin", "agent"]), settleRiderShift);

/** @desc Sync/Reconcile the rider's cash held liability with the database audit trail */
router.post("/shift/reconcile", auth(["rider"]), reconcileRiderAccount);


/* ============================================================
    MANAGEMENT ROUTES (Dispatch & Hub Ops)
============================================================ */

/** @desc Assign a rider to a pending pickup */
router.put("/:id/assign-rider", auth(["admin", "agent"]), assignRiderController);

/** @desc Reassign a pickup to a different rider */
router.put("/:id/reassign", auth(["admin", "agent"]), reassignSinglePickup);

/** @desc Agent sees pickups assigned to their specific Hub */
router.get("/agent/list", auth(["agent"]), agentPickupList);


/* ============================================================
    CUSTOMER ROUTES (Bookings & Rewards)
============================================================ */

/** @desc Customer creates a new request */
router.post("/", auth(["customer"]), uploadPickupPhotos.any(), createPickup);

/** @desc Customer views their own booking history */
router.get("/customer", auth(["customer"]), listCustomerPickups);

/** @desc View final digital receipt after completion */
router.get("/:id/receipt", auth(["customer", "rider", "agent", "admin"]), getReceipt);

/** @desc Redeem points to Wallet Balance */
router.post("/points/redeem", auth(["customer"]), redeemPoints);

/** @desc Customer views their point history */
router.get("/points/my-history", auth(["customer"]), getMyPointHistory);


/* ============================================================
    RIDER (LOGISTICS) ROUTES
=========================================================== */

/** @desc Rider sees their specific assigned daily tasks */
router.get("/rider/list", auth(["rider"]), riderPickupList);

/** @desc Rider updates status (on_way, arrived, etc) */
router.put("/:id/status", auth(["rider", "agent", "admin"]), updatePickupStatus);

/** @desc Final Financial Settlement: Rider pays customer, uploads weight/proof */
router.post(
    "/:id/complete",
    auth(["rider", "admin"]),
    uploadPickupPhotos.single('proof_image'),
    completePickup
);


/* ============================================================
    GENERAL UTILITY (Shared)
============================================================ */

/** @desc Detailed view of a pickup (Used for Map tracking & briefings) */
router.get("/:id", auth(["customer", "agent", "rider", "admin"]), getPickupDetails);

/** @desc Full timeline/audit log of a specific pickup */
router.get("/:id/timeline", auth(["admin", "agent", "rider"]), getPickupTimeline);

/** @desc Global Leaderboard for gamification */
router.get("/rewards/leaderboard", auth(["customer", "agent", "rider", "admin"]), getLeaderboard);

export default router;