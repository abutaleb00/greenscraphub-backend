import { validationResult } from "express-validator";
import ApiError from "../utils/ApiError.js";

import {
    createCategory,
    getAllCategories,
    getCategoryById,
    getCategoryBySlug,
    updateCategory,
    deleteCategory,
    deleteCategoryAndReassignItems,
    getCategoryItemCount
} from "../models/scrapCategoryModel.js";

import {
    createScrapItem,
    getScrapItemById,
    getScrapItemsByCategory,
    getAllScrapItems,
    updateScrapItem,
    getScrapItemBySlug,
    deleteScrapItem, // Ensure this is exported in your model
    updateItemStatus // Ensure this is exported in your model
} from "../models/scrapItemModel.js";

/* ----------------------------------------------------
   Helpers
---------------------------------------------------- */
const getFullUrl = (relativePath) => {
    if (!relativePath) return null;
    if (relativePath.startsWith('http')) return relativePath;

    const baseUrl = process.env.BASE_URL || 'http://localhost:4000';
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

export const listPublicCategories = async (req, res, next) => {
    try {
        const categories = await getAllCategories({ includeInactive: false });
        const transformedData = categories.map(cat => ({
            ...cat,
            icon: getFullUrl(cat.icon)
        }));
        res.json({ success: true, data: transformedData });
    } catch (err) {
        next(err);
    }
};

export const listPublicItemsByCategory = async (req, res, next) => {
    try {
        const { categoryId } = req.params;
        const category = await getCategoryById(categoryId);

        if (!category) throw new ApiError(404, "Category does not exist");
        if (!category.is_active) throw new ApiError(403, "This category is currently hidden");

        const items = await getScrapItemsByCategory(categoryId, { onlyActive: true });

        res.json({
            success: true,
            data: {
                category: { ...category, icon: getFullUrl(category.icon) },
                items: (items || []).map(item => ({
                    ...item,
                    image_url: getFullUrl(item.image_url)
                })),
            },
        });
    } catch (err) {
        next(err);
    }
};

export const getPublicItemDetail = async (req, res, next) => {
    try {
        const { itemId } = req.params;
        const item = await getScrapItemById(itemId);
        if (!item || !item.is_active) throw new ApiError(404, "Item not found");

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

export const updateCategoryAdmin = async (req, res, next) => {
    try {
        handleValidation(req);
        const { categoryId } = req.params;
        const category = await getCategoryById(categoryId);
        if (!category) throw new ApiError(404, "Category not found");

        const { name, description, display_order, is_active } = req.body;

        const dataToUpdate = {};
        if (name !== undefined) {
            dataToUpdate.name = name;
            dataToUpdate.slug = slugify(name);
        }
        if (description !== undefined) dataToUpdate.description = description;
        if (display_order !== undefined) dataToUpdate.display_order = display_order;
        if (is_active !== undefined) dataToUpdate.is_active = is_active;

        if (req.file) {
            dataToUpdate.icon = `/uploads/category-icons/${req.file.filename}`;
        }

        await updateCategory(categoryId, dataToUpdate);
        const updated = await getCategoryById(categoryId);

        res.json({
            success: true,
            data: { ...updated, icon: getFullUrl(updated.icon) }
        });
    } catch (err) {
        next(err);
    }
};

/* ====================================================
   ADMIN CATALOG – ITEMS
==================================================== */

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

        res.status(201).json({
            success: true,
            data: { ...newItem, image_url: getFullUrl(newItem.image_url) }
        });
    } catch (err) {
        next(err);
    }
};

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

export const updateItemAdmin = async (req, res, next) => {
    try {
        handleValidation(req);
        const { itemId } = req.params;
        const item = await getScrapItemById(itemId);
        if (!item) throw new ApiError(404, "Item not found");

        const { name, description, unit, min_price_per_unit, max_price_per_unit, is_active, category_id } = req.body;

        const dataToUpdate = {};
        if (name !== undefined) {
            dataToUpdate.name = name;
            dataToUpdate.slug = slugify(name);
        }
        if (description !== undefined) dataToUpdate.description = description;
        if (unit !== undefined) dataToUpdate.unit = unit;
        if (min_price_per_unit !== undefined) dataToUpdate.min_price_per_unit = parseFloat(min_price_per_unit);
        if (max_price_per_unit !== undefined) dataToUpdate.max_price_per_unit = parseFloat(max_price_per_unit);
        if (is_active !== undefined) dataToUpdate.is_active = is_active;
        if (category_id !== undefined) dataToUpdate.category_id = category_id;

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

/* --- NEW STATUS & DELETE HANDLERS --- */

/* ----------------------------------------------------
   Admin: Toggle Item Visibility
   PATCH /api/v1/scrap/admin/items/:itemId/status
---------------------------------------------------- */
export const toggleItemStatusAdmin = async (req, res, next) => {
    try {
        const { itemId } = req.params;
        const { is_active } = req.body;

        // Validation: Ensure status is provided and is a boolean/number
        if (is_active === undefined) {
            throw new ApiError(400, "is_active status is required (1 or 0)");
        }

        const success = await updateItemStatus(itemId, is_active);

        if (!success) {
            throw new ApiError(404, "Scrap item not found");
        }

        res.json({
            success: true,
            message: `Item successfully ${is_active ? 'activated' : 'deactivated'}`
        });
    } catch (err) {
        next(err);
    }
};

/* ----------------------------------------------------
   Admin: Delete Scrap Item
   DELETE /api/v1/scrap/admin/items/:itemId
---------------------------------------------------- */
export const deleteItemAdmin = async (req, res, next) => {
    try {
        const { itemId } = req.params;

        // The model now returns an object { success, type, affectedRows }
        const result = await deleteScrapItem(itemId);

        if (!result || result.affectedRows === 0) {
            throw new ApiError(404, "Item not found");
        }

        // Provide clear feedback if it was a soft delete due to history
        const message = result.type === 'soft'
            ? "Item is linked to pickup history. It has been deactivated and hidden instead of permanently deleted."
            : "Item permanently deleted from the catalog.";

        res.json({
            success: true,
            message,
            deletedType: result.type
        });
    } catch (err) {
        // Fallback for unexpected database constraint errors
        if (err.code === 'ER_ROW_IS_REFERENCED_2') {
            return next(new ApiError(409, "Cannot delete this item because it is referenced in historical records. Please deactivate it instead."));
        }
        next(err);
    }
};

/* Admin: DELETE /api/v1/scrap/admin/categories/:categoryId */
export const deleteCategoryAdmin = async (req, res, next) => {
    try {
        const { categoryId } = req.params;
        const { reassignToId } = req.body;

        const itemCount = await getCategoryItemCount(categoryId);

        if (itemCount > 0) {
            if (!reassignToId) {
                return res.status(400).json({
                    success: false,
                    message: `Category contains ${itemCount} items. Please select a replacement category to move them to.`,
                    requiresReassignment: true
                });
            }
            // Move items and delete
            await deleteCategoryAndReassignItems(categoryId, reassignToId);
        } else {
            // Safe to delete normally
            await deleteCategory(categoryId);
        }

        res.json({ success: true, message: "Category processed successfully" });
    } catch (err) {
        next(err);
    }
};