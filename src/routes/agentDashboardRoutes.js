// src/routes/agentDashboardRoutes.js
import express from "express";
import { auth } from "../middlewares/auth.js";
import { getAgentDashboard } from "../controllers/agentDashboardController.js";

const router = express.Router();

// Agent dashboard – Agent (or Admin with ?agent_id=) only
router.get("/dashboard", auth(["agent", "admin"]), getAgentDashboard);

export default router;
