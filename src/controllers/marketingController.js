import db from '../config/db.js';
import ApiError from '../utils/ApiError.js';
import axios from 'axios';
import nodemailer from 'nodemailer';

/* -----------------------------------------------------
    CORE RUNTIME INSTANT BROADCAST NODE DISPATCHERS
----------------------------------------------------- */
const dispatchInstantSMS = async (to, message) => {
    let formatted = to.trim();
    if (formatted.startsWith('0')) formatted = '88' + formatted;
    await axios.post('https://api.sms.net.bd/sendsms', {
        api_key: process.env.SMS_API_KEY,
        msg: message,
        to: formatted
    }, { headers: { 'Content-Type': 'multipart/form-data' } });
};

const dispatchInstantEmail = async (transporter, to, subject, body) => {
    await transporter.sendMail({
        from: `"Smart Scrap BD Hub" <${process.env.MAIL_USER}>`,
        to, subject,
        html: `<div style="font-family:sans-serif;max-width:600px;margin:0 auto;padding:20px;border:1px solid #eee;border-radius:12px;">${body}</div>`
    });
};

/* -----------------------------------------------------
    CAMPAIGN SUMMARY INDEX LIST (TIMEZONE FIXED)
----------------------------------------------------- */
export const getCampaignsOverview = async (req, res, next) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const offset = (page - 1) * limit;

        // 🟢 FIXED: CONVERT_TZ ব্যবহার করে UTC থেকে বাংলাদেশ টাইমে রূপান্তর করা হয়েছে
        const query = `
            SELECT 
                mc.id, mc.title, mc.channel, mc.target_type, 
                CONVERT_TZ(mc.scheduled_at, '+00:00', '+06:00') as scheduled_at, 
                mc.status, mc.created_at,
                u.full_name as created_by_name,
                (SELECT COUNT(*) FROM marketing_queue WHERE campaign_id = mc.id) as total_targets,
                (SELECT COUNT(*) FROM marketing_queue WHERE campaign_id = mc.id AND status = 'sent') as sent_count,
                (SELECT COUNT(*) FROM marketing_queue WHERE campaign_id = mc.id AND status = 'failed') as failed_count
            FROM marketing_campaigns mc
            JOIN users u ON mc.created_by = u.id
            ORDER BY mc.created_at DESC
            LIMIT ? OFFSET ?
        `;

        const [rows] = await db.query(query, [limit, offset]);

        const [totalCountRows] = await db.query(
            "SELECT COUNT(*) as total FROM marketing_campaigns"
        );

        res.json({
            success: true,
            data: rows,
            meta: {
                total_campaigns: totalCountRows[0].total,
                page,
                limit
            }
        });
    } catch (err) {
        next(err);
    }
};

/* -----------------------------------------------------
    DETAILED CAMPAIGN RECIPIENT DELIVERY HISTORY LOG
----------------------------------------------------- */
export const getCampaignHistoryLog = async (req, res, next) => {
    try {
        const campaignId = req.params.id;
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 50;
        const offset = (page - 1) * limit;

        const [campaignCheck] = await db.query(
            `SELECT id, title, channel, content, email_subject 
             FROM marketing_campaigns 
             WHERE id = ?`,
            [campaignId]
        );

        if (!campaignCheck.length) return next(new ApiError(404, "Target marketing campaign record not found."));

        const query = `
            SELECT 
                mq.id, mq.recipient_destination, mq.status, mq.error_message, mq.sent_at,
                u.full_name as customer_name, u.phone as customer_phone
            FROM marketing_queue mq
            JOIN users u ON mq.user_id = u.id
            WHERE mq.campaign_id = ?
            ORDER BY mq.id ASC
            LIMIT ? OFFSET ?
        `;

        const [rows] = await db.query(query, [parseInt(campaignId), limit, offset]);

        const [totalCountRows] = await db.query(
            "SELECT COUNT(*) as total FROM marketing_queue WHERE campaign_id = ?",
            [campaignId]
        );

        res.json({
            success: true,
            campaign: campaignCheck[0],
            data: rows,
            meta: {
                total_recipients: totalCountRows[0].total,
                page,
                limit
            }
        });
    } catch (err) {
        next(err);
    }
};

