import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { validationResult } from 'express-validator';
import nodemailer from 'nodemailer';
import ApiError from '../utils/ApiError.js';
import db from '../config/db.js';
import { awardReferralBonus } from './pointController.js'; // Import the helper we created

// Temporary store for OTPs and registration data
const otpStore = new Map();

/* -----------------------------------------------------
    HELPER: SEND EMAIL OTP
----------------------------------------------------- */
const sendEmailOTP = async (email, otp) => {
  const transporter = nodemailer.createTransport({
    host: process.env.MAIL_HOST,
    port: parseInt(process.env.MAIL_PORT),
    secure: process.env.MAIL_SECURE === 'true',
    auth: {
      user: process.env.MAIL_USER,
      pass: process.env.MAIL_PASS,
    },
  });

  await transporter.sendMail({
    from: `"GreenScrapHub Support" <${process.env.MAIL_USER}>`,
    to: email,
    subject: "Verification Code - GreenScrapHub",
    html: `
            <div style="font-family: sans-serif; padding: 20px; border: 1px solid #eee; border-radius: 10px;">
                <h2 style="color: #10B981;">GreenScrapHub Verification</h2>
                <p>Use the code below to verify your account. Valid for 5 minutes.</p>
                <div style="background: #f4f4f4; padding: 20px; text-align: center; border-radius: 10px;">
                    <h1 style="letter-spacing: 5px; color: #10B981; font-size: 40px;">${otp}</h1>
                </div>
            </div>
        `,
  });
};

/* -----------------------------------------------------
    CUSTOMER SELF-REGISTRATION (STEP 1: OTP REQUEST)
----------------------------------------------------- */
export const registerRequest = async (req, res, next) => {
  try {
    const { phone, email, full_name, password, referral_code } = req.body;

    const [exists] = await db.query("SELECT id FROM users WHERE phone = ? OR (email IS NOT NULL AND email = ?)", [phone, email]);
    if (exists.length > 0) return next(new ApiError(400, 'Phone or Email already registered'));

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    otpStore.set(phone, { ...req.body, otp, expires: Date.now() + 300000 });

    if (email) await sendEmailOTP(email, otp);
    console.log(`[AUTH] OTP for ${phone}: ${otp}`);

    res.json({ success: true, message: "Verification code sent to your email/phone." });
  } catch (err) {
    next(err);
  }
};

/* -----------------------------------------------------
    CUSTOMER SELF-REGISTRATION (STEP 2: VERIFY & CREATE)
----------------------------------------------------- */
export const verifyAndRegister = async (req, res, next) => {
  const conn = await db.getConnection();
  try {
    const { phone, otp } = req.body;
    const data = otpStore.get(phone);

    if (!data || data.otp !== otp || Date.now() > data.expires) {
      return next(new ApiError(400, "Invalid or expired OTP"));
    }

    await conn.beginTransaction();

    const password_hash = await bcrypt.hash(data.password, 10);

    // 1. Create Base User (Role 4 = Customer)
    const [u] = await conn.query(
      "INSERT INTO users (full_name, phone, email, password_hash, role_id) VALUES (?, ?, ?, ?, 4)",
      [data.full_name, data.phone, data.email || null, password_hash]
    );
    const userId = u.insertId;

    // 2. Resolve Referrer (Check if referral_code exists)
    let referredByCustomerId = null;
    if (data.referral_code) {
      const [ref] = await conn.query("SELECT id FROM customers WHERE referral_code = ?", [data.referral_code]);
      if (ref.length > 0) {
        referredByCustomerId = ref[0].id;
        // AWARD BONUS TO REFERRER
        await awardReferralBonus(referredByCustomerId, conn);
      }
    }

    // 3. Setup Customer Profile (GS + 5 random chars)
    const refCode = 'GS' + Math.random().toString(36).substring(2, 7).toUpperCase();
    await conn.query(
      "INSERT INTO customers (user_id, referral_code, referred_by, total_points) VALUES (?, ?, ?, 20)",
      [userId, refCode, referredByCustomerId]
    );

    // 4. Initialize Wallet
    await conn.query("INSERT INTO wallet_accounts (user_id, balance) VALUES (?, 0)", [userId]);

    await conn.commit();
    otpStore.delete(phone);

    const token = jwt.sign({ id: userId, role: 'customer' }, process.env.JWT_SECRET, { expiresIn: '7d' });
    res.status(201).json({
      success: true,
      message: "Registration successful!",
      data: { token, role: 'customer', user_id: userId }
    });
  } catch (err) {
    await conn.rollback();
    next(err);
  } finally {
    conn.release();
  }
};

