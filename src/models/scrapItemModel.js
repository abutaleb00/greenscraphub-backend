import pool from "../config/db.js";

/* ----------------------------------------------------
   CREATE ITEM
---------------------------------------------------- */
export async function createScrapItem({
    category_id,
    name,
    description = null,
    unit = "kg",
    min_price_per_unit,
    max_price_per_unit,
    image_url = null,
}) {
    const [result] = await pool.query(
        `
    INSERT INTO scrap_items (
      category_id,
      name,
      description,
      unit,
      min_price_per_unit,
      max_price_per_unit,
      image_url
    )
    VALUES (?, ?, ?, ?, ?, ?, ?)
    `,
        [
            category_id,
            name,
            description,
            unit,
            min_price_per_unit,
            max_price_per_unit,
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
          i.id,
          i.category_id,
          i.name,
          i.slug,
          i.description,
          i.unit,
          i.min_price_per_unit,
          i.max_price_per_unit,
          i.image_url,
          i.is_active,
          i.created_at,
          i.updated_at
        FROM scrap_items i
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
      i.id,
      i.category_id,
      i.name,
      i.description,
      i.unit,
      i.min_price_per_unit,
      i.max_price_per_unit,
      i.image_url,
      i.is_active,
      i.created_at,
      i.updated_at,
      c.name AS category_name
    FROM scrap_items i
    JOIN scrap_categories c ON i.category_id = c.id
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
      name,
      description,
      unit,
      min_price_per_unit,
      max_price_per_unit,
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

    query += ` ORDER BY name ASC`;

    const [rows] = await pool.query(query, params);
    return rows;
}

/* ----------------------------------------------------
   LIST ALL ITEMS (ADMIN)
---------------------------------------------------- */
export async function getAllScrapItems({ includeInactive = false } = {}) {
    let query = `
    SELECT 
      i.id,
      i.category_id,
      i.name,
      i.description,
      i.unit,
      i.min_price_per_unit,
      i.max_price_per_unit,
      i.image_url,
      i.is_active,
      i.created_at,
      i.updated_at,
      c.name AS category_name
    FROM scrap_items i
    JOIN scrap_categories c ON i.category_id = c.id
  `;

    if (!includeInactive) {
        query += ` WHERE i.is_active = 1`;
    }

    query += `
    ORDER BY c.name ASC, i.name ASC
  `;

    const [rows] = await pool.query(query);
    return rows;
}

/* ----------------------------------------------------
   UPDATE ITEM
---------------------------------------------------- */
export async function updateScrapItem(id, data) {
    const fields = [];
    const values = [];

    for (const [key, value] of Object.entries(data)) {
        if (value !== undefined) {
            fields.push(`${key} = ?`);
            values.push(value);
        }
    }

    if (!fields.length) return false;

    values.push(id);

    await pool.query(
        `
    UPDATE scrap_items
    SET ${fields.join(", ")}
    WHERE id = ?
    `,
        values
    );

    return await getScrapItemById(id);
}

/* ----------------------------------------------------
   SOFT DELETE ITEM
---------------------------------------------------- */
export async function softDeleteScrapItem(id) {
    await pool.query(
        `
    UPDATE scrap_items
    SET is_active = 0
    WHERE id = ?
    `,
        [id]
    );

    return true;
}
