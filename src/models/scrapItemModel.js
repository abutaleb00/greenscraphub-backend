// src/models/scrapItemModel.js
import pool from "../config/db.js";

/* ----------------------------------------------------
    CREATE ITEM
---------------------------------------------------- */
export async function createScrapItem({
    category_id,
    name_en,
    name_bn,
    slug,
    description = null,
    unit = "kg",
    current_min_rate,
    current_max_rate,
    image_url = null,
}) {
    const [result] = await pool.query(
        `
    INSERT INTO scrap_items (
      category_id,
      name_en,
      name_bn,
      slug,
      description,
      unit,
      current_min_rate,
      current_max_rate,
      image_url
    )
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    `,
        [
            category_id,
            name_en,
            name_bn,
            slug,
            description,
            unit,
            current_min_rate,
            current_max_rate,
            image_url,
        ]
    );

    return await getScrapItemById(result.insertId);
}

/* ----------------------------------------------------
    GET ITEM BY SLUG
---------------------------------------------------- */
export async function getScrapItemBySlug(slug) {
    const [rows] = await pool.query(
        `
        SELECT 
          i.*,
          c.name_en AS category_name_en,
          c.name_bn AS category_name_bn
        FROM scrap_items i
        LEFT JOIN scrap_categories c ON i.category_id = c.id
        WHERE i.slug = ?
        LIMIT 1
        `,
        [slug]
    );

    return rows[0] || null;
}

/* ----------------------------------------------------
    GET ITEM BY ID
---------------------------------------------------- */
export async function getScrapItemById(id) {
    const [rows] = await pool.query(
        `
    SELECT 
      i.*,
      c.name_en AS category_name_en,
      c.name_bn AS category_name_bn
    FROM scrap_items i
    LEFT JOIN scrap_categories c ON i.category_id = c.id
    WHERE i.id = ?
    LIMIT 1
    `,
        [id]
    );

    return rows[0] || null;
}

/* ----------------------------------------------------
    GET ITEMS BY CATEGORY (PUBLIC)
---------------------------------------------------- */
export async function getScrapItemsByCategory(categoryId, { onlyActive = true } = {}) {
    let query = `
    SELECT 
      id,
      category_id,
      name_en,
      name_bn,
      slug,
      description,
      unit,
      current_min_rate,
      current_max_rate,
      image_url,
      is_active,
      created_at,
      updated_at
    FROM scrap_items
    WHERE category_id = ?
  `;

    const params = [categoryId];

    if (onlyActive) {
        query += ` AND is_active = 1`;
    }

    query += ` ORDER BY name_en ASC`;

    const [rows] = await pool.query(query, params);
    return rows;
}

/* ----------------------------------------------------
    LIST ALL ITEMS (ADMIN)
---------------------------------------------------- */
export async function getAllScrapItems({ includeInactive = false } = {}) {
    let query = `
    SELECT 
      i.*,
      c.name_en AS category_name_en,
      c.name_bn AS category_name_bn
    FROM scrap_items i
    LEFT JOIN scrap_categories c ON i.category_id = c.id
  `;

    if (!includeInactive) {
        query += ` WHERE i.is_active = 1`;
    }

    query += ` ORDER BY c.name_en ASC, i.name_en ASC`;

    const [rows] = await pool.query(query);
    return rows;
}

/* ----------------------------------------------------
    UPDATE ITEM (Defensive Dynamic Update)
    Supports Transactional Connection from Controller
---------------------------------------------------- */
export async function updateScrapItem(id, data, connection = null) {
    const conn = connection || pool;
    const fields = [];
    const values = [];

    const allowedUpdates = [
        'category_id', 'name_en', 'name_bn', 'slug', 'description',
        'unit', 'current_min_rate', 'current_max_rate',
        'image_url', 'is_active'
    ];

    for (const [key, value] of Object.entries(data)) {
        if (allowedUpdates.includes(key) && value !== undefined) {
            fields.push(`${key} = ?`);
            values.push(value);
        }
    }

    if (!fields.length) return false;

    values.push(id);

    const [result] = await conn.query(
        `
    UPDATE scrap_items
    SET ${fields.join(", ")}
    WHERE id = ?
    `,
        values
    );

    return result.affectedRows > 0;
}

/* ----------------------------------------------------
    TOGGLE ACTIVE STATUS
---------------------------------------------------- */
export async function updateItemStatus(id, isActive) {
    const [result] = await pool.query(
        `UPDATE scrap_items SET is_active = ? WHERE id = ?`,
        [isActive ? 1 : 0, id]
    );
    return result.affectedRows > 0;
}

/* ----------------------------------------------------
    DELETE ITEM (Hybrid Hard/Soft Delete)
---------------------------------------------------- */
export async function deleteScrapItem(id) {
    // 1. Check if the item is linked to any pickup history
    const [usage] = await pool.query(
        `SELECT COUNT(*) as count FROM pickup_items WHERE item_id = ?`,
        [id]
    );

    if (usage[0].count > 0) {
        // 2. Perform a SOFT DELETE (Hide from app, keep for historical records)
        const [result] = await pool.query(
            `UPDATE scrap_items SET is_active = 0 WHERE id = ?`,
            [id]
        )
        return { success: true, type: 'soft', affectedRows: result.affectedRows };
    } else {
        // 3. Perform a HARD DELETE (Safe to remove as it has no history)
        const [result] = await pool.query(
            `DELETE FROM scrap_items WHERE id = ?`,
            [id]
        );
        return { success: true, type: 'hard', affectedRows: result.affectedRows };
    }
}