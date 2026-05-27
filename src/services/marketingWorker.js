import cron from 'node-cron';
import axios from 'axios';
import nodemailer from 'nodemailer';
import db from '../config/db.js';

const dispatchSMSNode = async (apiKey, to, message) => {
    let formatted = to.trim();
    if (formatted.startsWith('0')) formatted = '88' + formatted;
    await axios.post('https://api.sms.net.bd/sendsms', {
        api_key: apiKey,
        msg: message,
        to: formatted
    }, { headers: { 'Content-Type': 'multipart/form-data' } });
};

const dispatchEmailNode = async (transporter, to, subject, body) => {
    await transporter.sendMail({
        from: `"Smart Scrap BD Hub" <${process.env.MAIL_USER}>`,
        to,
        subject,
        html: `<div style="font-family:sans-serif;max-width:600px;margin:0 auto;padding:20px;border:1px solid #eee;border-radius:12px;">${body}</div>`
    });
};

// 🟢 Background Automation Daemon (Orchestrated to evaluate precisely every 1 minute)
cron.schedule('* * * * *', async () => {
    try {
        // 🟢 ১. নোড প্রসেস থেকে পিওর বাংলাদেশ স্ট্যান্ডার্ড টাইম (BST) জেনারেট
        const bdtNow = new Date(new Date().toLocaleString("en-US", { timeZone: "Asia/Dhaka" }));

        console.log(`[CRON HEARTBEAT] Scanning for eligible campaigns at BST: ${bdtNow.toLocaleString('en-BD')}`);

        // 🟢 ২. বাংলাদেশ সময় অনুযায়ী বর্তমান বা অতীত সময়ের পেন্ডিং ক্যাম্পেইন খোঁজা
        const [campaigns] = await db.query(
            `SELECT id, title, channel, content, email_subject 
             FROM marketing_campaigns 
             WHERE status = 'pending' 
               AND scheduled_at <= ? 
             LIMIT 1`,
            [bdtNow]
        );

        if (!campaigns.length) return; // কোনো ক্যাম্পেইন রেডি না থাকলে নিরবে এক্সিট করবে

        const campaign = campaigns[0];
        console.log(`[MARKETING WORKER] Processing activated for campaign: ${campaign.title} (ID: ${campaign.id})`);

        // ৩. রেস কন্ডিশন বা ডাবল ডিসপ্যাচ এড়াতে তাৎক্ষণিক প্রসেসিং স্টেট লক
        await db.query("UPDATE marketing_campaigns SET status = 'processing' WHERE id = ?", [campaign.id]);

        // ৪. এই ক্যাম্পেইনের সাথে ম্যাপ করা কিউড কাস্টমার লিস্ট সংগ্রহ
        const [queueItems] = await db.query(
            "SELECT id, recipient_destination FROM marketing_queue WHERE campaign_id = ? AND status = 'queued'",
            [campaign.id]
        );

        let transporter = null;
        if (campaign.channel === 'email') {
            transporter = nodemailer.createTransport({
                host: process.env.MAIL_HOST,
                port: parseInt(process.env.MAIL_PORT),
                secure: process.env.MAIL_SECURE === 'true',
                auth: { user: process.env.MAIL_USER, pass: process.env.MAIL_PASS }
            });
        }

        // ৫. ব্যাচ ডিসপ্যাচ সিকোয়েন্স লুপ (প্রতি ব্যাচে ৩০টি করে মেসেজ প্রসেস হবে)
        const batchSize = 30;
        for (let i = 0; i < queueItems.length; i += batchSize) {
            const chunk = queueItems.slice(i, i + batchSize);

            await Promise.all(chunk.map(async (task) => {
                try {
                    if (campaign.channel === 'sms') {
                        await dispatchSMSNode(process.env.SMS_API_KEY, task.recipient_destination, campaign.content);
                    } else {
                        await dispatchEmailNode(transporter, task.recipient_destination, campaign.email_subject, campaign.content);
                    }

                    // 🟢 ৬. কিউ আইটেম সাকসেস স্টেটমেন্টে সরাসরি কারেন্ট বাংলাদেশ টাইম লক করা হলো
                    await db.query("UPDATE marketing_queue SET status = 'sent', sent_at = ? WHERE id = ?", [bdtNow, task.id]);
                } catch (nodeErr) {
                    console.error(`[NODE ERROR] Dispatch failed to target ${task.recipient_destination}:`, nodeErr.message);
                    await db.query("UPDATE marketing_queue SET status = 'failed', error_message = ? WHERE id = ?", [nodeErr.message.slice(0, 255), task.id]);
                }
            }));
        }

        // ৭. ক্যাম্পেইনের সামগ্রিক স্ট্যাটাস কমপ্লিট করা
        await db.query("UPDATE marketing_campaigns SET status = 'completed' WHERE id = ?", [campaign.id]);
        console.log(`[MARKETING WORKER] Successfully dispatched campaign layout ID: ${campaign.id}`);

    } catch (criticalErr) {
        console.error("[CRITICAL WORKER THREAD CRASH]:", criticalErr.message);
    }
});