import express from "express";
import { auth } from "../middlewares/auth.js";
import {
    getHubRiders,
    getHubCollectionLogs,
    getHubEarnings,
    getRiderAudit,
    getPendingSettlements, // Updated
    settleRiderCash,
    getDispatchConsole,
    getAgentMissionDetail,
    getSettlementLogs
} from "../controllers/logistics/agentManagementController.js";
import { updateRiderCommission } from '../controllers/commissionController.js';
import { getAgentDashboard } from "../controllers/agentDashboardController.js";
import { releaseInventory, getHubInventory, getStockHistory } from "../controllers/logistics/inventoryController.js";

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
router.get("/settlement-logs", auth(["agent"]), getSettlementLogs);
router.get("/pending-settlements", auth(["agent"]), getPendingSettlements); // GET list
router.post("/settle-cash", auth(["agent"]), settleRiderCash);
router.get("/dispatch-console", auth(["agent"]), getDispatchConsole);

/** * @route   GET /api/v1/agents/riders/:rider_id/audit
 * @desc    Performance metrics (Success rate, ratings, settlement trail)
 */
router.get("/riders/:rider_id/audit", auth(["agent"]), getRiderAudit);

router.get("/inventory", auth(["agent"]), getHubInventory);
router.post("/inventory/release", auth(["agent"]), releaseInventory);
router.get("/inventory/history", auth(["agent"]), getStockHistory);

router.patch(
    '/riders/:id/commission',
    auth(["agent", "admin"]),
    updateRiderCommission
);
export default router;