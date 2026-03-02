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

    // Store data temporarily
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
    next(new ApiError(500, "Failed to send verification code."));
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

    // 1. Create Base User Record 
    // Set role_id to 4 (Customer) as per your roles table
    const [userResult] = await conn.query(
      "INSERT INTO users (full_name, phone, email, password_hash, role_id, is_active) VALUES (?, ?, ?, ?, 4, 1)",
      [data.full_name, data.phone, data.email, password_hash]
    );
    const userId = userResult.insertId;

    // 2. Generate Unique Referral Code (Professional Format: GS + 5 Alphanumeric)
    const newUserCode = 'GS' + Math.random().toString(36).substring(2, 7).toUpperCase();

    // 3. Resolve Referrer (Check if the provided code belongs to an existing customer)
    let referredByCustomerId = null;
    if (data.referral_code) {
      const [referrerRows] = await conn.query(
        "SELECT id FROM customers WHERE referral_code = ?",
        [data.referral_code]
      );
      if (referrerRows.length > 0) {
        referredByCustomerId = referrerRows[0].id;
      }
    }

    // 4. Create Customer Profile with Welcome Points (20)
    const [customerResult] = await conn.query(
      "INSERT INTO customers (user_id, referral_code, referred_by, total_points) VALUES (?, ?, ?, ?)",
      [userId, newUserCode, referredByCustomerId, 20]
    );
    const customerId = customerResult.insertId;

    // 5. Initialize Wallet Account
    await conn.query(
      "INSERT INTO wallet_accounts (user_id, user_type, balance) VALUES (?, 'customer', 0.00)",
      [userId]
    );

    await conn.commit();
    otpStore.delete(phone);

    // 6. Generate JWT with explicit 'customer' string role for frontend middleware
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
          customer_id: customerId,
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

    // 1. Join users with roles to get the role name string
    const [rows] = await db.query(`
      SELECT u.*, r.name as role_name 
      FROM users u 
      INNER JOIN roles r ON u.role_id = r.id 
      WHERE u.phone = ?`,
      [phone]
    );

    const user = rows[0];

    // 2. Validate user existence
    if (!user) {
      return next(new ApiError(401, 'Invalid phone number or password'));
    }

    // 3. Validate password
    const match = await bcrypt.compare(password, user.password_hash);
    if (!match) {
      return next(new ApiError(401, 'Invalid phone number or password'));
    }

    // 4. Normalize the role name (Critical for fixing 403 errors)
    // This ensures the token contains 'customer', 'rider', etc.
    const userRole = user.role_name ? user.role_name.toLowerCase() : 'customer';

    // 5. Generate JWT with the correct role string
    const token = jwt.sign(
      {
        id: user.id,
        role: userRole,
        full_name: user.full_name
      },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    // 6. Cleanup sensitive data
    delete user.password_hash;
    delete user.role_name; // Remove the temporary alias

    res.json({
      success: true,
      message: "Login successful",
      data: {
        token,
        user: {
          ...user,
          role: userRole // Pass the string role to the frontend
        }
      }
    });
  } catch (err) {
    next(err);
  }
};

/* -----------------------------------------------------
    GET ME (Comprehensive Multi-Role Profile - FINAL)
----------------------------------------------------- */
export const getMe = async (req, res, next) => {
  try {
    const [rows] = await db.query(`
        SELECT 
            u.id, 
            u.full_name, 
            u.phone, 
            u.email, 
            u.is_active,
            u.created_at,
            r.name AS role_name, 
            -- Customer specific fields
            c.id AS customer_id,
            c.referral_code, 
            c.total_points, 
            c.default_address_id,
            (SELECT COUNT(*) FROM customers WHERE referred_by = c.id) as referral_count,
            -- Rider specific fields
            rd.id AS rider_id,
            rd.vehicle_type,
            rd.vehicle_number,
            rd.is_online AS rider_online,
            rd.is_verified AS rider_verified,
            rd.rating_avg,
            rd.total_completed,
            -- Agent specific fields
            ag.id AS agent_id,
            ag.name AS agent_business_name,
            ag.code AS agent_code,
            ag.commission_type,
            ag.commission_value,
            ag.is_active AS agent_active
        FROM users u 
        INNER JOIN roles r ON u.role_id = r.id
        LEFT JOIN customers c ON u.id = c.user_id 
        LEFT JOIN riders rd ON u.id = rd.user_id
        LEFT JOIN agents ag ON u.id = ag.owner_user_id 
        WHERE u.id = ?`,
      [req.user.id]
    );

    if (!rows.length) {
      return next(new ApiError(404, 'User session invalid or user not found'));
    }

    const rawData = rows[0];
    const role = rawData.role_name.toLowerCase();
    // 1. Core User Data (Universal for all roles)
    const responseData = {
      id: rawData.id,
      full_name: rawData.full_name,
      phone: rawData.phone,
      email: rawData.email,
      role: role,
      is_active: Boolean(rawData.is_active),
      created_at: rawData.created_at
    };

    // 2. Role-Specific Payload Construction
    switch (role) {
      case 'customer':
        responseData.customer_id = rawData.customer_id;
        responseData.referral_code = rawData.referral_code;
        responseData.total_points = rawData.total_points || 0;
        responseData.referral_count = rawData.referral_count || 0;
        responseData.default_address_id = rawData.default_address_id;
        break;

      case 'rider':
        responseData.rider_id = rawData.rider_id;
        responseData.vehicle_type = rawData.vehicle_type;
        responseData.vehicle_number = rawData.vehicle_number;
        responseData.is_online = Boolean(rawData.rider_online);
        responseData.is_verified = Boolean(rawData.rider_verified);
        responseData.rating_avg = rawData.rating_avg || "0.0";
        responseData.total_completed = rawData.total_completed || 0;
        break;

      case 'agent':
        responseData.agent_id = rawData.agent_id;
        responseData.business_name = rawData.agent_business_name || rawData.full_name;
        responseData.agent_code = rawData.agent_code;
        responseData.is_verified = Boolean(rawData.agent_active);
        responseData.commission = {
          type: rawData.commission_type,
          value: rawData.commission_value || "0.00"
        };
        break;

      case 'admin':
      case 'superadmin':
        responseData.is_staff = true;
        break;

      default:
        // Optional: Add basic profile even for unknown roles
        break;
    }

    res.json({
      success: true,
      data: responseData
    });
  } catch (err) {
    console.error("GetMe Error:", err);
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