/* -----------------------------------------------------
    STAFF ONBOARDING (Admin Creates Agent / Agent Creates Rider)
----------------------------------------------------- */
export const onboardStaff = async (req, res, next) => {
  const conn = await db.getConnection();
  try {
    const { full_name, phone, email, password, role_name, agent_id } = req.body;
    const creatorRole = req.user.role;

    // Security check
    if (role_name === 'agent' && creatorRole !== 'admin') {
      return next(new ApiError(403, "Only Admins can onboard new Agents"));
    }

    await conn.beginTransaction();

    const [roles] = await conn.query("SELECT id FROM roles WHERE name = ?", [role_name]);
    if (!roles.length) throw new Error("Invalid role specified");
    const roleId = roles[0].id;

    const password_hash = await bcrypt.hash(password, 10);
    const [u] = await conn.query(
      "INSERT INTO users (full_name, phone, email, password_hash, role_id, agent_id) VALUES (?, ?, ?, ?, ?, ?)",
      [full_name, phone, email || null, password_hash, roleId, agent_id || null]
    );
    const userId = u.insertId;

    // Profile Creation
    if (role_name === 'rider') {
      await conn.query(
        "INSERT INTO riders (user_id, agent_id, vehicle_type) VALUES (?, ?, ?)",
        [userId, agent_id || null, req.body.vehicle_type || 'Bicycle']
      );
    } else if (role_name === 'agent') {
      const agentCode = 'AG' + Math.random().toString(36).substring(2, 6).toUpperCase();
      await conn.query(
        "INSERT INTO agents (owner_user_id, name, code) VALUES (?, ?, ?)",
        [userId, full_name, agentCode]
      );
    }

    // Initialize Wallet for earnings
    await conn.query("INSERT INTO wallet_accounts (user_id, balance) VALUES (?, 0)", [userId]);

    await conn.commit();
    res.status(201).json({ success: true, message: `${role_name} onboarded successfully.` });
  } catch (err) {
    await conn.rollback();
    next(err);
  } finally {
    conn.release();
  }
};

/* -----------------------------------------------------
    HELPER: INITIALIZE CUSTOMER PROFILE
    (Used by both self-reg and admin-onboarding)
----------------------------------------------------- */
const createCustomerProfile = async (conn, userId, referralCodeInput) => {
  let referredByCustomerId = null;
  if (referralCodeInput) {
    const [ref] = await conn.query("SELECT id FROM customers WHERE referral_code = ?", [referralCodeInput]);
    if (ref.length > 0) {
      referredByCustomerId = ref[0].id;
      await awardReferralBonus(referredByCustomerId, conn);
    }
  }

  const newRefCode = 'GS' + Math.random().toString(36).substring(2, 7).toUpperCase();
  await conn.query(
    "INSERT INTO customers (user_id, referral_code, referred_by, total_points) VALUES (?, ?, ?, 20)",
    [userId, newRefCode, referredByCustomerId]
  );
};

