import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { validationResult } from 'express-validator';
import nodemailer from 'nodemailer';
import ApiError from '../utils/ApiError.js';
import db from '../config/db.js';
import {
  findUserByEmail,
  findUserByPhone,
  findUserById
} from '../models/userModel.js';

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
            <div style="font-family: sans-serif; padding: 20px; color: #333; border: 1px solid #eee; border-radius: 10px;">
                <h2 style="color: #10B981;">Welcome to GreenScrapHub</h2>
                <p>Use the code below to verify your account. This code will expire in 5 minutes.</p>
                <div style="background: #f4f4f4; padding: 20px; text-align: center; border-radius: 10px;">
                    <h1 style="letter-spacing: 5px; color: #10B981; margin: 0; font-size: 40px;">${otp}</h1>
                </div>
                <p style="font-size: 12px; color: #777; margin-top: 20px;">If you did not request this, please ignore this email.</p>
            </div>
        `,
  });
};

/* -----------------------------------------------------
    STEP 1: REGISTRATION REQUEST (OTP SEND)
----------------------------------------------------- */
export const registerRequest = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return next(new ApiError(422, errors.array()[0].msg));

    const { full_name, phone, email, password, referral_code } = req.body;

    // Check availability
    if (await findUserByPhone(phone)) return next(new ApiError(400, 'Phone number already registered'));
    if (email && await findUserByEmail(email)) return next(new ApiError(400, 'Email address already registered'));

    // Generate 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();

    // Store the data temporarily in the map
    otpStore.set(phone, {
      full_name,
      phone,
      email,
      password,
      otp,
      referral_code: referral_code || null,
      expires: Date.now() + 300000 // 5 Minutes
    });

    if (email) {
      await sendEmailOTP(email, otp);
    }

    console.log(`[AUTH] OTP for ${phone} is: ${otp}`);

    res.status(200).json({
      success: true,
      message: "Verification code sent successfully."
    });
  } catch (err) {
    console.error("OTP Error:", err);
    next(new ApiError(500, "Failed to send verification code. Check server mail config."));
  }
};

/* -----------------------------------------------------
    STEP 2: VERIFY OTP & COMPLETE REGISTRATION
----------------------------------------------------- */
export const verifyAndRegister = async (req, res, next) => {
  const conn = await db.getConnection();
  try {
    const { phone, otp } = req.body;
    const data = otpStore.get(phone);

    if (!data || data.otp !== otp || Date.now() > data.expires) {
      return next(new ApiError(400, "Invalid or expired verification code"));
    }

    await conn.beginTransaction();

    const password_hash = await bcrypt.hash(data.password, 10);

    // 1. Create Base User Record (Ensure role is lowercase 'customer')
    const [userResult] = await conn.query(
      "INSERT INTO users (full_name, phone, email, password_hash, role) VALUES (?, ?, ?, ?, 'customer')",
      [data.full_name, data.phone, data.email, password_hash]
    );
    const userId = userResult.insertId;

    // 2. Generate Unique Referral Code
    const newUserCode = 'GS' + Math.random().toString(36).substring(2, 7).toUpperCase();

    // 3. Resolve Referrer
    let referredById = null;
    if (data.referral_code) {
      const [referrer] = await conn.query(
        "SELECT id FROM customers WHERE referral_code = ?",
        [data.referral_code]
      );
      if (referrer.length > 0) {
        referredById = referrer[0].id;
      }
    }

    // 4. Create Customer Profile
    await conn.query(
      "INSERT INTO customers (user_id, referral_code, referred_by, total_points) VALUES (?, ?, ?, ?)",
      [userId, newUserCode, referredById, 20]
    );

    // 5. Initialize Wallet
    await conn.query(
      "INSERT INTO wallet_accounts (user_id, user_type, balance) VALUES (?, 'customer', 0.00)",
      [userId]
    );

    await conn.commit();
    otpStore.delete(phone);

    // 6. Generate JWT with ROLE (Critical for fixing 403)
    const token = jwt.sign(
      { id: userId, role: 'customer', full_name: data.full_name },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.status(201).json({
      success: true,
      message: "Registration complete!",
      data: {
        token,
        user: {
          id: userId,
          full_name: data.full_name,
          phone: data.phone,
          email: data.email,
          role: 'customer',
          referral_code: newUserCode,
          total_points: 20
        }
      },
    });
  } catch (err) {
    await conn.rollback();
    console.error("Registration Finalization Error:", err);
    next(new ApiError(500, "Transaction failed during account creation."));
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

    const [rows] = await db.query('SELECT * FROM users WHERE phone = ?', [phone]);
    const user = rows[0];

    if (!user) return next(new ApiError(401, 'Invalid phone number or password'));

    const match = await bcrypt.compare(password, user.password_hash);
    if (!match) return next(new ApiError(401, 'Invalid phone number or password'));

    // Ensure role is correctly pulled and added to JWT (Critical for fixing 403)
    const userRole = user.role ? user.role.toLowerCase() : 'customer';

    const token = jwt.sign(
      { id: user.id, role: userRole, full_name: user.full_name },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    delete user.password_hash;

    res.json({
      success: true,
      message: "Login successful",
      data: { token, user: { ...user, role: userRole } }
    });
  } catch (err) {
    next(err);
  }
};

/* -----------------------------------------------------
    GET ME (Profile Information)
----------------------------------------------------- */
export const getMe = async (req, res, next) => {
  try {
    const [rows] = await db.query(`
            SELECT u.id, u.full_name, u.phone, u.email, u.role, u.created_at,
                   c.referral_code, c.total_points, c.id as customer_id
            FROM users u 
            LEFT JOIN customers c ON u.id = c.user_id 
            WHERE u.id = ?`, [req.user.id]);

    if (!rows.length) return next(new ApiError(404, 'User session invalid or user not found'));

    // Normalize role in response
    const userData = rows[0];
    userData.role = userData.role ? userData.role.toLowerCase() : 'customer';

    res.json({
      success: true,
      data: userData
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