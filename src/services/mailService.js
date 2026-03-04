import nodemailer from 'nodemailer';

const transporter = nodemailer.createTransport({
    host: process.env.MAIL_HOST,
    port: process.env.MAIL_PORT,
    secure: process.env.MAIL_SECURE === 'true',
    auth: {
        user: process.env.MAIL_USER,
        pass: process.env.MAIL_PASS,
    },
});

export const sendUnifiedReceipt = async (receiptData, items) => {
    try {
        const itemRows = items.map(it => `
            <tr>
                <td style="padding: 16px 0; border-bottom: 1px solid #f0f4f8;">
                    <div style="font-size: 14px; font-weight: 700; color: #1a202c; text-transform: uppercase; margin-bottom: 4px;">${it.item_name}</div>
                    <div style="font-size: 12px; color: #718096; font-weight: 600;">Rate: ৳${it.final_rate_per_unit}/kg</div>
                </td>
                <td style="padding: 16px 0; border-bottom: 1px solid #f0f4f8; text-align: center; font-size: 14px; font-weight: 700; color: #4a5568;">
                    ${it.actual_weight} KG
                </td>
                <td style="padding: 16px 0; border-bottom: 1px solid #f0f4f8; text-align: right; font-size: 14px; font-weight: 800; color: #10b981;">
                    ৳${parseFloat(it.final_amount).toLocaleString()}
                </td>
            </tr>
        `).join('');

        const htmlContent = `
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin: 0; padding: 0; background-color: #f4f7f6; -webkit-font-smoothing: antialiased;">
    <table border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed;">
        <tr>
            <td align="center" style="padding: 40px 0;">
                <table border="0" cellpadding="0" cellspacing="0" width="600" style="background-color: #ffffff; border-radius: 24px; overflow: hidden; box-shadow: 0 20px 40px rgba(0,0,0,0.04);">
                    <tr>
                        <td align="center" style="padding: 40px; background: linear-gradient(135deg, #10b981 0%, #059669 100%);">
                            <div style="background: rgba(255,255,255,0.2); width: 60px; height: 60px; border-radius: 18px; line-height: 60px; margin-bottom: 20px;">
                                <span style="font-size: 30px;">♻️</span>
                            </div>
                            <h1 style="color: #ffffff; margin: 0; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; font-size: 22px; font-weight: 900; letter-spacing: -0.5px; text-transform: uppercase;">GreenScrap Hub</h1>
                            <div style="display: inline-block; margin-top: 15px; padding: 6px 16px; background: rgba(255,255,255,0.15); border-radius: 100px; color: #ffffff; font-family: sans-serif; font-size: 11px; font-weight: 800; text-transform: uppercase; letter-spacing: 1px;">
                                Transaction Verified
                            </div>
                        </td>
                    </tr>

                    <tr>
                        <td style="padding: 40px;">
                            <table border="0" cellpadding="0" cellspacing="0" width="100%">
                                <tr>
                                    <td>
                                        <p style="margin: 0 0 5px 0; font-family: sans-serif; font-size: 11px; font-weight: 800; color: #a0aec0; text-transform: uppercase; letter-spacing: 1px;">Customer</p>
                                        <p style="margin: 0; font-family: sans-serif; font-size: 16px; font-weight: 700; color: #1a202c;">${receiptData.customer_name}</p>
                                    </td>
                                    <td align="right">
                                        <p style="margin: 0 0 5px 0; font-family: sans-serif; font-size: 11px; font-weight: 800; color: #a0aec0; text-transform: uppercase; letter-spacing: 1px;">Order ID</p>
                                        <p style="margin: 0; font-family: sans-serif; font-size: 16px; font-weight: 700; color: #1a202c; font-style: italic;">#GS-${receiptData.booking_code}</p>
                                    </td>
                                </tr>
                            </table>

                            <div style="margin: 30px 0; border-top: 2px dashed #edf2f7;"></div>

                            <table border="0" cellpadding="0" cellspacing="0" width="100%" style="font-family: sans-serif;">
                                <thead>
                                    <tr>
                                        <th align="left" style="padding-bottom: 12px; font-size: 10px; font-weight: 800; color: #cbd5e0; text-transform: uppercase; letter-spacing: 1px;">Material Details</th>
                                        <th align="center" style="padding-bottom: 12px; font-size: 10px; font-weight: 800; color: #cbd5e0; text-transform: uppercase; letter-spacing: 1px;">Weight</th>
                                        <th align="right" style="padding-bottom: 12px; font-size: 10px; font-weight: 800; color: #cbd5e0; text-transform: uppercase; letter-spacing: 1px;">Subtotal</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    ${itemRows}
                                </tbody>
                            </table>

                            <table border="0" cellpadding="0" cellspacing="0" width="100%" style="margin-top: 30px; background-color: #f8fafc; border-radius: 20px; padding: 30px;">
                                <tr>
                                    <td>
                                        <p style="margin: 0; font-family: sans-serif; font-size: 12px; font-weight: 800; color: #718096; text-transform: uppercase; letter-spacing: 1px;">Net Payout via ${receiptData.payment_method}</p>
                                        <h2 style="margin: 5px 0 0 0; font-family: sans-serif; font-size: 32px; font-weight: 900; color: #1a202c; letter-spacing: -1px;">৳${parseFloat(receiptData.net_payable_amount).toLocaleString()}</h2>
                                    </td>
                                    <td align="right">
                                        <div style="background: #ffffff; padding: 10px; border-radius: 12px; border: 1px solid #edf2f7;">
                                            <span style="font-size: 20px;">✅</span>
                                        </div>
                                    </td>
                                </tr>
                            </table>

                            <div style="margin-top: 40px; text-align: center; font-family: sans-serif;">
                                <p style="margin: 0; font-size: 12px; font-weight: 700; color: #1a202c; text-transform: uppercase; letter-spacing: 1px;">Processing Hub</p>
                                <p style="margin: 5px 0 0 0; font-size: 13px; color: #718096; font-weight: 600;">${receiptData.hub_name} • ${receiptData.hub_address}</p>
                                
                                <div style="margin: 30px 0; border-top: 1px solid #edf2f7;"></div>
                                
                                <p style="margin: 0; font-size: 10px; color: #a0aec0; font-weight: 700; line-height: 1.8; text-transform: uppercase; letter-spacing: 1px;">
                                    This is a system-generated secure receipt.<br>
                                    Thank you for helping us build a greener planet.
                                </p>
                            </div>
                        </td>
                    </tr>
                </table>
                <p style="margin-top: 20px; text-align: center; font-family: sans-serif; font-size: 12px; color: #a0aec0;">
                    &copy; 2026 GreenScrap Logistics Hub. All rights reserved.
                </p>
            </td>
        </tr>
    </table>
</body>
</html>`;

        const recipients = [receiptData.customer_email, process.env.ADMIN_MAIL].filter(Boolean);

        await transporter.sendMail({
            from: `"GreenScrap Hub" <${process.env.MAIL_USER}>`,
            to: recipients.join(', '),
            subject: `Receipt: Order #GS-${receiptData.booking_code}`,
            html: htmlContent
        });

        console.log(`[Mail] Premium Receipt sent for ${receiptData.booking_code}`);
    } catch (error) {
        console.error("[Mail Error]", error);
    }
};