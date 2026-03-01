import express from 'express';
import { body } from 'express-validator';
import {
  registerRequest,
  verifyAndRegister,
  login,
  getMe,
  forgotPasswordRequest,
  resetPassword
} from '../controllers/authController.js';
import { auth } from '../middlewares/auth.js';

const router = express.Router();

/**
 * 1. CUSTOMER REGISTRATION - STEP 1 (Request OTP)
 * Captures user data and referral code, then sends OTP.
 */
router.post(
  '/register',
  [
    body('full_name').trim().notEmpty().withMessage('Full name is required'),
    body('phone').trim().notEmpty().withMessage('Phone is required'),
    body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
    body('email').optional().isEmail().withMessage('Invalid email format'),
    body('referral_code').optional().trim(),
  ],
  registerRequest
);

/**
 * 2. CUSTOMER REGISTRATION - STEP 2 (Verify & Create)
 */
router.post(
  '/verify-otp',
  [
    body('phone').notEmpty().withMessage('Phone is required'),
    body('otp').isLength({ min: 6, max: 6 }).withMessage('OTP must be 6 digits'),
  ],
  verifyAndRegister
);

/**
 * 3. FORGOT PASSWORD - STEP 1 (Request Reset OTP)
 * Sends an OTP to the email linked to the provided phone number.
 */
router.post(
  '/forgot-password',
  [
    body('phone').notEmpty().withMessage('Registered phone number is required'),
  ],
  forgotPasswordRequest
);

/**
 * 4. FORGOT PASSWORD - STEP 2 (Verify & Reset)
 * Validates OTP and updates the password in the database.
 */
router.post(
  '/reset-password',
  [
    body('phone').notEmpty().withMessage('Phone is required'),
    body('otp').isLength({ min: 6, max: 6 }).withMessage('OTP must be 6 digits'),
    body('new_password').isLength({ min: 6 }).withMessage('New password must be at least 6 characters'),
  ],
  resetPassword
);

/**
 * 5. LOGIN - PHONE & PASSWORD
 */
router.post(
  '/login',
  [
    body('phone').notEmpty().withMessage('Phone is required'),
    body('password').notEmpty().withMessage('Password is required'),
  ],
  login
);

/**
 * 6. GET AUTHENTICATED USER
 */
router.get('/me', auth(), getMe);

export default router;