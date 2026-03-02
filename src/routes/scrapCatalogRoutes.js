import express from "express";
import { body } from "express-validator";
import { auth } from "../middlewares/auth.js";
import { uploadCategoryIcon, uploadScrapItemImage } from "../middlewares/upload.js";

import {
    // Public Exports
    listPublicCategories,
    listPublicItemsByCategory,
    getPublicItemDetail,

    // Admin Category Exports
    listAdminCategories,
    getAdminCategoryById,
    createCategoryAdmin,
    updateCategoryAdmin,
    deleteCategoryAdmin,

    // Admin Item Exports
    listAdminItems,
    createItemAdmin,
    updateItemAdmin,
    toggleItemStatusAdmin,
    deleteItemAdmin
} from "../controllers/scrapCatalogController.js";

const router = express.Router();

/* ====================================================
   PUBLIC CATALOG ROUTES
   (Accessible by mobile app and guest users)
==================================================== */

// GET → /api/v1/scrap/categories
router.get("/categories", listPublicCategories);

// GET → items under a category
router.get("/categories/:categoryId/items", listPublicItemsByCategory);

// GET → item details
router.get("/items/:itemId", getPublicItemDetail);


/* ====================================================
   ADMIN CATALOG ROUTES
   (Strictly Protected by auth("admin"))
==================================================== */

/* --- ADMIN: CATEGORIES --- */

// LIST: GET → /api/v1/scrap/admin/categories
router.get("/admin/categories", auth("admin"), listAdminCategories);

// DETAIL: GET → /api/v1/scrap/admin/categories/:categoryId
router.get("/admin/categories/:categoryId", auth("admin"), getAdminCategoryById);

// CREATE: POST → /api/v1/scrap/admin/categories
router.post(
    "/admin/categories",
    auth("admin"),
    uploadCategoryIcon.single("icon"),
    [
        body("name").notEmpty().withMessage("Category name is required"),
        body("display_order").optional().isInt({ min: 0 })
    ],
    createCategoryAdmin
);

// UPDATE: PUT → /api/v1/scrap/admin/categories/:categoryId
router.put(
    "/admin/categories/:categoryId",
    auth("admin"),
    uploadCategoryIcon.single("icon"),
    [
        body("name").optional().notEmpty(),
        body("display_order").optional().isInt({ min: 0 })
    ],
    updateCategoryAdmin
);

// DELETE: DELETE → /api/v1/scrap/admin/categories/:categoryId
router.delete("/admin/categories/:categoryId", auth("admin"), deleteCategoryAdmin);


/* --- ADMIN: ITEMS --- */

// LIST: GET → /api/v1/scrap/admin/items
router.get("/admin/items", auth("admin"), listAdminItems);

// CREATE: POST → /api/v1/scrap/admin/items
router.post(
    "/admin/items",
    auth("admin"),
    uploadScrapItemImage.single("image"),
    [
        body("category_id")
            .notEmpty().withMessage("category_id is required")
            .isInt({ gt: 0 }).withMessage("category_id must be a positive number"),

        body("name")
            .notEmpty().withMessage("Item name is required"),

        body("unit")
            .optional()
            .isIn(["kg", "piece"]).withMessage("unit must be kg or piece"),

        body("min_price_per_unit")
            .notEmpty().withMessage("min_price_per_unit required")
            .isFloat({ min: 0 }).withMessage("Must be a valid price"),

        body("max_price_per_unit")
            .notEmpty().withMessage("max_price_per_unit required")
            .isFloat({ min: 0 }).withMessage("Must be a valid price"),
    ],
    createItemAdmin
);

// UPDATE: PUT → /api/v1/scrap/admin/items/:itemId
router.put(
    "/admin/items/:itemId",
    auth("admin"),
    uploadScrapItemImage.single("image"),
    [
        body("name").optional().notEmpty(),
        body("category_id").optional().isInt(),
        body("unit").optional().isIn(["kg", "piece"]),
        body("min_price_per_unit").optional().isFloat({ min: 0 }),
        body("max_price_per_unit").optional().isFloat({ min: 0 }),
    ],
    updateItemAdmin
);

// TOGGLE STATUS: PATCH → /api/v1/scrap/admin/items/:itemId/status
router.patch(
    "/admin/items/:itemId/status",
    auth("admin"),
    [
        body("is_active").isBoolean().withMessage("is_active must be a boolean")
    ],
    toggleItemStatusAdmin
);

// DELETE: DELETE → /api/v1/scrap/admin/items/:itemId
router.delete("/admin/items/:itemId", auth("admin"), deleteItemAdmin);

export default router;