import express from "express";
import { auth } from "../middlewares/auth.js";
import { getWalletSummary } from "../controllers/walletController.js";

const router = express.Router();

// Customer only access for financial data
router.get("/summary", auth(["customer"]), getWalletSummary);

export default router;