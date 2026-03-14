import express from "express";
import { auth } from "../middlewares/auth.js";
import {
    getRiderDashboard,
    getMyTasks,
    getTaskDetail,
    updateTaskStatus,
    getRiderEarnings,      
    getRiderCollectionLogs,
    finalizePickup,
    getRiderHistory,
    getHistoryDetail,
    getEarningsOverview,
    updateStatus,
    updateLocation
} from "../controllers/logistics/riderTaskController.js";

const router = express.Router();

/* ============================================================
    INSIGHTS & ANALYTICS
============================================================ */

/** * @route   GET /api/v1/riders/dashboard 
 * @desc    Rider specific stats (Today's earnings, total pickups)
 */
router.get("/dashboard", auth(["rider"]), getRiderDashboard);

/** * @route   GET /api/v1/riders/earnings 
 * @desc    Personal wallet and commission breakdown
 */
router.patch("/status", auth(["rider"]), updateStatus);
router.patch("/location", auth(["rider"]), updateLocation);
router.get("/earnings", auth(["rider"]), getRiderEarnings);


/* ============================================================
    ACTIVE FIELD OPERATIONS (The Task Board)
============================================================ */

/** * @route   GET /api/v1/riders/tasks 
 * @desc    Fetch active assignments (Pending, On the Way, Arrived)
 */
router.post("/tasks/:id/finalize", auth(["rider"]), finalizePickup);
router.get("/tasks/:id", auth(["rider", "agent"]), getTaskDetail);
router.get("/tasks", auth(["rider"]), getMyTasks);

/** * @route   PATCH /api/v1/riders/tasks/:id/status 
 * @desc    Update progress (Pending -> On the Way -> Arrived)
 */
router.patch("/tasks/:id/status", auth(["rider"]), updateTaskStatus);


/* ============================================================
    HISTORICAL ARCHIVE
============================================================ */

/** * @route   GET /api/v1/riders/pickups 
 * @desc    Rider's personal history of completed/cancelled jobs
 */
router.get("/history", auth(["rider"]), getRiderHistory);
router.get("/history/:id", auth(["rider"]), getHistoryDetail);
router.get("/earnings-overview", auth(["rider"]), getEarningsOverview);
router.get("/pickups", auth(["rider"]), getRiderCollectionLogs);

export default router;