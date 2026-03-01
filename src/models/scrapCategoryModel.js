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
   - includeInactive=false → only is_active=1
---------------------------------------------------- */
export async function getAllCategories({ includeInactive = false } = {}) {
    let query = `
    SELECT id, name, slug, description, icon, display_order, is_active,
           created_at, updated_at
    FROM scrap_categories
  `;
    const params = [];

    if (!includeInactive) {
        query += ` WHERE is_active = 1`;
    }

    query += ` ORDER BY display_order ASC, name ASC`;

    const [rows] = await pool.query(query, params);
    return rows;
}

/* ----------------------------------------------------
   UPDATE CATEGORY (dynamic)
---------------------------------------------------- */
export async function updateCategory(id, data) {
    const fields = [];
    const values = [];

    Object.entries(data).forEach(([key, value]) => {
        if (value !== undefined) {
            fields.push(`${key} = ?`);
            values.push(value);
        }
    });

    if (!fields.length) return false;

    values.push(id);

    await pool.query(
        `
    UPDATE scrap_categories
    SET ${fields.join(", ")}
    WHERE id = ?
    `,
        values
    );

    return true;
}

/* ----------------------------------------------------
   SOFT DELETE CATEGORY
---------------------------------------------------- */
export async function softDeleteCategory(id) {
    await pool.query(
        `
    UPDATE scrap_categories
    SET is_active = 0
    WHERE id = ?
    `,
        [id]
    );
    return true;
}
