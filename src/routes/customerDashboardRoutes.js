import express from "express";
import { auth } from "../middlewares/auth.js";
import { getCustomerDashboard } from "../controllers/customerDashboardController.js";

const router = express.Router();

router.get("/dashboard", auth(["customer"]), getCustomerDashboard);

export default router;
