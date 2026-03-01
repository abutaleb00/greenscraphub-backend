import express from "express";
import { auth } from "../middlewares/auth.js";
import { getAdminDashboard } from "../controllers/adminDashboardController.js";

const router = express.Router();

router.get("/dashboard", auth(["admin"]), getAdminDashboard);

export default router;
