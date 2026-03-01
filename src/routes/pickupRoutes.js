import express from "express";
import multer from "multer";
import path from "path";
import fs from "fs";
import { auth } from "../middlewares/auth.js";
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
   MULTER CONFIGURATION (Disk Storage)
   Ensures files are saved physically so we can generate URLs
============================================================ */
const storage = multer.diskStorage({
   destination: (req, file, cb) => {
      const uploadPath = 'public/uploads/pickups/';
      // Auto-create directory if it doesn't exist
      if (!fs.existsSync(uploadPath)) {
         fs.mkdirSync(uploadPath, { recursive: true });
      }
      cb(null, uploadPath);
   },
   filename: (req, file, cb) => {
      const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
      cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
   }
});

const upload = multer({
   storage,
   limits: { fileSize: 10 * 1024 * 1024 }, // Increased to 10MB for high-res proof photos
   fileFilter: (req, file, cb) => {
      const filetypes = /jpeg|jpg|png|webp/;
      const mimetype = filetypes.test(file.mimetype);
      const extname = filetypes.test(path.extname(file.originalname).toLowerCase());

      if (mimetype && extname) {
         return cb(null, true);
      }
      cb(new Error("Error: File upload only supports images (jpeg, jpg, png, webp)"));
   }
});

/* ============================================================
   CUSTOMER ROUTES
============================================================ */

/**
 * @route   POST /api/v1/pickups
 * @desc    Create a new pickup request with multiple items and photos
 */
router.post(
   "/",
   auth(["customer"]),
   upload.any(), // Required for dynamic fields like item_photos[0], item_photos[1]
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
 * This triggers the Universal Payout (Wallet Update) logic.
 */
router.post(
   "/:id/complete",
   auth(["rider", "admin"]),
   upload.single('proof_image'), // Rider uploads 1 final proof image
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