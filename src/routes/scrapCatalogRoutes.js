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
    deleteItemAdmin,
    getRiderPriceList
} from "../controllers/scrapCatalogController.js";
import { getMarketOverview } from "../controllers/scrapItemController.js";

const router = express.Router();

/* ====================================================
    PUBLIC CATALOG ROUTES
    (Accessible by mobile app and guest users)
==================================================== */

router.get("/market-overview", getMarketOverview);
router.get("/categories", listPublicCategories);
router.get("/categories/:categoryId/items", listPublicItemsByCategory);
router.get("/items/:itemId", getPublicItemDetail);

router.get("/rider/price-list", auth(["rider", "agent", "admin"]), getRiderPriceList);
/* ====================================================
    ADMIN CATALOG ROUTES
    (Strictly Protected by auth(["admin"]))
==================================================== */

/* --- ADMIN: CATEGORIES --- */

router.get("/admin/categories", auth(["admin"]), listAdminCategories);
router.get("/admin/categories/:categoryId", auth(["admin"]), getAdminCategoryById);

router.post(
    "/admin/categories",
    auth(["admin"]),
    uploadCategoryIcon.single("icon"),
    [
        body("name_en").notEmpty().withMessage("English category name is required"),
        body("name_bn").notEmpty().withMessage("Bangla category name is required"),
        body("display_order").optional().isInt({ min: 0 })
    ],
    createCategoryAdmin
);

router.put(
    "/admin/categories/:categoryId",
    auth(["admin"]),
    uploadCategoryIcon.single("icon"),
    [
        body("name_en").optional().notEmpty(),
        body("name_bn").optional().notEmpty(),
        body("display_order").optional().isInt({ min: 0 }),
        body("is_active").optional().isBoolean()
    ],
    updateCategoryAdmin
);

router.delete("/admin/categories/:categoryId", auth(["admin"]), deleteCategoryAdmin);


/* --- ADMIN: ITEMS --- */

router.get("/admin/items", auth(["admin"]), listAdminItems);

router.post(
    "/admin/items",
    auth(["admin"]),
    uploadScrapItemImage.single("image"),
    [
        body("category_id")
            .notEmpty().withMessage("category_id is required")
            .isInt({ gt: 0 }).withMessage("category_id must be a positive number"),

        body("name_en").notEmpty().withMessage("English item name is required"),
        body("name_bn").notEmpty().withMessage("Bangla item name is required"),

        body("unit")
            .optional()
            .isIn(["kg", "piece", "gm", "ton"]).withMessage("Invalid unit"),

        body("current_min_rate")
            .notEmpty().withMessage("current_min_rate is required")
            .isFloat({ min: 0 }).withMessage("Min rate must be a valid positive number"),

        body("current_max_rate")
            .notEmpty().withMessage("current_max_rate is required")
            .isFloat({ min: 0 }).withMessage("Max rate must be a valid positive number"),
    ],
    createItemAdmin
);

router.put(
    "/admin/items/:itemId",
    auth(["admin"]),
    uploadScrapItemImage.single("image"),
    [
        body("name_en").optional({ checkFalsy: true }).notEmpty(),
        body("name_bn").optional({ checkFalsy: true }),
        // category_id is sent as a string by FormData, we must ensure it's a numeric string
        body("category_id").optional({ checkFalsy: true }).isNumeric().withMessage("Category ID must be numeric"),
        body("unit").optional({ checkFalsy: true }).isString(),
        // Allow numeric strings and convert them
        body("current_min_rate").optional({ checkFalsy: true }).isNumeric().withMessage("Min rate must be a number"),
        body("current_max_rate").optional({ checkFalsy: true }).isNumeric().withMessage("Max rate must be a number"),
        body("is_active").optional().isIn(['0', '1', 0, 1]),
        body("change_reason").optional({ checkFalsy: true }).isString()
    ],
    updateItemAdmin
);

router.patch(
    "/admin/items/:itemId/status",
    auth(["admin"]),
    [
        body("is_active").isBoolean().withMessage("is_active must be a boolean (true/false or 1/0)")
    ],
    toggleItemStatusAdmin
);

router.delete("/admin/items/:itemId", auth(["admin"]), deleteItemAdmin);

export default router;