/* -----------------------------------------------------
    ADMIN → ONBOARD CUSTOMER (DIRECT)
----------------------------------------------------- */
export const onboardCustomer = async (req, res, next) => {
  const conn = await db.getConnection();
  try {
    const { full_name, phone, email, password, referral_code } = req.body;

    // 1. Check if user already exists
    const [exists] = await conn.query("SELECT id FROM users WHERE phone = ?", [phone]);
    if (exists.length > 0) return next(new ApiError(400, 'User with this phone already exists'));

    await conn.beginTransaction();

    // 2. Create User (Role 4 = Customer)
    const password_hash = await bcrypt.hash(password, 10);
    const [u] = await conn.query(
      "INSERT INTO users (full_name, phone, email, password_hash, role_id, is_active) VALUES (?, ?, ?, ?, 4, 1)",
      [full_name, phone, email || null, password_hash]
    );
    const userId = u.insertId;

    // 3. Setup Profile & Referral via helper
    await createCustomerProfile(conn, userId, referral_code);

    // 4. Initialize Wallet
    await conn.query("INSERT INTO wallet_accounts (user_id, balance) VALUES (?, 0)", [userId]);

    await conn.commit();
    res.status(201).json({
      success: true,
      message: "Customer onboarded successfully by Admin."
    });
  } catch (err) {
    await conn.rollback();
    next(err);
  } finally {
    conn.release();
  }
};
/* -----------------------------------------------------
    LOGIN
----------------------------------------------------- */
export const login = async (req, res, next) => {
  try {
    const { phone, password } = req.body;

    const [rows] = await db.query(`
            SELECT u.*, r.name as role_name 
            FROM users u 
            JOIN roles r ON u.role_id = r.id 
            WHERE u.phone = ? AND u.is_active = 1`, [phone]);

    const user = rows[0];
    if (!user || !(await bcrypt.compare(password, user.password_hash))) {
      return next(new ApiError(401, 'Invalid phone number or password'));
    }

    const role = user.role_name.toLowerCase();
    const token = jwt.sign({ id: user.id, role }, process.env.JWT_SECRET, { expiresIn: '7d' });

    res.json({
      success: true,
      data: {
        token,
        user: { id: user.id, full_name: user.full_name, role, phone: user.phone }
      }
    });
  } catch (err) {
    next(err);
  }
};

/* -----------------------------------------------------
    GET ME (Comprehensive Profile)
----------------------------------------------------- */
export const getMe = async (req, res, next) => {
  try {
    const [rows] = await db.query(`
            SELECT 
                u.id, 
                u.full_name, 
                u.phone, 
                u.email, 
                r.name as role,
                c.referral_code, 
                c.total_points,
                rd.is_online, 
                rd.vehicle_number,
                -- Use COALESCE to fallback to u.full_name if ag.business_name is null
                COALESCE(ag.business_name, u.full_name) as business_name, 
                ag.code as agent_code,
                w.balance as wallet_balance
            FROM users u
            JOIN roles r ON u.role_id = r.id
            LEFT JOIN customers c ON u.id = c.user_id
            LEFT JOIN riders rd ON u.id = rd.user_id
            LEFT JOIN agents ag ON u.id = ag.owner_user_id
            LEFT JOIN wallet_accounts w ON u.id = w.user_id
            WHERE u.id = ?`, [req.user.id]);

    if (!rows.length) return next(new ApiError(404, 'User not found'));
    res.json({ success: true, data: rows[0] });
  } catch (err) {
    next(err);
  }
};

/* -----------------------------------------------------
    STEP 1: FORGOT PASSWORD REQUEST (OTP SEND)
----------------------------------------------------- */
export const forgotPasswordRequest = async (req, res, next) => {
  try {
    const { phone } = req.body;

    const [rows] = await db.query('SELECT email, full_name FROM users WHERE phone = ?', [phone]);
    const user = rows[0];

    if (!user) return next(new ApiError(404, 'No account found with this phone number'));
    if (!user.email) return next(new ApiError(400, 'No email linked to this account. Please contact support.'));

    const otp = Math.floor(100000 + Math.random() * 900000).toString();

    otpStore.set(`reset_${phone}`, {
      phone,
      otp,
      expires: Date.now() + 300000 // 5 Minutes
    });

    await sendEmailOTP(user.email, otp);

    console.log(`[RESET] OTP for ${phone} is: ${otp}`);

    res.status(200).json({
      success: true,
      message: "Password reset code sent to your registered email."
    });
  } catch (err) {
    next(new ApiError(500, "Failed to send reset code."));
  }
};

