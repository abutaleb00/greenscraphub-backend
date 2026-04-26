import express from 'express';
import { auth } from '../middlewares/auth.js';
import { getSettings, updateSettings } from '../controllers/adminSettingController.js';

const router = express.Router();

// Settings routes
router.get('/settings', auth(['admin']), getSettings);
router.patch('/settings', auth(['admin']), updateSettings);

export default router;