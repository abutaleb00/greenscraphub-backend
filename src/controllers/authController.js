import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { validationResult } from 'express-validator';
import nodemailer from 'nodemailer';
import ApiError from '../utils/ApiError.js';
import db from '../config/db.js';
import { awardReferralBonus } from './pointController.js';
import axios from 'axios';
import useragent from 'useragent';
import requestIp from 'request-ip';
// Temporary store for OTPs and registration data
const otpStore = new Map();

const logActivity = async (req, userId, action, metadata = {}) => {
  try {
    const agent = useragent.parse(req.headers['user-agent']);

    // Improved IP detection
    let ip = requestIp.getClientIp(req);

    // If you are behind a proxy (like Nginx), request-ip usually handles it, 
    // but we can force a clean-up if it returns a list or IPv6 prefix
    if (ip && ip.startsWith('::ffff:')) {
      ip = ip.replace('::ffff:', '');
    }

    const platform = req.headers['x-platform'] || (req.headers['user-agent'].includes('Postman') ? 'API' : 'WEB');

    const query = `
        INSERT INTO activity_logs 
        (user_id, action, platform, browser, os, device, ip_address, metadata, created_at) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())
    `;

    const values = [
      userId,
      action,
      platform,
      agent.toAgent(),
      agent.os.toString(),
      agent.device.toString(),
      ip === '::1' ? '127.0.0.1' : ip, // Normalize localhost
      JSON.stringify(metadata)
    ];

    await db.query(query, values);
  } catch (error) {
    console.error("[Activity Log Error]", error.message);
  }
};
/* -----------------------------------------------------
    HELPER: SEND SMS OTP (sms.net.bd)
----------------------------------------------------- */
const sendSMS = async (phone, otp) => {
  try {
    let formattedPhone = phone.trim();
    if (formattedPhone.startsWith('0')) {
      formattedPhone = '88' + formattedPhone;
    }

    const apiKey = process.env.SMS_API_KEY;
    const message = `Your Smart Scrap BD verification code is: ${otp}. Valid for 5 minutes.`;

    const response = await axios.post('https://api.sms.net.bd/sendsms', {
      api_key: apiKey,
      msg: message,
      to: formattedPhone
    }, {
      headers: { 'Content-Type': 'multipart/form-data' }
    });

    if (response.data.error === 0) {
      return true;
    } else {
      console.error(`[SMS Error] API returned: ${response.data.msg}`);
      return false;
    }
  } catch (error) {
    console.error(`[SMS Critical Error] ${error.message}`);
    return false;
  }
};

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
    from: `"Smart Scrap BD Support" <${process.env.MAIL_USER}>`,
    to: email,
    subject: "Verification Code - Smart Scrap BD",
    html: `
        <div style="font-family: sans-serif; padding: 20px; border: 1px solid #eee; border-radius: 10px;">
            <h2 style="color: #10B981;">Smart Scrap BD Verification</h2>
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

    const [exists] = await db.query(
      "SELECT id FROM users WHERE phone = ? OR (email IS NOT NULL AND email = ?)",
      [phone, email]
    );
    if (exists.length > 0) return next(new ApiError(400, 'Phone or Email already registered'));

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    otpStore.set(phone, { ...req.body, otp, expires: Date.now() + 300000 });

    const smsSent = await sendSMS(phone, otp);

    if (email && !email.includes('example.com')) {
      await sendEmailOTP(email, otp);
    }

    res.json({
      success: true,
      message: "Verification code sent to your phone and email."
    });
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

    // 🔥 1. Fetch Dynamic Reward Settings
    const [settingsRows] = await conn.query("SELECT * FROM app_settings WHERE id = 1");
    const settings = settingsRows[0] || { signup_bonus_points: 20, referral_bonus_points: 50 };

    const password_hash = await bcrypt.hash(data.password, 10);

    // 2. Create User
    const [u] = await conn.query(
      "INSERT INTO users (full_name, phone, email, password_hash, role_id) VALUES (?, ?, ?, ?, 4)",
      [data.full_name, data.phone, data.email || null, password_hash]
    );
    const userId = u.insertId;

    // 3. Handle Referral Points
    let referredByCustomerId = null;
    if (data.referral_code) {
      const [ref] = await conn.query("SELECT id FROM customers WHERE referral_code = ?", [data.referral_code]);
      if (ref.length > 0) {
        referredByCustomerId = ref[0].id;

        // Award dynamic referral bonus to the Referrer
        await conn.query(
          "UPDATE customers SET total_points = total_points + ? WHERE id = ?",
          [settings.referral_bonus_points, referredByCustomerId]
        );

        await conn.query(
          "INSERT INTO point_transactions (customer_id, amount, type, description) VALUES (?, ?, 'referral_bonus', ?)",
          [referredByCustomerId, settings.referral_bonus_points, `Referral bonus for inviting ${data.full_name}`]
        );
      }
    }

    // 4. Create Customer Profile with Dynamic Signup Bonus
    const refCode = 'GS' + Math.random().toString(36).substring(2, 7).toUpperCase();
    await conn.query(
      "INSERT INTO customers (user_id, referral_code, referred_by, total_points) VALUES (?, ?, ?, ?)",
      [userId, refCode, referredByCustomerId, settings.signup_bonus_points]
    );

    // Log the signup bonus in history
    await conn.query(
      "INSERT INTO point_transactions (customer_id, amount, type, description) VALUES ((SELECT id FROM customers WHERE user_id = ?), ?, 'earn', 'Welcome Signup Bonus')",
      [userId, settings.signup_bonus_points]
    );

    await conn.query("INSERT INTO wallet_accounts (user_id, balance) VALUES (?, 0)", [userId]);

    await conn.commit();
    otpStore.delete(phone);

    // LOG ACTIVITY: SIGNUP
    await logActivity(req, userId, 'SIGNUP', { method: 'Self-Registration' });

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
  // 🔥 Fetch Dynamic Settings
  const [settingsRows] = await conn.query("SELECT * FROM app_settings WHERE id = 1");
  const settings = settingsRows[0] || { signup_bonus_points: 20, referral_bonus_points: 50 };

  let referredByCustomerId = null;
  if (referralCodeInput) {
    const [ref] = await conn.query("SELECT id FROM customers WHERE referral_code = ?", [referralCodeInput]);
    if (ref.length > 0) {
      referredByCustomerId = ref[0].id;

      // Dynamic referral bonus for the referrer
      await conn.query(
        "UPDATE customers SET total_points = total_points + ? WHERE id = ?",
        [settings.referral_bonus_points, referredByCustomerId]
      );

      await conn.query(
        "INSERT INTO point_transactions (customer_id, amount, type, description) VALUES (?, ?, 'referral_bonus', 'Referral bonus for inviting a new member')",
        [referredByCustomerId, settings.referral_bonus_points]
      );
    }
  }

  const newRefCode = 'GS' + Math.random().toString(36).substring(2, 7).toUpperCase();

  // Create profile with dynamic signup points
  await conn.query(
    "INSERT INTO customers (user_id, referral_code, referred_by, total_points) VALUES (?, ?, ?, ?)",
    [userId, newRefCode, referredByCustomerId, settings.signup_bonus_points]
  );

  // Log Signup bonus history for user
  await conn.query(
    "INSERT INTO point_transactions (customer_id, amount, type, description) VALUES ((SELECT id FROM customers WHERE user_id = ?), ?, 'earn', 'Admin Onboarding Welcome Bonus')",
    [userId, settings.signup_bonus_points]
  );
};

/* -----------------------------------------------------
    ADMIN → ONBOARD CUSTOMER (DIRECT)
----------------------------------------------------- */
export const onboardCustomer = async (req, res, next) => {
  const conn = await db.getConnection();
  try {
    const {
      full_name, phone, email, password, referral_code,
      address_line, division_id, district_id, upazila_id,
      is_active, latitude, longitude
    } = req.body;

    // 1. Check if user already exists
    const [exists] = await conn.query("SELECT id FROM users WHERE phone = ?", [phone]);
    if (exists.length > 0) return next(new ApiError(400, 'User with this phone already exists'));

    await conn.beginTransaction();

    // 2. Create User (Role 4 = Customer)
    const password_hash = await bcrypt.hash(password, 10);
    const [u] = await conn.query(
      "INSERT INTO users (full_name, phone, email, password_hash, role_id, is_active) VALUES (?, ?, ?, ?, 4, ?)",
      [full_name, phone, email || null, password_hash, is_active || 1]
    );
    const userId = u.insertId;

    // 3. Add Address Details WITH Lat/Long
    // Ensure your 'addresses' table has latitude and longitude columns (DECIMAL 10,8 and 11,8)
    await conn.query(
      `INSERT INTO addresses (
        user_id, address_line, division_id, district_id, upazila_id, 
        latitude, longitude, is_default
      ) VALUES (?, ?, ?, ?, ?, ?, ?, 1)`,
      [
        userId,
        address_line,
        division_id,
        district_id,
        upazila_id,
        latitude || null,
        longitude || null
      ]
    );

    // 4. Setup Profile & Referral via helper
    await createCustomerProfile(conn, userId, referral_code);

    // 5. Initialize Wallet
    await conn.query("INSERT INTO wallet_accounts (user_id, balance) VALUES (?, 0)", [userId]);

    await conn.commit();
    res.status(201).json({
      success: true,
      message: "Customer identity node deployed with precise geo-coordinates."
    });
  } catch (err) {
    await conn.rollback();
    next(err);
  } finally {
    conn.release();
  }
};
/* -----------------------------------------------------
    LOGIN (Updated to include email)
----------------------------------------------------- */
export const login = async (req, res, next) => {
  try {
    const { phone, password } = req.body;

    const [rows] = await db.query(`
            SELECT u.id, u.full_name, u.phone, u.email, u.password_hash, u.is_active, r.name as role_name 
            FROM users u 
            JOIN roles r ON u.role_id = r.id 
            WHERE u.phone = ? AND u.is_active = 1`, [phone]);

    const user = rows[0];

    if (!user || !(await bcrypt.compare(password, user.password_hash))) {
      return next(new ApiError(401, 'Invalid phone number or password'));
    }

    const role = user.role_name.toLowerCase();
    const token = jwt.sign({ id: user.id, role }, process.env.JWT_SECRET, { expiresIn: '7d' });

    // LOG ACTIVITY: LOGIN
    await logActivity(req, user.id, 'LOGIN', { status: 'success' });

    res.json({
      success: true,
      data: {
        token,
        user: {
          id: user.id,
          full_name: user.full_name,
          role,
          phone: user.phone,
          email: user.email
        }
      }
    });
  } catch (err) {
    next(err);
  }
};

/* -----------------------------------------------------
    UPDATE FCM TOKEN (Firebase Push Notifications)
----------------------------------------------------- */
export const updateFcmToken = async (req, res, next) => {
  try {
    const { token } = req.body;
    const userId = req.user.id;
    if (!token) return next(new ApiError(400, "FCM Token is required"));

    await db.query("UPDATE users SET fcm_token = ?, updated_at = NOW() WHERE id = ?", [token, userId]);
    res.json({ success: true, message: "Push notification token synchronized." });
  } catch (err) {
    next(err);
  }
};

/* -----------------------------------------------------
    GET ME (Comprehensive Profile with App Config)
----------------------------------------------------- */
export const getMe = async (req, res, next) => {
  try {
    // 1. Fetch User Profile Data
    const [rows] = await db.query(`
            SELECT 
                u.id, u.full_name, u.phone, u.email, u.profile_image, 
                r.name as role, c.referral_code, c.total_points,
                rd.is_online, rd.vehicle_number,
                COALESCE(ag.business_name, u.full_name) as business_name, 
                ag.code as agent_code, w.balance as wallet_balance
            FROM users u
            JOIN roles r ON u.role_id = r.id
            LEFT JOIN customers c ON u.id = c.user_id
            LEFT JOIN riders rd ON u.id = rd.user_id
            LEFT JOIN agents ag ON u.id = ag.owner_user_id
            LEFT JOIN wallet_accounts w ON u.id = w.user_id
            WHERE u.id = ?`, [req.user.id]);

    if (!rows.length) return next(new ApiError(404, 'User not found'));

    const user = rows[0];

    // 2. Handle Profile Image URL
    if (user.profile_image) {
      const baseUrl = process.env.BASE_URL || `${req.protocol}://${req.get('host')}`;
      user.profile_image = user.profile_image.startsWith('http')
        ? user.profile_image
        : `${baseUrl}${user.profile_image}`;
    }

    /**
     * 3. 🔥 NEW: FETCH GLOBAL APP SETTINGS
     * This allows the app to show dynamic reward values and rates
     */
    const [settingsRows] = await db.query(`
        SELECT 
            signup_bonus_points, 
            referral_bonus_points, 
            point_to_cash_rate, 
            min_redeem_points,
            min_withdrawal_amount
        FROM app_settings 
        WHERE id = 1
    `);

    // Combine user data with app configuration
    res.json({
      success: true,
      data: user,
      app_config: settingsRows[0] || {
        signup_bonus_points: 100,
        referral_bonus_points: 50,
        point_to_cash_rate: 0.10,
        min_redeem_points: 100
      }
    });

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
    if (!phone) return next(new ApiError(400, 'Phone number is required'));

    const [rows] = await db.query(
      'SELECT id, email, full_name FROM users WHERE phone = ? LIMIT 1',
      [phone]
    );
    const user = rows[0];

    if (!user) {
      return next(new ApiError(404, 'No account found with this phone number'));
    }

    const otp = Math.floor(100000 + Math.random() * 900000).toString();

    otpStore.set(`reset_${phone}`, {
      phone,
      otp,
      expires: Date.now() + 300000
    });

    await sendSMS(phone, otp);

    if (user.email && !user.email.includes('example.com')) {
      try {
        await sendEmailOTP(user.email, otp);
      } catch (e) { console.error("Mail failed during reset", e.message); }
    }

    // LOG ACTIVITY: PASSWORD RESET REQUESTED
    await logActivity(req, user.id, 'PASSWORD_RESET_REQUEST');

    res.status(200).json({
      success: true,
      message: "A verification code has been sent to your registered phone."
    });
  } catch (err) {
    next(new ApiError(500, "An internal server error occurred."));
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

    const [user] = await db.query('SELECT id FROM users WHERE phone = ?', [phone]);
    await db.query('UPDATE users SET password_hash = ? WHERE phone = ?', [password_hash, phone]);

    otpStore.delete(`reset_${phone}`);

    // LOG ACTIVITY: PASSWORD RESET COMPLETED
    if (user.length > 0) {
      await logActivity(req, user[0].id, 'PASSWORD_RESET_SUCCESS');
    }

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
    const userId = req.user.id;
    const userRole = req.user.role;
    const { full_name, email, default_address_id, vehicle_type, vehicle_number, emergency_contact, is_online } = req.body;

    const profile_image = req.file ? `/uploads/profiles/${req.file.filename}` : null;

    await conn.beginTransaction();

    await conn.query(
      `UPDATE users SET 
        full_name = COALESCE(?, full_name), 
        email = COALESCE(?, email),
        profile_image = COALESCE(?, profile_image),
        updated_at = CURRENT_TIMESTAMP
       WHERE id = ?`,
      [full_name, email, profile_image, userId]
    );

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

    // LOG ACTIVITY: PROFILE_UPDATE
    await logActivity(req, userId, 'PROFILE_UPDATE');

    const [updatedRows] = await db.query(`
        SELECT u.id, u.full_name, u.phone, u.email, u.profile_image, r.name as role
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
    next(err);
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

    const [users] = await db.query("SELECT password_hash FROM users WHERE id = ?", [userId]);
    if (!users.length) return next(new ApiError(404, "User not found"));

    const isMatch = await bcrypt.compare(currentPassword, users[0].password_hash);
    if (!isMatch) return next(new ApiError(401, "Current password is incorrect"));

    const password_hash = await bcrypt.hash(newPassword, 10);
    await db.query("UPDATE users SET password_hash = ? WHERE id = ?", [password_hash, userId]);

    // LOG ACTIVITY: SECURITY_PASSWORD_CHANGE
    await logActivity(req, userId, 'PASSWORD_CHANGE');

    res.status(200).json({
      success: true,
      message: "Password changed successfully."
    });
  } catch (err) {
    next(err);
  }
};

export const logout = async (req, res, next) => {
  try {
    await logActivity(req, req.user.id, 'LOGOUT');
    res.json({ success: true, message: "Logged out from session." });
  } catch (err) {
    next(err);
  }
};