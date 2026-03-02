import express from 'express';
import { body } from 'express-validator';
import { getAddresses, addAddress, setDefaultAddress, deleteAddress } from '../controllers/addressController.js';
import { auth } from '../middlewares/auth.js';

const router = express.Router();

router.use(auth()); // All address routes require login

router.get('/', getAddresses);

router.post('/', [
    body('address_line').notEmpty().withMessage('Address is required'),
    body('city').notEmpty().withMessage('City is required'),
], addAddress);

router.patch('/:id/default', setDefaultAddress);
router.delete('/:id', deleteAddress);

export default router;