/* -----------------------------------------------------
    STEP 2: VERIFY OTP & RESET PASSWORD
----------------------------------------------------- */
export const resetPassword = async (req, res, next) => {
  try {
    const { phone, otp, new_password } = req.body;
    const data = otpStore.get(`reset_${phone}`);

    if (!data || data.otp !== otp || Date.now() > data.expires) {
      return next(new ApiError(400, "Invalid or expired reset code"));
    }

    const password_hash = await bcrypt.hash(new_password, 10);

    await db.query('UPDATE users SET password_hash = ? WHERE phone = ?', [password_hash, phone]);

    otpStore.delete(`reset_${phone}`);

    res.status(200).json({
      success: true,
      message: "Password updated successfully. You can now login."
    });
  } catch (err) {
    next(new ApiError(500, "Failed to reset password."));
  }
};

/* -----------------------------------------------------
    UPDATE PROFILE (Multi-Role Support)
----------------------------------------------------- */
export const updateProfile = async (req, res, next) => {
  const conn = await db.getConnection();
  try {
    const userId = req.user.id; // From auth middleware
    const userRole = req.user.role; // From auth middleware (e.g., 'customer', 'rider')

    const {
      full_name,
      email,
      // Customer specific
      default_address_id,
      // Rider specific
      vehicle_type,
      vehicle_number,
      emergency_contact,
      is_online,
    } = req.body;

    await conn.beginTransaction();

    // 1. Update Base User Information
    // Note: We don't usually allow phone updates here to prevent bypass of OTP verification
    const [userUpdate] = await conn.query(
      `UPDATE users SET 
        full_name = COALESCE(?, full_name), 
        email = COALESCE(?, email),
        updated_at = CURRENT_TIMESTAMP
       WHERE id = ?`,
      [full_name, email, userId]
    );

    // 2. Role-Based Profile Update
    if (userRole === 'customer') {
      await conn.query(
        `UPDATE customers SET 
          default_address_id = COALESCE(?, default_address_id),
          updated_at = CURRENT_TIMESTAMP
         WHERE user_id = ?`,
        [default_address_id, userId]
      );
    }
    else if (userRole === 'rider') {
      await conn.query(
        `UPDATE riders SET 
          vehicle_type = COALESCE(?, vehicle_type),
          vehicle_number = COALESCE(?, vehicle_number),
          emergency_contact = COALESCE(?, emergency_contact),
          is_online = COALESCE(?, is_online),
          updated_at = CURRENT_TIMESTAMP
         WHERE user_id = ?`,
        [vehicle_type, vehicle_number, emergency_contact, is_online, userId]
      );
    }

    await conn.commit();

    // 3. Fetch fresh data to return
    const [updatedRows] = await db.query(`
        SELECT u.id, u.full_name, u.phone, u.email, r.name as role
        FROM users u
        INNER JOIN roles r ON u.role_id = r.id
        WHERE u.id = ?`,
      [userId]
    );

    res.status(200).json({
      success: true,
      message: "Profile updated successfully",
      data: updatedRows[0]
    });

  } catch (err) {
    await conn.rollback();
    console.error("Update Profile Error:", err);
    next(new ApiError(500, "Failed to update profile."));
  } finally {
    conn.release();
  }
};

/* -----------------------------------------------------
    CHANGE PASSWORD (Separate for Security)
----------------------------------------------------- */
export const changePassword = async (req, res, next) => {
  try {
    const { currentPassword, newPassword } = req.body;
    const userId = req.user.id;

    // Fetch user hash
    const [users] = await db.query("SELECT password_hash FROM users WHERE id = ?", [userId]);
    if (!users.length) return next(new ApiError(404, "User not found"));

    // Verify current
    const isMatch = await bcrypt.compare(currentPassword, users[0].password_hash);
    if (!isMatch) return next(new ApiError(401, "Current password is incorrect"));

    // Hash new
    const password_hash = await bcrypt.hash(newPassword, 10);
    await db.query("UPDATE users SET password_hash = ? WHERE id = ?", [password_hash, userId]);

    res.status(200).json({
      success: true,
      message: "Password changed successfully."
    });
  } catch (err) {
    next(err);
  }
};