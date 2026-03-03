// src/routes/adminDashboardRoutes.js
import express from "express";
import { auth } from "../middlewares/auth.js";
import { getAdminDashboard } from "../controllers/adminDashboardController.js";

const router = express.Router();

/**
 * @route   GET /api/v1/dashboard/admin/summary
 * @desc    Get complete live system summary (KPIs, Users, Recent Feeds, Charts)
 * @access  Private (Admin Only)
 */
router.get("/summary", auth(["admin"]), getAdminDashboard);

/**
 * @route   GET /api/v1/dashboard/admin/stats-only
 * @desc    Lightweight route for real-time counters (Riders Online, Pending Pickups)
 * Used for "Pulse" monitoring without heavy database joins.
 * @access  Private (Admin Only)
 */
// router.get("/stats-only", auth(["admin"]), getAdminStatsOnly); 

export default router;