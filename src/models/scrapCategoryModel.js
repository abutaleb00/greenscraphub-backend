import pool from "../config/db.js";

/* ----------------------------------------------------
    CREATE CATEGORY
    Updated: Supporting bilingual fields
---------------------------------------------------- */
export async function createCategory({ name_en, name_bn, slug, description = null, icon = null, display_order = 0 }) {
    const [result] = await pool.query(
        `
    INSERT INTO scrap_categories (name_en, name_bn, slug, description, icon, display_order)
    VALUES (?, ?, ?, ?, ?, ?)
    `,
        [name_en, name_bn, slug, description, icon, display_order]
    );

    return {
        id: result.insertId,
        name_en,
        name_bn,
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
    SELECT id, name_en, name_bn, slug, description, icon, display_order, is_active,
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
    SELECT id, name_en, name_bn, slug, description, icon, display_order, is_active,
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
    SELECT id, name_en, name_bn, slug, description, icon, display_order, is_active,
           created_at, updated_at
    FROM scrap_categories
    `;

    if (!includeInactive) {
        sql += ` WHERE is_active = 1`;
    }

    // Default sort by display order then English name
    sql += ` ORDER BY display_order ASC, name_en ASC`;

    const [rows] = await pool.query(sql);
    return rows;
}

/* ----------------------------------------------------
    UPDATE CATEGORY (Dynamic & Defensive)
    Updated: Included bilingual fields in allowedUpdates
---------------------------------------------------- */
export async function updateCategory(id, data) {
    const fields = [];
    const values = [];

    // Define allowed columns based on the new schema
    const allowedUpdates = ['name_en', 'name_bn', 'slug', 'description', 'icon', 'display_order', 'is_active'];

    Object.entries(data).forEach(([key, value]) => {
        if (allowedUpdates.includes(key) && value !== undefined) {
            fields.push(`${key} = ?`);
            values.push(value);
        }
    });

    if (fields.length === 0) return false;

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
    Logic: Atomic transaction to ensure data integrity
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

/* ----------------------------------------------------
    DELETE CATEGORY (Standard)
---------------------------------------------------- */
export async function deleteCategory(id) {
    const [result] = await pool.query(
        `DELETE FROM scrap_categories WHERE id = ?`,
        [id]
    );
    return result.affectedRows > 0;
}

/* ----------------------------------------------------
    ITEM COUNT HELPER
---------------------------------------------------- */
export async function getCategoryItemCount(id) {
    const [rows] = await pool.query(
        `SELECT COUNT(*) as count FROM scrap_items WHERE category_id = ?`,
        [id]
    );
    return rows[0].count;
}