// src/controllers/geographyController.js
import db from '../config/db.js';

/**
 * 1. Get All Divisions
 * Public: Used at the start of address selection
 */
export const getDivisions = async (req, res, next) => {
    try {
        const [rows] = await db.query(
            "SELECT id, name_en, name_bn FROM divisions WHERE status = 1 ORDER BY name_en ASC"
        );
        res.json({ success: true, data: rows });
    } catch (err) {
        next(err);
    }
};

/**
 * 2. Get Districts by Division
 * Filtered: When user selects a Division (e.g., Khulna)
 */
export const getDistricts = async (req, res, next) => {
    try {
        const { divisionId } = req.params;
        const [rows] = await db.query(
            "SELECT id, name_en, name_bn FROM districts WHERE division_id = ? AND is_active = 1 ORDER BY name_en ASC",
            [divisionId]
        );
        res.json({ success: true, data: rows });
    } catch (err) {
        next(err);
    }
};

/**
 * 3. Get Upazilas by District
 * Filtered: When user selects a District (e.g., Khulna District)
 */
export const getUpazilas = async (req, res, next) => {
    try {
        const { districtId } = req.params;
        const [rows] = await db.query(
            "SELECT id, name_en, name_bn FROM upazilas WHERE district_id = ? AND is_active = 1 ORDER BY name_en ASC",
            [districtId]
        );
        res.json({ success: true, data: rows });
    } catch (err) {
        next(err);
    }
};