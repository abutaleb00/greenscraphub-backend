// src/controllers/scrapCatalogController.js
import { validationResult } from "express-validator";
import ApiError from "../utils/ApiError.js";

import {
    createCategory,
    getAllCategories,
    getCategoryById,
    getCategoryBySlug,
    updateCategory,
} from "../models/scrapCategoryModel.js";

import {
    createScrapItem,
    getScrapItemById,
    getScrapItemsByCategory,
    getAllScrapItems,
    updateScrapItem,
    getScrapItemBySlug
} from "../models/scrapItemModel.js";

/* ----------------------------------------------------
   Helpers
---------------------------------------------------- */
function handleValidation(req) {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        throw new ApiError(422, errors.array()[0].msg);
    }
}

function slugify(text) {
    return String(text)
        .toLowerCase()
        .trim()
        .replace(/[^a-z0-9]+/g, "-")
        .replace(/^-+|-+$/g, "");
}

/* ====================================================
   PUBLIC CATALOG
==================================================== */

/* Public: GET /api/v1/scrap/categories */
export const listPublicCategories = async (req, res, next) => {
    try {
        const categories = await getAllCategories({ includeInactive: false });
        res.json({ success: true, data: categories });
    } catch (err) {
        next(err);
    }
};

/* Public: GET /api/v1/scrap/categories/:categoryId/items */
export const listPublicItemsByCategory = async (req, res, next) => {
    try {
        const { categoryId } = req.params;

        const category = await getCategoryById(categoryId);

        // If the category is inactive, we tell the user specifically
        if (!category) {
            throw new ApiError(404, "Category does not exist");
        }

        if (!category.is_active) {
            throw new ApiError(403, "This category is currently hidden");
        }

        // Check if items exist and are active
        const items = await getScrapItemsByCategory(categoryId, { onlyActive: true });

        res.json({
            success: true,
            data: {
                category,
                items: items || [], // Ensure items is always an array, never undefined
            },
        });
    } catch (err) {
        next(err);
    }
};;

/* Public: GET /api/v1/scrap/items/:itemId */
export const getPublicItemDetail = async (req, res, next) => {
    try {
        const { itemId } = req.params;
        const item = await getScrapItemById(itemId);
        if (!item || !item.is_active) {
            throw new ApiError(404, "Item not found");
        }

        res.json({ success: true, data: item });
    } catch (err) {
        next(err);
    }
};

/* ====================================================
   ADMIN CATALOG – CATEGORIES
==================================================== */

/* Admin: POST /api/v1/scrap/admin/categories */
export const createCategoryAdmin = async (req, res, next) => {
    try {
        handleValidation(req);

        const { name, slug: customSlug, description, display_order } = req.body;

        // Generate slug
        let slug = customSlug || slugify(name);

        // Ensure unique slug
        const existing = await getCategoryBySlug(slug);
        if (existing) {
            slug = `${slug}-${Date.now()}`;
        }

        // File upload handling
        let iconPath = null;
        if (req.file) {
            // return a relative path that frontend can display
            iconPath = `/uploads/category-icons/${req.file.filename}`;
        }

        // Save category
        const category = await createCategory({
            name,
            slug,
            description: description || null,
            icon: iconPath, // store relative path
            display_order: display_order ?? 0,
        });

        res.status(201).json({
            success: true,
            data: category,
        });
    } catch (err) {
        next(err);
    }
};

export const getAdminCategoryById = async (req, res, next) => {
    try {
        const { categoryId } = req.params;

        const category = await getCategoryById(categoryId);

        if (!category) {
            throw new ApiError(404, "Category not found");
        }

        res.json({ success: true, data: category });
    } catch (err) {
        next(err);
    }
};


/* Admin: GET /api/v1/scrap/admin/categories */
export const listAdminCategories = async (req, res, next) => {
    try {
        const includeInactive = req.query.includeInactive === "1";
        const categories = await getAllCategories({ includeInactive });
        res.json({ success: true, data: categories });
    } catch (err) {
        next(err);
    }
};

