// src/routes/pickupRoutes.js
import express from "express";
import { auth } from "../middlewares/auth.js";
import { uploadPickupPhotos } from "../middlewares/pickupUpload.js";
import {
   createPickup,
   getPickupDetails,
   listCustomerPickups,
   agentPickupList,
   riderPickupList,
   updatePickupStatus,
   completePickup,
   getReceipt,
   reassignSinglePickup,
   listAllPickupsAdmin,
   assignRiderController
} from "../controllers/pickupController.js";

const router = express.Router();

/* ============================================================
    ADMIN ROUTES (Global Oversight)
============================================================ */

/**
 * @route   GET /api/v1/pickups/admin/all
 * @desc    Admin views every pickup across all divisions (Khulna, Dhaka, etc.)
 */
router.get("/admin/all", auth(["admin"]), listAllPickupsAdmin);


/* ============================================================
    MANAGEMENT ROUTES (Admin & Agent Hubs)
============================================================ */

/**
 * @route   PUT /api/v1/pickups/:id/assign-rider
 * @desc    Assign a rider (Admin: any rider, Agent: only their hub staff)
 */
router.put(
   "/:id/assign-rider",
   auth(["admin", "agent"]),
   assignRiderController
);
router.put("/:id/reassign", auth(["admin", "agent"]), reassignSinglePickup);
/**
 * @route   GET /api/v1/pickups/agent/list
 * @desc    Agent sees pickups assigned to their specific Hub/Upazila
 */
router.get("/agent/list", auth(["agent"]), agentPickupList);


/* ============================================================
    CUSTOMER ROUTES
============================================================ */

/**
 * @route   POST /api/v1/pickups/
 * @desc    Customer creates a new request. uploadPickupPhotos.any() allows multiple item photos.
 */
router.post("/", auth(["customer"]), uploadPickupPhotos.any(), createPickup);

/**
 * @route   GET /api/v1/pickups/customer
 * @desc    Customer views their own booking history.
 */
router.get("/customer", auth(["customer"]), listCustomerPickups);

/**
 * @route   GET /api/v1/pickups/:id/receipt
 * @desc    View final digital receipt (invoice) after completion.
 */
router.get("/:id/receipt", auth(["customer", "admin"]), getReceipt);


/* ============================================================
    RIDER (LOGISTICS) ROUTES
============================================================ */

/**
 * @route   GET /api/v1/pickups/rider/list
 * @desc    Rider sees their specific daily tasks/active assignments.
 */
router.get("/rider/list", auth(["rider"]), riderPickupList);

/**
 * @route   PUT /api/v1/pickups/:id/status
 * @desc    Update logistical status (e.g., 'arrived', 'weighing', 'cancelled').
 */
router.put("/:id/status", auth(["rider", "agent", "admin"]), updatePickupStatus);

/**
 * @route   POST /api/v1/pickups/:id/complete
 * @desc    Final Financial Settlement. uploadPickupPhotos.single('proof_image') for scale photo.
 */
router.post(
   "/:id/complete",
   auth(["rider", "admin"]),
   uploadPickupPhotos.single('proof_image'),
   completePickup
);


/* ============================================================
    GENERAL UTILITY (Shared)
============================================================ */

/**
 * @route   GET /api/v1/pickups/:id
 * @desc    Detailed view of a pickup, items, and full timeline.
 */
router.get("/:id", auth(["customer", "agent", "rider", "admin"]), getPickupDetails);

export default router;