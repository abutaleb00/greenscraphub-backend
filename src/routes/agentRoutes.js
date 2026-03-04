import express from "express";
import { auth } from "../middlewares/auth.js";
import {
    getHubRiders,
    getHubCollectionLogs,
    getHubEarnings,
    getRiderAudit,
    getPendingSettlements, // Updated
    settleRiderCash,
    getDispatchConsole ,
    getAgentMissionDetail
} from "../controllers/logistics/agentManagementController.js";

import { getAgentDashboard } from "../controllers/agentDashboardController.js";

const router = express.Router();

/* ============================================================
    HUB ANALYTICS & DASHBOARD
============================================================ */

/** @route GET /api/v1/agents/dashboard */
router.get("/dashboard", auth(["agent", "admin"]), getAgentDashboard);

/** @route GET /api/v1/agents/earnings */
router.get("/earnings", auth(["agent"]), getHubEarnings);


/** @route GET /api/v1/agents/pickups */
router.get("/pickups", auth(["agent"]), getHubCollectionLogs);
router.get("/pickups/:id", auth(["agent"]), getAgentMissionDetail);


/* ============================================================
    RIDER FLEET OVERSIGHT (Logistics Only)
============================================================ */

/** * @route   GET /api/v1/agents/riders
 * @desc    Fetch riders assigned to this hub with their live load/cash stats
 */
router.get("/riders", auth(["agent"]), getHubRiders);
router.get("/pending-settlements", auth(["agent"]), getPendingSettlements); // GET list
router.post("/settle-cash", auth(["agent"]), settleRiderCash);
router.get("/dispatch-console", auth(["agent"]), getDispatchConsole);

/** * @route   GET /api/v1/agents/riders/:rider_id/audit
 * @desc    Performance metrics (Success rate, ratings, settlement trail)
 */
router.get("/riders/:rider_id/audit", auth(["agent"]), getRiderAudit);

export default router;