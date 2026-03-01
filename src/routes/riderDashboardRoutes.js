import express from "express";
import { auth } from "../middlewares/auth.js";
import { getRiderDashboard } from "../controllers/riderDashboardController.js";

const router = express.Router();

router.get("/dashboard", auth(["rider"]), getRiderDashboard);

export default router;
