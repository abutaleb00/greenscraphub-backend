import express from 'express';

import authRoutes from './authRoutes.js';
import scrapCatalogRoutes from './scrapCatalogRoutes.js';
import adminUserRoutes from './adminUserRoutes.js';
import pickupRoutes from './pickupRoutes.js';
import walletRoutes from './walletRoutes.js'; // 🚀 NEW: Wallet Module
import agentDashboardRoutes from "./agentDashboardRoutes.js";
import adminDashboardRoutes from "./adminDashboardRoutes.js";
import riderDashboardRoutes from "./riderDashboardRoutes.js";
import customerDashboardRoutes from "./customerDashboardRoutes.js";
import payoutRoutes from './payoutRoutes.js';
import pointRoutes from './pointRoutes.js';
const router = express.Router();

// --- Health Check ---
router.get('/health', (req, res) => {
  res.json({ success: true, message: 'API is working', timestamp: new Date() });
});

// --- Core Modules ---
router.use('/auth', authRoutes);           // login, register, me
router.use('/scrap', scrapCatalogRoutes);   // Categories + Price Items

// --- Financial Modules ---
router.use('/wallet', walletRoutes);       // 💰 NEW: Earnings & Transactions
router.use('/payouts', payoutRoutes);
router.use('/point', pointRoutes);
// --- Logistics Modules ---
router.use('/pickups', pickupRoutes);      // 📦 Create, List, Status, Complete

// --- Dashboard & Management ---
router.use('/admin', adminUserRoutes);
router.use("/admin", adminDashboardRoutes);
router.use("/agent", agentDashboardRoutes);
router.use("/rider", riderDashboardRoutes);
router.use("/customer", customerDashboardRoutes);

export default router;