import express from "express";
import { auth } from "../middlewares/auth.js";
import { getWalletSummary, getWalletTransactions } from "../controllers/walletController.js";

const router = express.Router();

// Customer only access for financial data
router.get("/summary", auth(["customer"]), getWalletSummary);
router.get('/transactions', auth(['customer']), getWalletTransactions);

export default router;