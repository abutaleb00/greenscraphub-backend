import cron from 'node-cron';
import axios from 'axios';
import nodemailer from 'nodemailer';
import db from '../config/db.js';

const dispatchSMSNode = async (apiKey, to, message) => {
    let formatted = to.trim();
    if (formatted.startsWith('0')) formatted = '88' + formatted;
    await axios.post('https://api.sms.net.bd/sendsms', { api_key: apiKey, msg: message, to: formatted }, { headers: { 'Content-Type': 'multipart/form-data' } });
};

const dispatchEmailNode = async (transporter, to, subject, body) => {
    await transporter.sendMail({
        from: `"Smart Scrap BD Hub" <${process.env.MAIL_USER}>`,
        to, subject,
        html: `<div style="font-family:sans-serif;max-width:600px;margin:0 auto;padding:20px;border:1px solid #eee;border-radius:12px;">${body}</div>`
    });
};

// Orchestrate Background Automation Daemon (Runs every 1 minute)
cron.schedule('* * * * *', async () => {
    try {
        // Find past due pending tasks matching timeline matrix
        const [campaigns] = await db.query(
            "SELECT * FROM marketing_campaigns WHERE status = 'pending' AND scheduled_at <= NOW() LIMIT 1"
        );
        if (!campaigns.length) return;

        const campaign = campaigns[0];
        // Mutate system state lock flag so parallel tasks don't pick it up
        await db.query("UPDATE marketing_campaigns SET status = 'processing' WHERE id = ?", [campaign.id]);

        const [queueItems] = await db.query(
            "SELECT * FROM marketing_queue WHERE campaign_id = ? AND status = 'queued'",
            [campaign.id]
        );

        let transporter = null;
        if (campaign.channel === 'email') {
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
                    if (campaign.channel === 'sms') {
                        await dispatchSMSNode(process.env.SMS_API_KEY, task.recipient_destination, campaign.content);
                    } else {
                        await dispatchEmailNode(transporter, task.recipient_destination, campaign.email_subject, campaign.content);
                    }
                    await db.query("UPDATE marketing_queue SET status = 'sent', sent_at = NOW() WHERE id = ?", [task.id]);
                } catch (nodeErr) {
                    await db.query("UPDATE marketing_queue SET status = 'failed', error_message = ? WHERE id = ?", [nodeErr.message.slice(0, 255), task.id]);
                }
            }));
        }

        await db.query("UPDATE marketing_campaigns SET status = 'completed' WHERE id = ?", [campaign.id]);
        console.log(`[MARKETING WORKER] Processed campaign system allocation ID: ${campaign.id}`);
    } catch (criticalErr) {
        console.error("[CRITICAL WORKER THREAD CRASH]:", criticalErr.message);
    }
});