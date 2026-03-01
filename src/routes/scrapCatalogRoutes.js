// src/routes/scrapCatalogRoutes.js
import express from "express";
import { body } from "express-validator";
import { auth } from "../middlewares/auth.js";
import { upload } from "../config/multer.js";
import { uploadCategoryIcon } from "../middlewares/upload.js";

import {
    listPublicCategories,
    listPublicItemsByCategory,
    getAdminCategoryById,
    getPublicItemDetail,
    createCategoryAdmin,
    listAdminCategories,
    updateCategoryAdmin,
    createItemAdmin,
    listAdminItems,
    updateItemAdmin,
} from "../controllers/scrapCatalogController.js";

const router = express.Router();

/* ===========================
   PUBLIC CATALOG ROUTES
=========================== */

// GET → /api/v1/scrap/categories
router.get("/categories", listPublicCategories);

// GET → items under a category
router.get("/categories/:categoryId/items", listPublicItemsByCategory);

// GET → item details
router.get("/items/:itemId", getPublicItemDetail);


/* ===========================
   ADMIN CATALOG ROUTES
=========================== */

/* -----------------------------------------
   CREATE CATEGORY (with file upload)
----------------------------------------- */
router.post(
    "/admin/categories",
    auth("admin"),
    uploadCategoryIcon.single("icon"),   // ⬅ FILE UPLOAD HERE
    [
        body("name").notEmpty().withMessage("Name is required"),
        body("display_order").optional().isInt({ min: 0 })
    ],
    createCategoryAdmin
);

/* -----------------------------------------
   LIST CATEGORIES (Admin)
----------------------------------------- */
router.get("/admin/categories", auth("admin"), listAdminCategories);

// Get Single Category (Admin)
router.get(
    "/admin/categories/:categoryId",
    getAdminCategoryById
);

/* -----------------------------------------
   UPDATE CATEGORY (with optional new icon)
----------------------------------------- */
router.put(
    "/admin/categories/:categoryId",
    auth("admin"),
    uploadCategoryIcon.single("icon"),   // optional file upload
    [
        body("name").optional().notEmpty(),
        body("display_order").optional().isInt({ min: 0 })
    ],
    updateCategoryAdmin
);


/* -----------------------------------------
   CREATE ITEM
----------------------------------------- */
router.post(
    "/admin/items",
    auth("admin"),
    upload.single("image"),

    [
        body("category_id")
            .notEmpty().withMessage("category_id is required")
            .isInt({ gt: 0 }).withMessage("category_id must be a number"),

        body("name")
            .notEmpty().withMessage("Name is required"),

        // Accept unit optional
        body("unit")
            .optional()
            .isIn(["kg", "piece"]).withMessage("unit must be kg or piece"),

        // FORM-DATA numeric validation FIX:
        body("min_price_per_unit").notEmpty().withMessage("min_price_per_unit required"),
        body("max_price_per_unit").notEmpty().withMessage("max_price_per_unit required"),
    ],

    createItemAdmin
);


/* -----------------------------------------
   LIST ITEMS
----------------------------------------- */
router.get("/admin/items", auth("admin"), listAdminItems);


/* -----------------------------------------
   UPDATE ITEM
----------------------------------------- */
router.put(
    "/admin/items/:itemId",
    auth("admin"),
    [
        body("unit").optional().isIn(["kg", "piece"]),
        body("min_price_per_unit").optional().isFloat({ gt: 0 }),
        body("max_price_per_unit").optional().isFloat({ gt: 0 }),
    ],
    updateItemAdmin
);

export default router;