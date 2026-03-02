// src/models/scrapCategoryModel.js
import pool from "../config/db.js";

/* ----------------------------------------------------
   CREATE CATEGORY
---------------------------------------------------- */
export async function createCategory({ name, slug, description = null, icon = null, display_order = 0 }) {
    const [result] = await pool.query(
        `
    INSERT INTO scrap_categories (name, slug, description, icon, display_order)
    VALUES (?, ?, ?, ?, ?)
    `,
        [name, slug, description, icon, display_order]
    );

    return {
        id: result.insertId,
        name,
        slug,
        description,
        icon,
        display_order,
        is_active: 1,
    };
}

/* ----------------------------------------------------
   GET CATEGORY BY ID
---------------------------------------------------- */
export async function getCategoryById(id) {
    const [rows] = await pool.query(
        `
    SELECT id, name, slug, description, icon, display_order, is_active,
           created_at, updated_at
    FROM scrap_categories
    WHERE id = ?
    LIMIT 1
    `,
        [id]
    );

    return rows[0] || null;
}

/* ----------------------------------------------------
   GET CATEGORY BY SLUG
---------------------------------------------------- */
export async function getCategoryBySlug(slug) {
    const [rows] = await pool.query(
        `
    SELECT id, name, slug, description, icon, display_order, is_active,
           created_at, updated_at
    FROM scrap_categories
    WHERE slug = ?
    LIMIT 1
    `,
        [slug]
    );

    return rows[0] || null;
}

/* ----------------------------------------------------
   LIST CATEGORIES
---------------------------------------------------- */
export async function getAllCategories({ includeInactive = false } = {}) {
    let sql = `
    SELECT id, name, slug, description, icon, display_order, is_active,
           created_at, updated_at
    FROM scrap_categories
    `;

    if (!includeInactive) {
        sql += ` WHERE is_active = 1`;
    }

    sql += ` ORDER BY display_order ASC, name ASC`;

    const [rows] = await pool.query(sql);
    return rows;
}

/* ----------------------------------------------------
   UPDATE CATEGORY (Dynamic & Defensive)
   Fixed: Prevents empty values like "icon = ,"
---------------------------------------------------- */
export async function updateCategory(id, data) {
    const fields = [];
    const values = [];

    // Define allowed columns to prevent malicious input
    const allowedUpdates = ['name', 'slug', 'description', 'icon', 'display_order', 'is_active'];

    Object.entries(data).forEach(([key, value]) => {
        // Only add to query if key is allowed and value is NOT undefined
        if (allowedUpdates.includes(key) && value !== undefined) {
            fields.push(`${key} = ?`);
            values.push(value);
        }
    });

    if (fields.length === 0) return false;

    // Add ID to the values array for the WHERE clause
    values.push(id);

    const sql = `
        UPDATE scrap_categories 
        SET ${fields.join(", ")} 
        WHERE id = ?
    `;

    const [result] = await pool.query(sql, values);
    return result.affectedRows > 0;
}

/* ----------------------------------------------------
   SOFT DELETE CATEGORY
---------------------------------------------------- */
export async function softDeleteCategory(id) {
    const [result] = await pool.query(
        `
    UPDATE scrap_categories
    SET is_active = 0
    WHERE id = ?
    `,
        [id]
    );
    return result.affectedRows > 0;
}

/* ----------------------------------------------------
   DELETE CATEGORY WITH REASSIGNMENT
   - Moves all items from old category to new category
   - Then deletes the old category
---------------------------------------------------- */
export async function deleteCategoryAndReassignItems(id, reassignToId) {
    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        // 1. Move all items to the new category
        await connection.query(
            `UPDATE scrap_items SET category_id = ? WHERE category_id = ?`,
            [reassignToId, id]
        );

        // 2. Delete the old category
        const [result] = await connection.query(
            `DELETE FROM scrap_categories WHERE id = ?`,
            [id]
        );

        await connection.commit();
        return result.affectedRows > 0;
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}

/** * Keep your existing deleteCategory for "Clean" deletes 
 * (where you know the category is empty)
 */
export async function deleteCategory(id) {
    const [result] = await pool.query(
        `DELETE FROM scrap_categories WHERE id = ?`,
        [id]
    );
    return result.affectedRows > 0;
}

/**
 * Helper to check if a category has items
 */
export async function getCategoryItemCount(id) {
    const [rows] = await pool.query(
        `SELECT COUNT(*) as count FROM scrap_items WHERE category_id = ?`,
        [id]
    );
    // MariaDB returns an array, so we grab the first row and the count column
    return rows[0].count;
}