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
   listAllPickupsAdmin,
   assignRiderController // <--- Import the new controller
} from "../controllers/pickupController.js";

const router = express.Router();

/* ============================================================
   ADMIN ROUTES (Global Management)
============================================================ */
router.get("/admin/all", auth(["admin"]), listAllPickupsAdmin);

/* ============================================================
   MANAGEMENT ROUTES (Admin & Agent)
============================================================ */
/**
 * @route   PUT /api/v1/pickups/:id/assign-rider
 * @desc    Assign a rider (Admin: any rider, Agent: only their staff)
 */
router.put(
   "/:id/assign-rider",
   auth(["admin", "agent"]),
   assignRiderController
);

/* ============================================================
   CUSTOMER ROUTES
============================================================ */
router.post("/", auth(["customer"]), uploadPickupPhotos.any(), createPickup);
router.get("/customer", auth(["customer"]), listCustomerPickups);
router.get("/:id/receipt", auth(["customer", "admin"]), getReceipt);

/* ============================================================
   STAFF ROUTES (Agent & Rider)
============================================================ */
router.get("/agent/list", auth(["agent"]), agentPickupList);
router.get("/rider/list", auth(["rider"]), riderPickupList);
router.put("/:id/status", auth(["rider", "agent", "admin"]), updatePickupStatus);

router.post(
   "/:id/complete",
   auth(["rider", "admin"]),
   uploadPickupPhotos.single('proof_image'),
   completePickup
);

/* ============================================================
   GENERAL UTILITY
============================================================ */
router.get("/:id", auth(["customer", "agent", "rider", "admin"]), getPickupDetails);

export default router;