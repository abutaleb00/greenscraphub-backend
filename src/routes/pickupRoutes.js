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
    getReceipt
} from "../controllers/pickupController.js";

const router = express.Router();

/* ============================================================
   CUSTOMER ROUTES
============================================================ */

/**
 * @route   POST /api/v1/pickups
 * @desc    Create a new pickup request with multiple items and photos
 * Note: .any() is used to handle dynamic fields like item_photos[0], item_photos[1]
 */
router.post(
    "/",
    auth(["customer"]),
    uploadPickupPhotos.any(), 
    createPickup
);

/**
 * @route   GET /api/v1/pickups/customer
 * @desc    Get all pickup requests for the logged-in customer
 */
router.get("/customer", auth(["customer"]), listCustomerPickups);

/**
 * @route   GET /api/v1/pickups/:id/receipt
 * @desc    Get the final financial receipt/invoice after completion
 */
router.get("/:id/receipt", auth(["customer", "admin"]), getReceipt);


/* ============================================================
   STAFF ROUTES (Agent & Rider)
============================================================ */

/**
 * @route   GET /api/v1/pickups/agent/list
 * @desc    Get pickups assigned to an agent's area
 */
router.get("/agent/list", auth(["agent"]), agentPickupList);

/**
 * @route   GET /api/v1/pickups/rider/list
 * @desc    Get pickups specifically assigned to a rider
 */
router.get("/rider/list", auth(["rider"]), riderPickupList);

/**
 * @route   PUT /api/v1/pickups/:id/status
 * @desc    Update simple status (assigned, arrived, etc.)
 */
router.put("/:id/status", auth(["rider", "agent", "admin"]), updatePickupStatus);

/**
 * @route   POST /api/v1/pickups/:id/complete
 * @desc    Finalize pickup with actual weights, rates, and proof image.
 * Uses .single('proof_image') for the rider's final confirmation photo.
 */
router.post(
    "/:id/complete",
    auth(["rider", "admin"]),
    uploadPickupPhotos.single('proof_image'),
    completePickup
);


/* ============================================================
   GENERAL UTILITY
============================================================ */

/**
 * @route   GET /api/v1/pickups/:id
 * @desc    Get full details of a specific pickup
 */
router.get("/:id", auth(["customer", "agent", "rider", "admin"]), getPickupDetails);

export default router;