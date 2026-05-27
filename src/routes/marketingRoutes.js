import express from "express";
import { auth } from "../middlewares/auth.js";
import {
    createMarketingCampaign,
    getCampaignsOverview,
    getCampaignHistoryLog,
    cancelScheduledCampaign
} from "../controllers/marketingController.js";

const router = express.Router();

/* ============================================================
    ADMIN CAMPAIGN MANAGEMENT & SCHEDULER
============================================================ */

/** * @route   POST /api/v1/management/marketing/campaigns
 * @desc    Create and schedule global or selective marketing campaigns (SMS/Email)
 * @access  Admin
 */
router.post("/campaigns", auth(["admin"]), createMarketingCampaign);

/** * @route   GET /api/v1/management/marketing/campaigns/list
 * @desc    Fetch comprehensive overview log of all dispatched/pending campaigns
 * @access  Admin
 */
router.get("/campaigns/list", auth(["admin"]), getCampaignsOverview);

/** * @route   GET /api/v1/management/marketing/campaigns/:id/history
 * @desc    Fetch line-by-line recipient delivery queue report for a specific campaign
 * @access  Admin
 */
router.get("/campaigns/:id/history", auth(["admin"]), getCampaignHistoryLog);
router.patch("/campaigns/:id/cancel", auth(["admin"]), cancelScheduledCampaign);
export default router;