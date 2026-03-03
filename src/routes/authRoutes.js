import express from 'express';
import { body } from 'express-validator';
import {
  registerRequest,
  verifyAndRegister,
  onboardCustomer, // New Controller for Admin onboarding
  login,
  getMe,
  forgotPasswordRequest,
  resetPassword,
  updateProfile,
  changePassword
} from '../controllers/authController.js';
import { auth } from '../middlewares/auth.js';

const router = express.Router();

/**
 * 1. CUSTOMER REGISTRATION - STEP 1 (Request OTP)
 * For public/guest self-registration.
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
 * 3. ADMIN/AGENT -> DIRECT CUSTOMER ONBOARDING
 * Bypasses OTP flow. Requires Admin/Agent authorization.
 */
router.post(
  '/onboard/customer',
  auth(['admin', 'agent']), // Only staff can use this
  [
    body('full_name').trim().notEmpty().withMessage('Full name is required'),
    body('phone').trim().notEmpty().withMessage('Phone is required'),
    body('password').isLength({ min: 6 }).withMessage('Initial password must be at least 6 characters'),
    body('email').optional().isEmail().withMessage('Invalid email format'),
    body('referral_code').optional().trim(),
  ],
  onboardCustomer
);

/**
 * 4. FORGOT PASSWORD - STEP 1 (Request Reset OTP)
 */
router.post(
  '/forgot-password',
  [
    body('phone').notEmpty().withMessage('Registered phone number is required'),
  ],
  forgotPasswordRequest
);

/**
 * 5. FORGOT PASSWORD - STEP 2 (Verify & Reset)
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
 * 6. LOGIN - PHONE & PASSWORD
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
 * 7. GET AUTHENTICATED USER
 */
router.get('/me', auth(), getMe);

/**
 * 8. UPDATE PROFILE (Role-Aware)
 * Handles updates for users, customers, and riders profiles.
 */
router.patch(
  '/profile',
  auth(),
  [
    body('full_name').optional().trim().notEmpty().withMessage('Full name cannot be empty'),
    body('email').optional().isEmail().withMessage('Invalid email format'),
    body('default_address_id').optional().isNumeric(),
    body('vehicle_type').optional().notEmpty(),
    body('is_online').optional().isBoolean(),
  ],
  updateProfile
);

/**
 * 9. CHANGE PASSWORD (Secure)
 * Dedicated route for logged-in users to update their password.
 */
router.post(
  '/change-password',
  auth(),
  [
    body('currentPassword').notEmpty().withMessage('Current password is required'),
    body('newPassword').isLength({ min: 6 }).withMessage('New password must be at least 6 characters'),
  ],
  changePassword
);

export default router;