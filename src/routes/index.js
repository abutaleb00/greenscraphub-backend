import express from 'express';

// --- Import Module Routes ---
import authRoutes from './authRoutes.js';
import scrapCatalogRoutes from './scrapCatalogRoutes.js';
import adminUserRoutes from './adminUserRoutes.js';
import pickupRoutes from './pickupRoutes.js';
import walletRoutes from './walletRoutes.js';
import payoutRoutes from './payoutRoutes.js';
import pointRoutes from './pointRoutes.js';
import addressRoutes from './addressRoutes.js';
import geographyRoutes from './geographyRoutes.js';

// --- Import Dashboard Routes ---
import adminDashboardRoutes from "./adminDashboardRoutes.js";
import riderRoutes from "./riderRoutes.js";
import customerDashboardRoutes from "./customerDashboardRoutes.js";
import systemRoutes from "./systemRoutes.js";
import agentRoutes from './agentRoutes.js';
import receiptRoutes from './receiptRoutes.js';
const router = express.Router();

/**
 * @section Health Check
 * Used by Load Balancers and Uptime Monitors
 */
router.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'GreenScrapHub API is operational',
    version: '2.0.0',
    timestamp: new Date()
  });
});

/**
 * @section Core Auth & Profile
 * Path: /api/v1/auth
 */
router.use('/auth', authRoutes);

/**
 * @section Scrap Catalog (Categories & Price List)
 * Path: /api/v1/scrap
 */
router.use('/scrap', scrapCatalogRoutes);

/**
 * @section Financial Circle (Wallets, Payouts, Rewards)
 * Paths: /api/v1/wallet, /api/v1/payouts, /api/v1/points
 */
router.use('/wallet', walletRoutes);
router.use('/payouts', payoutRoutes);
router.use('/points', pointRoutes);

/**
 * @section Logistics & Geography
 * Paths: /api/v1/pickups, /api/v1/addresses, /api/v1/geography
 */
router.use('/pickups', pickupRoutes);
router.use('/addresses', addressRoutes); // User's personal address book
router.use('/geography', geographyRoutes); // Division/District/Upazila lookup

/**
 * @section Dashboards & Management
 * Role-specific data aggregation
 */
router.use('/dashboard/admin', adminDashboardRoutes);
router.use('/riders', riderRoutes);
router.use('/customers', customerDashboardRoutes);
router.use('/receipts', receiptRoutes);

/**
 * @section Agents Management
 * Path: /api/v1/agents
 */
router.use('/agents', agentRoutes);
/**
 * @section Admin User Management
 * Path: /api/v1/management
 */
router.use('/management', adminUserRoutes); // Onboarding Agents/Riders
router.use('/system', systemRoutes);

export default router;