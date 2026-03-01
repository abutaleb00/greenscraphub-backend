import pool from "../config/db.js";

/* -------------------------------------------------------
   FIND USER BY PHONE
------------------------------------------------------- */
export async function findUserByPhone(phone) {
  const [rows] = await pool.query(
    `
    SELECT 
      u.id,
      u.full_name,
      u.phone,
      u.email,
      u.password_hash,
      r.name AS role
    FROM users u
    LEFT JOIN roles r ON u.role_id = r.id
    WHERE u.phone = ?
    LIMIT 1
    `,
    [phone]
  );

  return rows[0] || null;
}

/* -------------------------------------------------------
   FIND USER BY EMAIL
------------------------------------------------------- */
export async function findUserByEmail(email) {
  const [rows] = await pool.query(
    `
    SELECT 
      u.id,
      u.full_name,
      u.phone,
      u.email,
      u.password_hash,
      r.name AS role
    FROM users u
    LEFT JOIN roles r ON u.role_id = r.id
    WHERE u.email = ?
    LIMIT 1
    `,
    [email]
  );

  return rows[0] || null;
}

/* -------------------------------------------------------
   FIND USER BY ID
------------------------------------------------------- */
export async function findUserById(id) {
  const [rows] = await pool.query(
    `
    SELECT 
      u.id,
      u.full_name,
      u.phone,
      u.email,
      u.password_hash,
      r.name AS role
    FROM users u
    LEFT JOIN roles r ON u.role_id = r.id
    WHERE u.id = ?
    LIMIT 1
    `,
    [id]
  );

  return rows[0] || null;
}

/* -------------------------------------------------------
   CREATE USER (role → role_id)
------------------------------------------------------- */
export async function createUser({ full_name, phone, email, password_hash, role }) {

  const [roleRow] = await pool.query(
    `SELECT id FROM roles WHERE name = ? LIMIT 1`,
    [role]
  );

  if (!roleRow.length) {
    throw new Error("Invalid role: " + role);
  }

  const role_id = roleRow[0].id;

  const [result] = await pool.query(
    `
    INSERT INTO users (full_name, phone, email, password_hash, role_id)
    VALUES (?, ?, ?, ?, ?)
    `,
    [full_name, phone, email, password_hash, role_id]
  );

  return {
    id: result.insertId,
    full_name,
    phone,
    email,
    role,
  };
}