/* -----------------------------------------------------
    CAMPAIGN BUILDER (TIMEZONE ALIGNED)
----------------------------------------------------- */
export const createMarketingCampaign = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const adminId = req.user.id;
        const { title, channel, content, email_subject, target_type, target_user_ids, scheduled_at } = req.body;

        if (!title || !channel || !content) {
            return next(new ApiError(400, "Required orchestration configuration metadata missing."));
        }

        // 🟢 ১. কারেন্ট নোড প্রসেস সময়কে সরাসরি 'Asia/Dhaka' টাইমজোনে রূপান্তর
        const bdtNow = new Date(new Date().toLocaleString("en-US", { timeZone: "Asia/Dhaka" }));

        // ফ্রন্টএন্ড থেকে আসা লোকাল টাইম স্ট্রিংকে অবজেক্টে রূপান্তর
        const scheduleTimeObj = scheduled_at ? new Date(scheduled_at) : null;
        const scheduleInMs = scheduleTimeObj ? scheduleTimeObj.getTime() : 0;

        // ১০ সেকেন্ডের রেস-কন্ডিশন বাফার সহ ইনস্ট্যান্ট চেক
        const isInstant = !scheduled_at || (scheduleInMs - bdtNow.getTime()) <= 10000;

        // 🟢 ২. ফাইনাল ডেট অ্যাসাইনমেন্ট (স্ট্রিং স্লাইস না করে সরাসরি পিওর ডেট অবজেক্ট ড্রাইভারকে পাস করা হচ্ছে)
        const finalScheduledTime = isInstant ? bdtNow : scheduleTimeObj;
        const initialStatus = isInstant ? 'processing' : 'pending';

        await conn.beginTransaction();

        // 1. Save Campaign Blueprint
        const [campaignResult] = await conn.query(
            `INSERT INTO marketing_campaigns 
            (title, channel, content, email_subject, target_type, scheduled_at, status, created_by) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
            [title, channel, content, email_subject || null, target_type, finalScheduledTime, initialStatus, adminId]
        );
        const campaignId = campaignResult.insertId;

        // 2. Discover Target Recipients
        let targets = [];
        if (target_type === 'all') {
            const [activeCustomers] = await conn.query(
                "SELECT id, phone, email FROM users WHERE role_id = 4 AND is_active = 1"
            );
            targets = activeCustomers;
        } else if (target_type === 'selected' && Array.isArray(target_user_ids) && target_user_ids.length > 0) {
            const [selectedCustomers] = await conn.query(
                "SELECT id, phone, email FROM users WHERE id IN (?) AND role_id = 4",
                [target_user_ids]
            );
            targets = selectedCustomers;
        }

        if (targets.length === 0) {
            await conn.rollback();
            return next(new ApiError(400, "Recipient destination scope resolution returned empty set."));
        }

        // 3. Populate Delivery Queue
        const queueValues = [];
        targets.forEach(user => {
            const destination = channel === 'sms' ? user.phone : user.email;
            if (destination && !destination.includes('example.com')) {
                queueValues.push([campaignId, user.id, destination]);
            }
        });

        if (queueValues.length > 0) {
            await conn.query(
                "INSERT INTO marketing_queue (campaign_id, user_id, recipient_destination) VALUES ?",
                [queueValues]
            );
        }

        await conn.commit();

        // 4. IF INSTANT: Spin up immediate background execution right now
        if (isInstant) {
            setImmediate(async () => {
                try {
                    const [queueItems] = await db.query(
                        "SELECT * FROM marketing_queue WHERE campaign_id = ? AND status = 'queued'",
                        [campaignId]
                    );

                    let transporter = null;
                    if (channel === 'email') {
                        transporter = nodemailer.createTransport({
                            host: process.env.MAIL_HOST, port: parseInt(process.env.MAIL_PORT),
                            secure: process.env.MAIL_SECURE === 'true', auth: { user: process.env.MAIL_USER, pass: process.env.MAIL_PASS }
                        });
                    }

                    const batchSize = 30;
                    for (let i = 0; i < queueItems.length; i += batchSize) {
                        const chunk = queueItems.slice(i, i + batchSize);

                        await Promise.all(chunk.map(async (task) => {
                            try {
                                if (channel === 'sms') {
                                    await dispatchInstantSMS(task.recipient_destination, content);
                                } else {
                                    await dispatchInstantEmail(transporter, task.recipient_destination, email_subject, content);
                                }
                                // 🟢 ৩. কিউ আপডেট স্টেটমেন্টেও কারেন্ট বাংলাদেশ টাইম লক করা হলো
                                await db.query("UPDATE marketing_queue SET status = 'sent', sent_at = ? WHERE id = ?", [bdtNow, task.id]);
                            } catch (nodeErr) {
                                await db.query("UPDATE marketing_queue SET status = 'failed', error_message = ? WHERE id = ?", [nodeErr.message.slice(0, 255), task.id]);
                            }
                        }));
                    }
                    await db.query("UPDATE marketing_campaigns SET status = 'completed' WHERE id = ?", [campaignId]);
                } catch (workerErr) {
                    console.error("[INSTANT EXECUTION WORKER CRASH]:", workerErr.message);
                }
            });
        }

        res.status(201).json({
            success: true,
            message: isInstant
                ? `Instant broadcast processing initialized for ${queueValues.length} targets.`
                : `Campaign scheduled successfully for execution on target timeline.`,
            campaign_id: campaignId
        });
    } catch (err) {
        if (conn) await conn.rollback();
        next(err);
    } finally {
        if (conn) conn.release();
    }
};

/* -----------------------------------------------------
    CANCEL PENDING SCHEDULED CAMPAIGN
----------------------------------------------------- */
export const cancelScheduledCampaign = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const campaignId = req.params.id;
        const adminId = req.user.id;

        await conn.beginTransaction();

        const [campaigns] = await conn.query(
            "SELECT status, title FROM marketing_campaigns WHERE id = ? FOR UPDATE",
            [campaignId]
        );

        if (!campaigns.length) {
            await conn.rollback();
            return res.status(404).json({ success: false, message: "Campaign record not found." });
        }

        if (campaigns[0].status !== 'pending') {
            await conn.rollback();
            return res.status(400).json({
                success: false,
                message: `Cannot cancel campaign. Pipeline is already processing or completed.`
            });
        }

        await conn.query("DELETE FROM marketing_queue WHERE campaign_id = ?", [campaignId]);

        await conn.query(
            "UPDATE marketing_campaigns SET status = 'failed' WHERE id = ?",
            [campaignId]
        );

        await conn.query(
            `INSERT INTO activity_logs (user_id, action, platform, browser, os, device, ip_address, metadata, created_at) 
             VALUES (?, 'CANCEL_CAMPAIGN', 'WEB', 'Marketing Engine', 'Server', 'System', '127.0.0.1', ?, NOW())`,
            [adminId, JSON.stringify({ campaign_id: campaignId, title: campaigns[0].title })]
        );

        await conn.commit();
        res.json({
            success: true,
            message: `Campaign [${campaigns[0].title}] has been successfully canceled and purged from queue.`
        });
    } catch (err) {
        await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};