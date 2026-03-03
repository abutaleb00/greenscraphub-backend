// src/routes/geographyRoutes.js
import express from 'express';
import { getDivisions, getDistricts, getUpazilas } from '../controllers/geographyController.js';

const router = express.Router();

// GET /api/v1/geography/divisions
router.get('/divisions', getDivisions);

// GET /api/v1/geography/divisions/:divisionId/districts
router.get('/divisions/:divisionId/districts', getDistricts);

// GET /api/v1/geography/districts/:districtId/upazilas
router.get('/districts/:districtId/upazilas', getUpazilas);

export default router;