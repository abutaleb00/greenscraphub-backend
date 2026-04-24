import express from 'express';
import { body } from 'express-validator';
import {
    getAddresses,
    addAddress,
    updateAddress,
    setDefaultAddress,
    deleteAddress,
    getAddressesByUserId,
    lookupGeoByCoords // Added for Uber-style lookup
} from '../controllers/addressController.js';
import { auth } from '../middlewares/auth.js';

const router = express.Router();

/**
 * AUTHENTICATION
 * Apply to all routes. Allows Customers, Riders, and Agents 
 * to manage their specific location data.
 */
router.use(auth());

/**
 * @route   GET /api/v1/addresses
 * @desc    Get all addresses with joined Division/District/Upazila names
 * @access  Private
 */
router.get('/', getAddresses);

/**
 * @route   POST /api/v1/addresses/lookup-geo
 * @desc    Uber-style: Get Geo IDs (Division/District/Upazila) from Lat/Lng
 * @access  Private
 */
router.post('/lookup-geo', [
    body('latitude').isFloat().withMessage('Valid latitude required'),
    body('longitude').isFloat().withMessage('Valid longitude required'),
], lookupGeoByCoords);

/**
 * @route   POST /api/v1/addresses
 * @desc    Add a new address linked to a specific Upazila for Agent routing
 * @access  Private
 */
router.post('/', [
    body('label').optional().isString().withMessage('Label must be a string (e.g., Home, Office)'),
    body('address_line').notEmpty().withMessage('Specific street info is required'),

    // Detailed fields based on your updated table schema
    body('house_no').optional().isString(),
    body('road_no').optional().isString(),
    body('landmark').optional().isString(),

    // Geographical IDs (Determined automatically by the map in mobile app)
    body('division_id').isInt().withMessage('Please select a valid Division'),
    body('district_id').isInt().withMessage('Please select a valid District'),
    body('upazila_id').isInt().withMessage('Please select a valid Upazila/Area'),

    // Coordinates (Required for Rider navigation)
    body('latitude').isFloat().withMessage('Valid latitude coordinate required'),
    body('longitude').isFloat().withMessage('Valid longitude coordinate required'),

    body('is_default').optional().isBoolean(),
], addAddress);

/**
 * @route   PUT /api/v1/addresses/:id
 * @desc    Update existing address details
 * @access  Private
 */
router.put('/:id', [
    body('label').optional().isString(),
    body('address_line').optional().notEmpty(),
    body('house_no').optional().isString(),
    body('road_no').optional().isString(),
    body('landmark').optional().isString(),
    body('division_id').optional().isInt(),
    body('district_id').optional().isInt(),
    body('upazila_id').optional().isInt(),
    body('latitude').optional().isFloat(),
    body('longitude').optional().isFloat(),
    body('is_default').optional().isBoolean(),
], updateAddress);

/**
 * @route   PATCH /api/v1/addresses/:id/default
 * @desc    Set an address as primary and sync with Role-based Profile
 * @access  Private
 */
router.patch('/:id/default', setDefaultAddress);

/**
 * @route   DELETE /api/v1/addresses/:id
 * @desc    Remove an address
 * @access  Private
 */
router.delete('/:id', deleteAddress);

/**
 * @route   GET /api/v1/addresses/user/:userId
 * @desc    Get all addresses for a specific user ID
 * @access  Private (Restricted to Admin/Agent)
 */
router.get('/user/:userId', auth(['admin', 'agent']), getAddressesByUserId);

export default router;