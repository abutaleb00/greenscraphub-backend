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
const getFullUrl = (relativePath) => {
    if (!relativePath) return null;
    // If it's already a full URL, return it
    if (relativePath.startsWith('http')) return relativePath;

    const baseUrl = process.env.BASE_URL || 'http://localhost:4000';
    // Ensure there is no double slash between baseUrl and relativePath
    return `${baseUrl.replace(/\/$/, "")}/${relativePath.replace(/^\//, "")}`;
};

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

        // Transform relative paths to full URLs
        const transformedData = categories.map(cat => ({
            ...cat,
            icon: getFullUrl(cat.icon)
        }));

        res.json({ success: true, data: transformedData });
    } catch (err) {
        next(err);
    }
};

/* Public: GET /api/v1/scrap/categories/:categoryId/items */
export const listPublicItemsByCategory = async (req, res, next) => {
    try {
        const { categoryId } = req.params;
        const category = await getCategoryById(categoryId);

        if (!category) {
            throw new ApiError(404, "Category does not exist");
        }
        if (!category.is_active) {
            throw new ApiError(403, "This category is currently hidden");
        }

        const items = await getScrapItemsByCategory(categoryId, { onlyActive: true });

        // Transform relative paths to full URLs
        const transformedCategory = { ...category, icon: getFullUrl(category.icon) };
        const transformedItems = (items || []).map(item => ({
            ...item,
            image_url: getFullUrl(item.image_url)
        }));

        res.json({
            success: true,
            data: {
                category: transformedCategory,
                items: transformedItems,
            },
        });
    } catch (err) {
        next(err);
    }
};

/* Public: GET /api/v1/scrap/items/:itemId */
export const getPublicItemDetail = async (req, res, next) => {
    try {
        const { itemId } = req.params;
        const item = await getScrapItemById(itemId);
        if (!item || !item.is_active) {
            throw new ApiError(404, "Item not found");
        }

        res.json({ 
            success: true, 
            data: { ...item, image_url: getFullUrl(item.image_url) } 
        });
    } catch (err) {
        next(err);
    }
};

/* ====================================================
   ADMIN CATALOG – CATEGORIES
==================================================== */

export const createCategoryAdmin = async (req, res, next) => {
    try {
        handleValidation(req);
        const { name, slug: customSlug, description, display_order } = req.body;

        let slug = customSlug || slugify(name);
        const existing = await getCategoryBySlug(slug);
        if (existing) slug = `${slug}-${Date.now()}`;

        let iconPath = null;
        if (req.file) {
            // Save ONLY the relative path in the DB
            iconPath = `/uploads/category-icons/${req.file.filename}`;
        }

        const category = await createCategory({
            name,
            slug,
            description: description || null,
            icon: iconPath,
            display_order: display_order ?? 0,
        });

        res.status(201).json({
            success: true,
            data: { ...category, icon: getFullUrl(category.icon) },
        });
    } catch (err) {
        next(err);
    }
};

export const getAdminCategoryById = async (req, res, next) => {
    try {
        const { categoryId } = req.params;
        const category = await getCategoryById(categoryId);
        if (!category) throw new ApiError(404, "Category not found");

        res.json({ 
            success: true, 
            data: { ...category, icon: getFullUrl(category.icon) } 
        });
    } catch (err) {
        next(err);
    }
};


/* Admin: GET /api/v1/scrap/admin/categories */
export const listAdminCategories = async (req, res, next) => {
    try {
        const includeInactive = req.query.includeInactive === "1";
        const categories = await getAllCategories({ includeInactive });
        
        const transformedData = categories.map(cat => ({
            ...cat,
            icon: getFullUrl(cat.icon)
        }));

        res.json({ success: true, data: transformedData });
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
        const { category_id, name, description, unit, min_price_per_unit, max_price_per_unit } = req.body;

        const minPrice = parseFloat(min_price_per_unit);
        const maxPrice = parseFloat(max_price_per_unit);

        if (isNaN(minPrice) || isNaN(maxPrice)) throw new ApiError(400, "Price values must be numeric");

        const category = await getCategoryById(category_id);
        if (!category) throw new ApiError(404, "Invalid category_id");

        let slug = slugify(name);
        const existingSlug = await getScrapItemBySlug(slug);
        if (existingSlug) slug = `${slug}-${Date.now()}`;

        let imagePath = null;
        if (req.file) {
            // Save ONLY the relative path in the DB
            imagePath = `/uploads/scrap-items/${req.file.filename}`;
        }

        const newItem = await createScrapItem({
            category_id,
            name,
            slug,
            description: description || null,
            unit: unit || "kg",
            min_price_per_unit: minPrice,
            max_price_per_unit: maxPrice,
            image_url: imagePath,
        });

        return res.status(201).json({
            success: true,
            data: { ...newItem, image_url: getFullUrl(newItem.image_url) }
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
        
        const transformedData = items.map(item => ({
            ...item,
            image_url: getFullUrl(item.image_url)
        }));

        res.json({ success: true, data: transformedData });
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

        const { name, description, unit, min_price_per_unit, max_price_per_unit, is_active, category_id } = req.body;

        // ... validation logic omitted for brevity ...

        const dataToUpdate = {};
        if (name !== undefined) dataToUpdate.name = name;
        if (description !== undefined) dataToUpdate.description = description;
        if (unit !== undefined) dataToUpdate.unit = unit;
        if (min_price_per_unit !== undefined) dataToUpdate.min_price_per_unit = min_price_per_unit;
        if (max_price_per_unit !== undefined) dataToUpdate.max_price_per_unit = max_price_per_unit;
        if (is_active !== undefined) dataToUpdate.is_active = is_active ? 1 : 0;
        if (category_id !== undefined) dataToUpdate.category_id = category_id;
        
        // If there's a new file upload via multer
        if (req.file) {
            dataToUpdate.image_url = `/uploads/scrap-items/${req.file.filename}`;
        }

        await updateScrapItem(itemId, dataToUpdate);
        const updated = await getScrapItemById(itemId);

        res.json({ 
            success: true, 
            data: { ...updated, image_url: getFullUrl(updated.image_url) } 
        });
    } catch (err) {
        next(err);
    }
};
