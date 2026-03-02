import pool from "../config/db.js";

/* ----------------------------------------------------
   CREATE ITEM
---------------------------------------------------- */
export async function createScrapItem({
    category_id,
    name,
    slug,
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
      slug,
      description,
      unit,
      min_price_per_unit,
      max_price_per_unit,
      image_url
    )
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `,
        [
            category_id,
            name,
            slug,
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
      i.slug,
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
      name,
      slug,
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
      i.slug,
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
    LEFT JOIN scrap_categories c ON i.category_id = c.id
  `;

    if (!includeInactive) {
        query += ` WHERE i.is_active = 1`;
    }

    query += ` ORDER BY c.name ASC, i.name ASC`;

    const [rows] = await pool.query(query);
    return rows;
}

/* ----------------------------------------------------
   UPDATE ITEM (Defensive Dynamic Update)
---------------------------------------------------- */
export async function updateScrapItem(id, data) {
    const fields = [];
    const values = [];

    const allowedUpdates = [
        'category_id', 'name', 'slug', 'description',
        'unit', 'min_price_per_unit', 'max_price_per_unit',
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
   - Performs HARD DELETE if no references exist.
   - Performs SOFT DELETE if linked to pickup history.
---------------------------------------------------- */
export async function deleteScrapItem(id) {
    // 1. Check if the item is linked to any pickup_items
    const [usage] = await pool.query(
        `SELECT COUNT(*) as count FROM pickup_items WHERE scrap_item_id = ?`,
        [id]
    );

    if (usage[0].count > 0) {
        // 2. Perform a SOFT DELETE (Hide from app, keep for history)
        const [result] = await pool.query(
            `UPDATE scrap_items SET is_active = 0 WHERE id = ?`,
            [id]
        )
        // Return structured data for the controller
        return { success: true, type: 'soft', affectedRows: result.affectedRows };
    } else {
        // 3. Perform a HARD DELETE (Safe to remove)
        const [result] = await pool.query(
            `DELETE FROM scrap_items WHERE id = ?`,
            [id]
        );
        return { success: true, type: 'hard', affectedRows: result.affectedRows };
    }
}

/* ----------------------------------------------------
   SOFT DELETE ITEM (Direct helper if needed)
---------------------------------------------------- */
export async function softDeleteScrapItem(id) {
    const [result] = await pool.query(
        `UPDATE scrap_items SET is_active = 0 WHERE id = ?`,
        [id]
    );
    return result.affectedRows > 0;
}