/* Admin: PUT /api/v1/scrap/admin/categories/:categoryId */
export const updateCategoryAdmin = async (req, res, next) => {
    try {
        handleValidation(req);

        const { categoryId } = req.params;
        const category = await getCategoryById(categoryId);
        if (!category) throw new ApiError(404, "Category not found");

        const { name, description, icon, display_order, is_active } = req.body;

        const dataToUpdate = {};
        if (name !== undefined) dataToUpdate.name = name;
        if (description !== undefined) dataToUpdate.description = description;
        if (icon !== undefined) dataToUpdate.icon = icon;
        if (display_order !== undefined) dataToUpdate.display_order = display_order;
        if (is_active !== undefined) dataToUpdate.is_active = is_active ? 1 : 0;

        await updateCategory(categoryId, dataToUpdate);

        const updated = await getCategoryById(categoryId);

        res.json({ success: true, data: updated });
    } catch (err) {
        next(err);
    }
};

/* ====================================================
   ADMIN CATALOG – ITEMS (with price range)
==================================================== */

/* Admin: POST /api/v1/scrap/admin/items */
export const createItemAdmin = async (req, res, next) => {
    try {
        handleValidation(req);

        const {
            category_id,
            name,
            description,
            unit,
            min_price_per_unit,
            max_price_per_unit
        } = req.body;

        // Convert numeric fields from string → number
        const minPrice = parseFloat(min_price_per_unit);
        const maxPrice = parseFloat(max_price_per_unit);

        if (isNaN(minPrice) || isNaN(maxPrice)) {
            throw new ApiError(400, "Price values must be numeric");
        }

        // Validate category exists
        const category = await getCategoryById(category_id);
        if (!category) {
            throw new ApiError(404, "Invalid category_id");
        }

        // Generate slug
        let slug = slugify(name, { lower: true, strict: true });
        const existingSlug = await getScrapItemBySlug(slug);
        if (existingSlug) {
            slug = `${slug}-${Date.now()}`;
        }

        // Handle file upload
        let imagePath = null;
        if (req.file) {
            imagePath = `/uploads/scrap-items/${req.file.filename}`;
        }

        // Save item
        const newItem = await createScrapItem({
            category_id,
            name,
            slug,
            description: description || null,
            unit: unit || "kg",
            min_price_per_unit: minPrice,
            max_price_per_unit: maxPrice,
            image_url: imagePath, // DB column
        });

        return res.status(201).json({
            success: true,
            data: newItem
        });

    } catch (err) {
        next(err);
    }
};


/* Admin: GET /api/v1/scrap/admin/items */
export const listAdminItems = async (req, res, next) => {
    try {
        const includeInactive = req.query.includeInactive === "1";
        const items = await getAllScrapItems({ includeInactive });
        res.json({ success: true, data: items });
    } catch (err) {
        next(err);
    }
};

/* Admin: PUT /api/v1/scrap/admin/items/:itemId */
export const updateItemAdmin = async (req, res, next) => {
    try {
        handleValidation(req);

        const { itemId } = req.params;
        const item = await getScrapItemById(itemId);
        if (!item) throw new ApiError(404, "Item not found");

        const {
            name,
            description,
            unit,
            min_price_per_unit,
            max_price_per_unit,
            image_url,
            is_active,
            category_id,
        } = req.body;

        if (
            min_price_per_unit !== undefined &&
            max_price_per_unit !== undefined &&
            Number(min_price_per_unit) > Number(max_price_per_unit)
        ) {
            throw new ApiError(400, "min_price_per_unit cannot be greater than max_price_per_unit");
        }

        if (category_id !== undefined) {
            const category = await getCategoryById(category_id);
            if (!category) throw new ApiError(400, "Invalid category_id");
        }

        const dataToUpdate = {};
        if (name !== undefined) dataToUpdate.name = name;
        if (description !== undefined) dataToUpdate.description = description;
        if (unit !== undefined) dataToUpdate.unit = unit;
        if (min_price_per_unit !== undefined) dataToUpdate.min_price_per_unit = min_price_per_unit;
        if (max_price_per_unit !== undefined) dataToUpdate.max_price_per_unit = max_price_per_unit;
        if (image_url !== undefined) dataToUpdate.image_url = image_url;
        if (is_active !== undefined) dataToUpdate.is_active = is_active ? 1 : 0;
        if (category_id !== undefined) dataToUpdate.category_id = category_id;

        await updateScrapItem(itemId, dataToUpdate);

        const updated = await getScrapItemById(itemId);
        res.json({ success: true, data: updated });
    } catch (err) {
        next(err);
    }
};
