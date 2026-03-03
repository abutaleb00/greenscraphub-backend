import express from 'express';
import { body } from 'express-validator';
import {
    getAddresses,
    addAddress,
    setDefaultAddress,
    deleteAddress
} from '../controllers/addressController.js';
import { auth } from '../middlewares/auth.js';

const router = express.Router();

// Apply auth to all routes. 
// Note: We use auth() without specific roles to allow Customers, Riders, and Agents to manage addresses.
router.use(auth());

/**
 * @route   GET /api/v1/addresses
 * @desc    Get all addresses with joined Division/District/Upazila names
 */
router.get('/', getAddresses);

/**
 * @route   POST /api/v1/addresses
 * @desc    Add a new address linked to a specific Upazila for Agent routing
 */
router.post('/', [
    body('label').optional().isString(),
    body('address_line').notEmpty().withMessage('Specific house/street info is required'),

    // Geographical IDs (Required for the new routing logic)
    body('division_id').isInt().withMessage('Please select a valid Division'),
    body('district_id').isInt().withMessage('Please select a valid District'),
    body('upazila_id').isInt().withMessage('Please select a valid Upazila/Area'),

    // Coordinates (Required for Rider navigation)
    body('latitude').isFloat().withMessage('Valid latitude required'),
    body('longitude').isFloat().withMessage('Valid longitude required'),

    body('is_default').optional().isBoolean(),
], addAddress);

/**
 * @route   PATCH /api/v1/addresses/:id/default
 * @desc    Set an address as primary and sync with User Profile
 */
router.patch('/:id/default', setDefaultAddress);

/**
 * @route   DELETE /api/v1/addresses/:id
 * @desc    Remove an address (with protection against deleting the active default)
 */
router.delete('/:id', deleteAddress);

export default router;