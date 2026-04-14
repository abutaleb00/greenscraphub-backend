import express from 'express';
import { body } from 'express-validator';
import {
  registerRequest,
  verifyAndRegister,
  onboardCustomer,
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
 * CUSTOM VALIDATOR: BD Phone Number
 * Checks if it's a valid 11-digit BD number starting with 01
 */
const phoneValidator = body('phone')
  .trim()
  .notEmpty().withMessage('Phone number is required')
  .matches(/^(01)[3-9][0-9]{8}$/).withMessage('Invalid Bangladeshi phone number format');

/**
 * 1. CUSTOMER REGISTRATION - STEP 1 (Request OTP)
 */
router.post(
  '/register',
  [
    body('full_name').trim().notEmpty().withMessage('Full name is required'),
    phoneValidator, // Used the custom validator
    body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
    body('email').optional({ checkFalsy: true }).isEmail().withMessage('Invalid email format'),
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
    phoneValidator,
    body('otp').isLength({ min: 6, max: 6 }).withMessage('OTP must be 6 digits'),
  ],
  verifyAndRegister
);

/**
 * 3. ADMIN/AGENT -> DIRECT CUSTOMER ONBOARDING
 */
router.post(
  '/onboard/customer',
  auth(['admin', 'agent']),
  [
    body('full_name').trim().notEmpty().withMessage('Full name is required'),
    phoneValidator,
    body('password').isLength({ min: 6 }).withMessage('Initial password must be at least 6 characters'),
    body('address_line').trim().notEmpty().withMessage('Street address is required'),
    body('division_id').notEmpty().withMessage('Division selection is required'),
    body('district_id').notEmpty().withMessage('District selection is required'),
    body('upazila_id').notEmpty().withMessage('Upazila selection is required'),
    body('latitude').optional({ checkFalsy: true }).isNumeric().withMessage('Latitude must be numeric'),
    body('longitude').optional({ checkFalsy: true }).isNumeric().withMessage('Longitude must be numeric'),
    body('email').optional({ checkFalsy: true }).isEmail().withMessage('Invalid email format'),
    body('referral_code').optional().trim(),
  ],
  onboardCustomer
);

/**
 * 4. FORGOT PASSWORD - STEP 1 (Request Reset OTP)
 */
router.post(
  '/forgot-password',
  [phoneValidator], // Validates phone before triggering paid SMS
  forgotPasswordRequest
);

/**
 * 5. FORGOT PASSWORD - STEP 2 (Verify & Reset)
 */
router.post(
  '/reset-password',
  [
    phoneValidator,
    body('otp').isLength({ min: 6, max: 6 }).withMessage('OTP must be 6 digits'),
    body('new_password').isLength({ min: 6 }).withMessage('New password must be at least 6 characters'),
  ],
  resetPassword
);

/**
 * 6. LOGIN
 */
router.post(
  '/login',
  [
    phoneValidator,
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
 */
router.patch(
  '/profile',
  auth(),
  [
    body('full_name').optional().trim().notEmpty().withMessage('Full name cannot be empty'),
    body('email').optional({ checkFalsy: true }).isEmail().withMessage('Invalid email format'),
    body('default_address_id').optional().isNumeric(),
    body('vehicle_type').optional().notEmpty(),
    // Added specific validation for rider online status
    body('is_online').optional().isNumeric().isIn([0, 1]).withMessage('Status must be 0 or 1'),
  ],
  updateProfile
);

/**
 * 9. CHANGE PASSWORD
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