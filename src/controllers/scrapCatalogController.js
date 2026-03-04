// src/controllers/scrapCatalogController.js

import { validationResult } from "express-validator";
import ApiError from "../utils/ApiError.js";
import db from "../config/db.js"; // Using direct db for transactions and specific history logic

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
    deleteScrapItem,
    updateItemStatus
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

/**
 * RIDER SPECIFIC: Get simplified price list for weighing
 */
export const getRiderPriceList = async (req, res, next) => {
    try {
        const [items] = await db.query(`
            SELECT 
                id, 
                name_en as name, 
                unit, 
                current_min_rate as price, -- Using min_rate as default purchase price
                current_max_rate as max_price,
                image_url
            FROM scrap_items 
            WHERE is_active = 1 
            ORDER BY name_en ASC
        `);

        res.json({
            success: true,
            data: items
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
        const { name_en, name_bn, slug: customSlug, description, display_order } = req.body;

        let slug = customSlug || slugify(name_en);
        const existing = await getCategoryBySlug(slug);
        if (existing) slug = `${slug}-${Date.now()}`;

        let iconPath = null;
        if (req.file) {
            iconPath = `/uploads/category-icons/${req.file.filename}`;
        }

        const category = await createCategory({
            name_en,
            name_bn,
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

        const { name_en, name_bn, description, display_order, is_active } = req.body;

        const dataToUpdate = {};
        if (name_en !== undefined) {
            dataToUpdate.name_en = name_en;
            dataToUpdate.slug = slugify(name_en);
        }
        if (name_bn !== undefined) dataToUpdate.name_bn = name_bn;
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
        const { category_id, name_en, name_bn, description, unit, current_min_rate, current_max_rate } = req.body;

        const minPrice = parseFloat(current_min_rate);
        const maxPrice = parseFloat(current_max_rate);
        if (isNaN(minPrice) || isNaN(maxPrice)) throw new ApiError(400, "Price values must be numeric");

        const category = await getCategoryById(category_id);
        if (!category) throw new ApiError(404, "Invalid category_id");

        let slug = slugify(name_en);
        const existingSlug = await getScrapItemBySlug(slug);
        if (existingSlug) slug = `${slug}-${Date.now()}`;

        let imagePath = null;
        if (req.file) {
            imagePath = `/uploads/scrap-items/${req.file.filename}`;
        }

        const newItem = await createScrapItem({
            category_id,
            name_en,
            name_bn,
            slug,
            description: description || null,
            unit: unit || "kg",
            current_min_rate: minPrice,
            current_max_rate: maxPrice,
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


/**
 * Update Scrap Item with Price History Tracking
 */
export const updateItemAdmin = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        // 1. Validate the request (Ensures numeric fields are valid)
        handleValidation(req);

        const { itemId } = req.params;
        const adminId = req.user.id;

        await conn.beginTransaction();

        // 2. Get existing item details with Row Lock
        const [oldItemRows] = await conn.query(
            "SELECT current_min_rate, current_max_rate, image_url FROM scrap_items WHERE id = ? FOR UPDATE",
            [itemId]
        );

        if (!oldItemRows.length) throw new ApiError(404, "Item not found");
        const oldItem = oldItemRows[0];

        // 3. Destructure and Sanitize Body
        // Note: Multer puts text fields in req.body. 
        // We handle strings vs numbers carefully here.
        const {
            name_en,
            name_bn,
            description,
            unit,
            current_min_rate,
            current_max_rate,
            is_active,
            category_id,
            change_reason
        } = req.body;

        const dataToUpdate = {};

        // Handle Text Fields (checking for string 'undefined' from FormData)
        if (name_en) {
            dataToUpdate.name_en = name_en;
            dataToUpdate.slug = name_en.toLowerCase().replace(/ /g, '-').replace(/[^\w-]+/g, '');
        }

        if (name_bn !== undefined) dataToUpdate.name_bn = name_bn === 'undefined' ? null : name_bn;
        if (description !== undefined) dataToUpdate.description = description === 'undefined' ? null : description;
        if (unit !== undefined) dataToUpdate.unit = unit;
        if (category_id !== undefined) dataToUpdate.category_id = parseInt(category_id);
        if (is_active !== undefined) dataToUpdate.is_active = parseInt(is_active);

        // 4. Handle Pricing & Change Detection
        let priceChanged = false;
        const newMin = current_min_rate !== undefined ? parseFloat(current_min_rate) : parseFloat(oldItem.current_min_rate);
        const newMax = current_max_rate !== undefined ? parseFloat(current_max_rate) : parseFloat(oldItem.current_max_rate);

        if (newMin !== parseFloat(oldItem.current_min_rate) || newMax !== parseFloat(oldItem.current_max_rate)) {
            priceChanged = true;
            dataToUpdate.current_min_rate = newMin;
            dataToUpdate.current_max_rate = newMax;
        }

        // 5. Handle Image Upload (Fixes 404 issue)
        if (req.file) {
            // Store the relative path. Ensure your static middleware serves the 'uploads' folder
            dataToUpdate.image_url = `/uploads/scrap-items/${req.file.filename}`;
        }

        // 6. Execute Update Query
        if (Object.keys(dataToUpdate).length > 0) {
            const fields = Object.keys(dataToUpdate).map(key => `${key} = ?`).join(", ");
            const values = Object.values(dataToUpdate);

            await conn.query(
                `UPDATE scrap_items SET ${fields} WHERE id = ?`,
                [...values, itemId]
            );
        }

        // 7. Record History if Price Changed
        if (priceChanged) {
            await conn.query(
                `INSERT INTO scrap_price_history 
                (scrap_item_id, old_min_price, old_max_price, new_min_price, new_max_price, changed_by_user_id, change_reason) 
                VALUES (?, ?, ?, ?, ?, ?, ?)`,
                [
                    itemId,
                    oldItem.current_min_rate,
                    oldItem.current_max_rate,
                    newMin,
                    newMax,
                    adminId,
                    change_reason || "Administrative Price Update"
                ]
            );
        }

        await conn.commit();

        // 8. Prepare Response
        // Helper to ensure URL is correct for frontend
        const getFullUrl = (path) => {
            if (!path) return null;
            if (path.startsWith('http')) return path;
            return `${req.protocol}://${req.get('host')}${path}`;
        };

        res.json({
            success: true,
            message: "Item updated successfully",
            data: {
                id: itemId,
                ...dataToUpdate,
                image_url: getFullUrl(dataToUpdate.image_url || oldItem.image_url)
            }
        });

    } catch (err) {
        await conn.rollback();
        console.error("Update Error Details:", err);
        next(err);
    } finally {
        conn.release();
    }
};

/* --- STATUS & DELETE HANDLERS --- */

export const toggleItemStatusAdmin = async (req, res, next) => {
    try {
        const { itemId } = req.params;
        const { is_active } = req.body;

        if (is_active === undefined) throw new ApiError(400, "is_active status is required (1 or 0)");

        const success = await updateItemStatus(itemId, is_active);
        if (!success) throw new ApiError(404, "Scrap item not found");

        res.json({
            success: true,
            message: `Item successfully ${is_active ? 'activated' : 'deactivated'}`
        });
    } catch (err) {
        next(err);
    }
};

export const deleteItemAdmin = async (req, res, next) => {
    try {
        const { itemId } = req.params;
        const result = await deleteScrapItem(itemId);

        if (!result || result.affectedRows === 0) throw new ApiError(404, "Item not found");

        const message = result.type === 'soft'
            ? "Item is linked to history. It has been deactivated and hidden."
            : "Item permanently deleted from the catalog.";

        res.json({ success: true, message, deletedType: result.type });
    } catch (err) {
        if (err.code === 'ER_ROW_IS_REFERENCED_2') {
            return next(new ApiError(409, "Cannot delete: referenced in records. Please deactivate instead."));
        }
        next(err);
    }
};

export const deleteCategoryAdmin = async (req, res, next) => {
    try {
        const { categoryId } = req.params;
        const { reassignToId } = req.body;

        const itemCount = await getCategoryItemCount(categoryId);

        if (itemCount > 0) {
            if (!reassignToId) {
                return res.status(400).json({
                    success: false,
                    message: `Category contains ${itemCount} items. Select a replacement category.`,
                    requiresReassignment: true
                });
            }
            await deleteCategoryAndReassignItems(categoryId, reassignToId);
        } else {
            await deleteCategory(categoryId);
        }

        res.json({ success: true, message: "Category processed successfully" });
    } catch (err) {
        next(err);
    }
};