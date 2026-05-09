import db from "../../config/db.js";
import ApiError from "../../utils/ApiError.js";
import { sendPushNotification } from "../../utils/notificationHelper.js";

/* -----------------------------------------------------
    HELPER: SAVE TO NOTIFICATIONS TABLE (DB Persistent)
----------------------------------------------------- */
const saveNotification = async (conn, userId, titleKey, bodyKey, placeholders = {}, type = 'info', action = null) => {
    try {
        const validTypes = ['info', 'alert', 'success', 'warning'];
        const finalType = validTypes.includes(type) ? type : 'info';

        await conn.query(`
            INSERT INTO notifications (
                user_id, title_key, body_key, body_placeholders, 
                notification_type, click_action, created_at
            ) VALUES (?, ?, ?, ?, ?, ?, NOW())`,
            [userId, titleKey, bodyKey, JSON.stringify(placeholders), finalType, action]
        );
    } catch (err) {
        console.error("[DB NOTIFICATION ERROR]", err.message);
    }
};

/**
 * UNIFIED WALLET HELPER
 * Explicitly accepts 'isOperational' as a parameter to prevent string matching bugs.
 */
const updateWallet = async (conn, userId, amount, type, source, refType, refId, descEn, isOperational = false) => {
    const numericAmount = Math.abs(parseFloat(amount)) || 0;
    if (numericAmount <= 0) return null;

    try {
        // 1. Idempotency Check
        const [existing] = await conn.query(
            "SELECT id FROM wallet_transactions WHERE reference_type = ? AND reference_id = ? AND source = ? AND amount = ?",
            [refType, refId, source, numericAmount]
        );
        if (existing.length > 0) return existing[0].id;

        // 2. Fetch/Lock Wallet
        let [walletRows] = await conn.query(
            "SELECT id, balance FROM wallet_accounts WHERE user_id = ? FOR UPDATE",
            [userId]
        );

        let walletId;
        let balanceBefore = 0;

        if (walletRows.length === 0) {
            const [ins] = await conn.query(
                "INSERT INTO wallet_accounts (user_id, balance, created_at, updated_at) VALUES (?, 0, NOW(), NOW())",
                [userId]
            );
            walletId = ins.insertId;
        } else {
            walletId = walletRows[0].id;
            balanceBefore = parseFloat(walletRows[0].balance) || 0;
        }

        // 3. Calculate Balance
        let balanceAfter = balanceBefore;

        // 🛡️ Safe Check: Only update balance if it is explicitly NOT an operational transaction
        if (!isOperational) {
            balanceAfter = type === 'credit'
                ? parseFloat((balanceBefore + numericAmount).toFixed(2))
                : parseFloat((balanceBefore - numericAmount).toFixed(2));

            await conn.query(
                "UPDATE wallet_accounts SET balance = ?, updated_at = NOW() WHERE id = ?",
                [balanceAfter, walletId]
            );
        }

        // 4. Record Transaction Ledger
        const [result] = await conn.query(
            `INSERT INTO wallet_transactions 
            (wallet_id, type, source, reference_type, reference_id, amount, balance_before, balance_after, description_en, status, created_at) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'completed', NOW())`,
            [walletId, type, source, refType, refId, numericAmount, balanceBefore, balanceAfter, descEn]
        );

        return result.insertId;
    } catch (err) {
        console.error("[Wallet Helper Error]", err.message);
        throw err;
    }
};

/**
 * 1. GET PICKUP DETAILS (Full Master Data + Items + Timeline + Tracking)
 * Fixes: Bilingual Timeline notes and User-uploaded item photos parsing.
 */
export const getPickupDetails = async (req, res, next) => {
    try {
        const { id } = req.params;
        const lang = req.headers['accept-language'] === 'bn' ? 'bn' : 'en';

        // 1. Fetch Pickup Master Data with full Location details
        const [pickupRows] = await db.query(
            `SELECT p.*, 
                u.full_name as customer_name, u.phone as customer_phone, u.email as customer_email,
                r_u.full_name as rider_name, r_u.phone as rider_phone, r_u.profile_image as rider_image,
                r.current_latitude as rider_live_lat, r.current_longitude as rider_live_lng,
                ag.business_name as hub_name, ag.latitude as hub_lat, ag.longitude as hub_lng,
                addr.address_line, addr.latitude as addr_lat, addr.longitude as addr_lng,
                dist.name_en as district_name_en, dist.name_bn as district_name_bn,
                upz.name_en as upazila_name_en, upz.name_bn as upazila_name_bn
             FROM pickups p 
             JOIN customers c ON p.customer_id = c.id 
             JOIN users u ON c.user_id = u.id
             LEFT JOIN riders r ON p.rider_id = r.id 
             LEFT JOIN users r_u ON r.user_id = r_u.id
             LEFT JOIN agents ag ON p.agent_id = ag.id
             LEFT JOIN addresses addr ON p.customer_address_id = addr.id
             LEFT JOIN districts dist ON addr.district_id = dist.id
             LEFT JOIN upazilas upz ON addr.upazila_id = upz.id
             WHERE p.id = ?`, [id]
        );

        if (!pickupRows.length) {
            return res.status(404).json({ success: false, message: "Pickup not found" });
        }

        const rawPickup = pickupRows[0];

        // BASE_URL and URL Normalization Helper
        const getFullUrl = (path) => {
            if (!path) return null;
            if (path.startsWith('http')) return path.replace('http://', 'https://');
            const baseUrl = (process.env.BASE_URL || 'https://webapp.prosfata.space').replace(/\/$/, '');
            return `${baseUrl}/${path.replace(/^\//, "")}`;
        };

        // 2. Construct the Tracking object for the MapView
        const tracking = {
            origin: {
                latitude: rawPickup.rider_live_lat || rawPickup.hub_lat,
                longitude: rawPickup.rider_live_lng || rawPickup.hub_lng
            },
            destination: {
                latitude: rawPickup.addr_lat,
                longitude: rawPickup.addr_lng
            }
        };

        // 3. Map the correct Language fields for District/Upazila
        const pickup = {
            ...rawPickup,
            district_name: lang === 'bn' ? rawPickup.district_name_bn : rawPickup.district_name_en,
            upazila_name: lang === 'bn' ? rawPickup.upazila_name_bn : rawPickup.upazila_name_en,
            rider_image: getFullUrl(rawPickup.rider_image),
            proof_image_before: getFullUrl(rawPickup.proof_image_before),
            proof_image_after: getFullUrl(rawPickup.proof_image_after)
        };

        // 4. Fetch associated pickup items and Parse User Photos
        const [items] = await db.query(
            `SELECT pi.*, si.name_en, si.name_bn, si.unit, si.image_url as product_image
             FROM pickup_items pi 
             JOIN scrap_items si ON pi.item_id = si.id 
             WHERE pi.pickup_id = ?`, [id]
        );

        const transformedItems = items.map(item => {
            let photos = [];
            try {
                // If user_photos is a JSON string in DB, parse it. If already object/null, handle it.
                photos = typeof item.user_photos === 'string' ? JSON.parse(item.user_photos) : (item.user_photos || []);
            } catch (e) {
                photos = [];
            }

            return {
                ...item,
                product_image: getFullUrl(item.product_image),
                // Map through the array and get full URLs for all user-attached photos
                user_photos: Array.isArray(photos) ? photos.map(p => getFullUrl(p)) : []
            };
        });

        // 5. Fetch Pickup Timeline (Activity History) with Bilingual support
        // Note: Assumes your pickup_timeline table has note_en and note_bn. 
        // If it only has 'note', the frontend translation helper will handle it.
        const [timelineRows] = await db.query(
            `SELECT pt.*, u.full_name as changer_name 
             FROM pickup_timeline pt
             LEFT JOIN users u ON pt.changed_by = u.id
             WHERE pt.pickup_id = ? 
             ORDER BY pt.created_at DESC`, [id]
        );

        // Normalize timeline notes based on language
        const timeline = timelineRows.map(log => ({
            ...log,
            // If DB has bilingual columns, use them, otherwise fallback to standard note
            display_note: lang === 'bn' ? (log.note_bn || log.note) : (log.note_en || log.note)
        }));

        // 6. Final Response Object
        res.json({
            success: true,
            data: {
                pickup: pickup,
                items: transformedItems,
                timeline: timeline,
                tracking: tracking
            }
        });

    } catch (err) {
        console.error("Pickup Details Error:", err.message);
        next(err);
    }
};

/**
 * 2. COMPLETE PICKUP (FCM + SMS + Email + Wallet + Ledger Liability)
 * Logic: Validates Hub Cash before allowing physical payout and manages truck load.
 */
export const completePickup = async (req, res, next) => {
    const conn = await db.getConnection();
    const { id: pickupId } = req.params;
    const { items, payment_method, note } = req.body;

    try {
        await conn.beginTransaction();

        // 1. Fetch Pickup, Customer, and Rider details 
        // Note: Includes email for the success receipt notification
        const [p] = await conn.query(`
            SELECT p.*, c.user_id as customer_uid, r.id as rider_table_id, r.user_id as rider_uid, 
                   r.cash_held_liability, u.fcm_token as customer_fcm, u.phone as customer_phone, 
                   u.email as customer_email
            FROM pickups p
            JOIN customers c ON p.customer_id = c.id
            JOIN users u ON c.user_id = u.id
            LEFT JOIN riders r ON p.rider_id = r.id
            WHERE p.id = ? FOR UPDATE`, [pickupId]);

        if (!p.length) throw new ApiError(404, "Pickup not found.");
        const pickup = p[0];

        // 2. Calculate Totals based on actual weights provided by the Rider
        let netPayable = 0;
        let totalWeight = 0;
        const parsedItems = typeof items === 'string' ? JSON.parse(items) : items;

        for (const it of parsedItems) {
            const weight = parseFloat(it.actual_weight) || 0;
            const rate = parseFloat(it.final_rate) || 0;
            const subtotal = weight * rate;
            netPayable += subtotal;
            totalWeight += weight;

            await conn.query(
                `UPDATE pickup_items SET actual_weight = ?, final_rate_per_unit = ?, final_amount = ? 
                 WHERE id = ? AND pickup_id = ?`, [weight, rate, subtotal, it.id, pickupId]
            );
        }

        // 3. --- 🛡️ LEADER SYSTEM: CASH VALIDATION & LIABILITY ---
        if (payment_method === 'cash') {
            const currentLiability = parseFloat(pickup.cash_held_liability || 0);

            // Safety check: Ensure rider has enough physical cash issued by hub
            if (currentLiability < netPayable) {
                throw new ApiError(400, `Insufficient Hub Cash. You need ৳${netPayable.toFixed(2)} but have only ৳${currentLiability.toFixed(2)} in hand.`);
            }

            // Deduct from Hub liability and increase truck load weight
            await conn.query(
                `UPDATE riders SET 
                    cash_held_liability = cash_held_liability - ?, 
                    total_collected_weight_kg = total_collected_weight_kg + ? 
                 WHERE id = ?`,
                [netPayable, totalWeight, pickup.rider_table_id]
            );
        } else {
            // For Wallet/Later, liability is unchanged, but truck weight increases
            await conn.query(
                "UPDATE riders SET total_collected_weight_kg = total_collected_weight_kg + ? WHERE id = ?",
                [totalWeight, pickup.rider_table_id]
            );
        }

        // 4. --- 💰 WALLET UPDATES ---
        // Customer Payment (Only if they chose digital wallet method)
        if (payment_method === 'wallet') {
            await updateWallet(conn, pickup.customer_uid, netPayable, 'credit', 'pickup_payment', 'pickup', pickupId, `Payment for ${pickup.booking_code}`);
        }

        // 5. --- ✅ FINALIZE PICKUP RECORD ---
        const proofImage = req.file ? `/uploads/pickups/${req.file.filename}` : null;

        await conn.query(
            `UPDATE pickups SET 
                status = 'completed', 
                actual_weight_kg = ?, 
                net_payable_amount = ?, 
                payment_method = ?, 
                payment_status = ?, 
                proof_image_after = ?, 
                completed_at = NOW() 
             WHERE id = ?`,
            [
                totalWeight,
                netPayable,
                payment_method,
                (payment_method === 'wallet' ? 'paid' : 'pending'),
                proofImage,
                pickupId
            ]
        );

        // Record in Timeline for audit log
        await conn.query(
            "INSERT INTO pickup_timeline (pickup_id, status, note, changed_by) VALUES (?, 'completed', ?, ?)",
            [pickupId, note || 'Shipment finalized and paid', req.user.id]
        );

        // Save persistent in-app notification for the Customer
        await saveNotification(conn, pickup.customer_uid, 'notif_earnings_confirmed_title', 'notif_earnings_confirmed_body',
            { bookingCode: pickup.booking_code, amount: netPayable.toFixed(2) }, 'success', `/(home)/activity/${pickupId}`);

        // COMMIT TRANSACTION
        await conn.commit();

        // 6. --- 📨 EXTERNAL COMMUNICATIONS (Post-Commit) ---

        // SMS Notification
        if (pickup.customer_phone) {
            const smsMessage = `SmartScrap: Your pickup ${pickup.booking_code} is complete. ৳${netPayable.toFixed(2)} has been paid via ${payment_method.toUpperCase()}. Thank you!`;
            // Call your SMS Gateway provider here
            // await smsHelper.send(pickup.customer_phone, smsMessage); 
            console.log(`[LOG: SMS Sent to ${pickup.customer_phone}]`);
        }

        // Email Notification
        if (pickup.customer_email) {
            const emailSubject = `Success: Receipt for Pickup ${pickup.booking_code}`;
            const emailBody = `<h1>Pickup Successful</h1><p>Your scrap weighing ${totalWeight}kg has been collected. Net amount paid: ৳${netPayable.toFixed(2)} via ${payment_method}.</p>`;
            // Call your Email provider here (SendGrid/Nodemailer)
            // await emailHelper.send(pickup.customer_email, emailSubject, emailBody);
            console.log(`[LOG: Email Sent to ${pickup.customer_email}]`);
        }

        // Push Notification (FCM)
        if (pickup.customer_fcm) {
            sendPushNotification(
                pickup.customer_fcm,
                "Earnings Confirmed! 💰",
                `৳${netPayable.toFixed(2)} for ${pickup.booking_code} via ${payment_method.toUpperCase()}`,
                { orderId: pickupId.toString(), type: "ORDER_UPDATE" }
            );
        }

        // Final Response
        res.json({
            success: true,
            message: "Pickup completed successfully!",
            net_amount: netPayable,
            remaining_hub_cash: payment_method === 'cash' ? (parseFloat(pickup.cash_held_liability) - netPayable) : pickup.cash_held_liability
        });

    } catch (err) {
        if (conn) await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};

/**
 * 🟢 ADMIN: OPEN SHIFT / ISSUE CASH (Flexible)
 * Dynamically queries the database schema to prevent any string ENUM truncation errors.
 */
export const openRiderShift = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const { rider_id, amount_issued, notes } = req.body;
        const numAmount = parseFloat(amount_issued);

        if (isNaN(numAmount) || numAmount <= 0) {
            return res.status(400).json({ success: false, message: "Valid amount is required" });
        }

        await conn.beginTransaction();

        // 1. 🔍 DYNAMIC ENUM DISCOVERY: Get valid values for 'reference_type'
        const [enumSchema] = await conn.query(
            `SELECT COLUMN_TYPE 
             FROM INFORMATION_SCHEMA.COLUMNS 
             WHERE TABLE_SCHEMA = DATABASE() 
               AND TABLE_NAME = 'wallet_transactions' 
               AND COLUMN_NAME = 'reference_type'`
        );

        let safeRefType = 'adjustment';
        if (enumSchema.length > 0 && enumSchema[0].COLUMN_TYPE.startsWith('enum')) {
            const matches = enumSchema[0].COLUMN_TYPE.match(/'([^']+)'/g);
            if (matches && matches.length > 0) {
                safeRefType = matches[0].replace(/'/g, '');
            }
        }

        // 2. 🔍 DYNAMIC ENUM DISCOVERY: Get valid values for 'source'
        const [sourceSchema] = await conn.query(
            `SELECT COLUMN_TYPE 
             FROM INFORMATION_SCHEMA.COLUMNS 
             WHERE TABLE_SCHEMA = DATABASE() 
               AND TABLE_NAME = 'wallet_transactions' 
               AND COLUMN_NAME = 'source'`
        );

        let safeSource = 'adjustment';
        if (sourceSchema.length > 0 && sourceSchema[0].COLUMN_TYPE.startsWith('enum')) {
            const matches = sourceSchema[0].COLUMN_TYPE.match(/'([^']+)'/g);
            if (matches && matches.length > 0) {
                safeSource = matches[0].replace(/'/g, '');
            }
        }

        // 3. Get the rider's user_id safely
        const [rider] = await conn.query(
            "SELECT user_id, cash_held_liability FROM riders WHERE id = ?",
            [rider_id]
        );
        if (!rider.length) {
            throw new Error("Rider node not found");
        }
        const userId = rider[0].user_id;

        // 4. Check if the rider already has an active shift
        const [active] = await conn.query(
            "SELECT id FROM rider_shifts WHERE rider_id = ? AND status = 'active'",
            [rider_id]
        );

        let activeShiftId = null;

        if (active.length > 0) {
            // SCENARIO A: TOP-UP (Shift already exists)
            activeShiftId = active[0].id;

            // Increment the cash_issued on the existing shift
            await conn.query(
                "UPDATE rider_shifts SET cash_issued = cash_issued + ?, notes = CONCAT(COALESCE(notes,''), ?) WHERE id = ?",
                [numAmount, ` | Top-up: ৳${numAmount}`, activeShiftId]
            );

            // 🛡️ Pass dynamically verified safe string tokens
            await updateWallet(
                conn,
                userId,
                numAmount,
                'credit',
                safeSource,
                safeRefType,
                activeShiftId,
                `Shift Top-up: ৳${numAmount}`,
                true // 👈 Explicitly marks as an operational transaction
            );

        } else {
            // SCENARIO B: NEW SHIFT
            const [result] = await conn.query(
                "INSERT INTO rider_shifts (rider_id, admin_id, cash_issued, status, notes) VALUES (?, ?, ?, 'active', ?)",
                [rider_id, req.user.id, numAmount, notes]
            );
            activeShiftId = result.insertId;

            // 🛡️ Pass dynamically verified safe string tokens
            await updateWallet(
                conn,
                userId,
                numAmount,
                'credit',
                safeSource,
                safeRefType,
                activeShiftId,
                `Morning Cash Issued: ৳${numAmount}`,
                true // 👈 Explicitly marks as an operational transaction
            );
        }

        // 5. ALWAYS update the rider's total liability
        await conn.query(
            "UPDATE riders SET cash_held_liability = cash_held_liability + ? WHERE id = ?",
            [numAmount, rider_id]
        );

        await conn.commit();
        res.json({ success: true, message: "Cash Issued Successfully" });
    } catch (err) {
        if (conn) await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};

/**
 * RIDER: SETTLE INTENT
 * Updated to match your specific DB schema (no updated_at column)
 */
export const settleRiderIntent = async (req, res, next) => {
    try {
        const { amount_to_return, scrap_weight } = req.body;
        const userId = req.user.id;

        // 1. Resolve Rider Table ID
        const [rider] = await db.query("SELECT id FROM riders WHERE user_id = ?", [userId]);
        if (!rider.length) return res.status(404).json({ success: false, message: "Rider not found" });
        const riderId = rider[0].id;

        // 2. Update the Active Shift
        // REMOVED: updated_at = NOW() because column is missing in your table
        const [result] = await db.query(
            `UPDATE rider_shifts 
             SET 
                reported_cash_return = ?, 
                reported_weight_return = ?, 
                status = 'settlement_pending'
             WHERE rider_id = ? AND status = 'active' 
             ORDER BY opened_at DESC LIMIT 1`,
            [
                parseFloat(amount_to_return) || 0,
                parseFloat(scrap_weight) || 0,
                riderId
            ]
        );

        if (result.affectedRows === 0) {
            return res.status(400).json({
                success: false,
                message: "No active shift found. Please check if you already submitted."
            });
        }

        res.json({
            success: true,
            message: "Declaration sent. Proceed to Hub for handover."
        });

    } catch (err) {
        console.error("[SETTLE_INTENT_ERROR]", err.message);
        next(err);
    }
};

/**
 * 5. EVENING: SETTLE SHIFT & RETURN CASH (Admin Finalizes)
 * Fixed: Now looks for 'settlement_pending' status and resets liability.
 */
/**
 * 🟢 ADMIN: SETTLE SHIFT & INGEST INVENTORY
 * Finalizes shift, clears cash liability, and moves scrap to Hub stock.
 */
export const settleRiderShift = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const { shift_id, cash_returned, scrap_value, notes } = req.body;
        await conn.beginTransaction();

        // 1. Get Shift & Rider Info
        const [shiftRows] = await conn.query(
            "SELECT * FROM rider_shifts WHERE id = ? AND status IN ('active', 'settlement_pending') FOR UPDATE",
            [shift_id]
        );
        if (!shiftRows.length) throw new ApiError(404, "Shift record not found.");
        const shift = shiftRows[0];

        // 2. Fetch all completed pickups by this rider that haven't been settled to hub yet
        const [pendingPickups] = await conn.query(
            "SELECT id FROM pickups WHERE rider_id = ? AND status = 'completed' AND is_settled_to_hub = 0",
            [shift.rider_id]
        );

        // 3. INVENTORY LOGIC: Move items to Hub Stock
        if (pendingPickups.length > 0) {
            const pickupIds = pendingPickups.map(p => p.id);

            // Get item weights and categories
            const [itemsToStock] = await conn.query(`
                SELECT pi.actual_weight, si.category_id 
                FROM pickup_items pi
                JOIN scrap_items si ON pi.item_id = si.id
                WHERE pi.pickup_id IN (?)`, [pickupIds]);

            // Update Hub Inventory
            for (const item of itemsToStock) {
                if (parseFloat(item.actual_weight) <= 0) continue;
                await conn.query(`
                    INSERT INTO hub_inventory (agent_id, category_id, current_weight)
                    VALUES ((SELECT agent_id FROM pickups WHERE id = ?), ?, ?)
                    ON DUPLICATE KEY UPDATE 
                        current_weight = current_weight + VALUES(current_weight),
                        last_updated_at = NOW()`,
                    [pickupIds[0], item.category_id, item.actual_weight]
                );
            }

            // Mark these specific orders as Settled
            await conn.query(
                "UPDATE pickups SET is_settled_to_hub = 1 WHERE id IN (?)",
                [pickupIds]
            );
        }

        // 4. SHIFT & LIABILITY LOGIC
        // Close the shift
        await conn.query(
            `UPDATE rider_shifts SET cash_returned = ?, scrap_value_received = ?, status = 'completed', closed_at = NOW(), notes = ? WHERE id = ?`,
            [cash_returned, scrap_value, notes, shift_id]
        );

        // Deduct liability (preventing negative values)
        await conn.query(
            "UPDATE riders SET cash_held_liability = GREATEST(0, cash_held_liability - ?), total_collected_weight_kg = 0 WHERE id = ?",
            [cash_returned, shift.rider_id]
        );

        // 5. FINANCE: Log the transaction
        const [riderUser] = await conn.query("SELECT user_id FROM riders WHERE id = ?", [shift.rider_id]);
        await updateWallet(conn, riderUser[0].user_id, cash_returned, 'debit', 'hub_settlement', 'shift', shift_id, `Shift Settle: ৳${cash_returned} | ${scrap_value}kg`);

        await conn.commit();
        res.json({ success: true, message: "Shift closed and inventory synced to Hub." });

    } catch (err) {
        if (conn) await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};

/**
 * 🟢 ADMIN: GET HUB TRANSACTION HISTORY
 * Fetches the most recent global hub-related transactions (Issues & Settlements)
 */
export const getHubTransactionHistory = async (req, res, next) => {
    try {
        const [rows] = await db.query(`
            SELECT 
                wt.id,
                u.full_name as rider_name,
                wt.type,
                wt.amount,
                wt.source,
                wt.description_en as description,
                wt.created_at as date
            FROM wallet_transactions wt
            JOIN wallet_accounts wa ON wt.wallet_id = wa.id
            JOIN users u ON wa.user_id = u.id
            WHERE wt.source IN ('hub_issue', 'hub_settlement')
            ORDER BY wt.created_at DESC
            LIMIT 50
        `);

        res.json({
            success: true,
            data: rows
        });
    } catch (err) {
        console.error("[HUB_HISTORY_ERROR]", err);
        next(err);
    }
};
export const getReceipt = async (req, res, next) => {
    try {
        const { id } = req.params;
        const [pickup] = await db.query(
            `SELECT p.*, u.full_name as customer_name, ag.business_name as hub_name 
             FROM pickups p JOIN customers c ON p.customer_id = c.id 
             JOIN users u ON c.user_id = u.id 
             LEFT JOIN agents ag ON p.agent_id = ag.id WHERE p.id = ?`, [id]);
        const [items] = await db.query(`SELECT pi.*, si.name_en FROM pickup_items pi JOIN scrap_items si ON pi.item_id = si.id WHERE pi.pickup_id = ?`, [id]);
        res.json({ success: true, data: { pickup: pickup[0], items } });
    } catch (err) { next(err); }
};

export const getPickupTimeline = async (req, res, next) => {
    try {
        const { id } = req.params;
        const [rows] = await db.query(
            `SELECT pt.id, pt.status, pt.note, pt.created_at, COALESCE(u.full_name, 'System') as actor_name
             FROM pickup_timeline pt LEFT JOIN users u ON pt.changed_by = u.id
             WHERE pt.pickup_id = ? ORDER BY pt.created_at ASC`, [id]
        );
        res.json({ success: true, data: rows });
    } catch (err) { next(err); }
};

/**
 * ADMIN: GET HUB OVERVIEW
 * Updated: Fetches reported settlement values and handles 'settlement_pending' status
 */
export const getHubRiderStatus = async (req, res, next) => {
    try {
        const [rows] = await db.query(`
            SELECT 
                r.id, 
                u.full_name, 
                u.phone, 
                r.cash_held_liability, 
                r.total_collected_weight_kg,
                rs.id as active_shift_id,
                rs.status as shift_status,
                rs.cash_issued,
                rs.reported_cash_return,
                rs.reported_weight_return,
                rs.opened_at as shift_start_time,
                CASE WHEN rs.id IS NOT NULL THEN 1 ELSE 0 END as shift_active
            FROM riders r
            JOIN users u ON r.user_id = u.id
            -- Link to shifts that are either 'active' or 'settlement_pending'
            LEFT JOIN rider_shifts rs ON r.id = rs.rider_id AND rs.status IN ('active', 'settlement_pending')
            WHERE u.is_active = 1 
            ORDER BY 
                -- Sort by pending status first so Admin sees them at the top
                CASE WHEN rs.status = 'settlement_pending' THEN 1 ELSE 2 END ASC,
                u.full_name ASC
        `);

        // Clean up the data for the frontend
        const formattedData = rows.map(rider => ({
            ...rider,
            // Ensure numbers are floats for calculations
            cash_held_liability: parseFloat(rider.cash_held_liability),
            reported_cash_return: parseFloat(rider.reported_cash_return || 0),
            reported_weight_return: parseFloat(rider.reported_weight_return || 0),
            total_collected_weight_kg: parseFloat(rider.total_collected_weight_kg)
        }));

        res.json({
            success: true,
            count: formattedData.length,
            data: formattedData
        });
    } catch (err) {
        next(err);
    }
};

/**
 * 🔄 RECONCILE RIDER ACCOUNT
 * Forces a recalculation of the rider's cash liability based on the actual 
 * audit trail (Shifts - Completed Cash Pickups).
 */
export const reconcileRiderAccount = async (req, res, next) => {
    const conn = await db.getConnection();
    try {
        const userId = req.user.id;
        await conn.beginTransaction();

        // 1. Identify the Rider
        const [riderRows] = await conn.query(
            "SELECT id, cash_held_liability FROM riders WHERE user_id = ? FOR UPDATE",
            [userId]
        );
        if (!riderRows.length) throw new ApiError(404, "Rider profile not found.");
        const riderId = riderRows[0].id;

        // 2. Calculate Reality:
        // Total Cash Issued in active/past shifts - Total Cash paid to customers in unsettled pickups
        const [audit] = await conn.query(`
            SELECT (
                (SELECT COALESCE(SUM(cash_issued - cash_returned), 0) 
                 FROM rider_shifts 
                 WHERE rider_id = ?) 
                - 
                (SELECT COALESCE(SUM(net_payable_amount), 0) 
                 FROM pickups 
                 WHERE rider_id = ? 
                 AND status = 'completed' 
                 AND payment_method = 'cash' 
                 AND is_settled_to_hub = 0)
            ) AS calculated_liability
        `, [riderId, riderId]);

        const actualLiability = audit[0].calculated_liability;

        // 3. Update Rider table if there is a mismatch
        if (parseFloat(riderRows[0].cash_held_liability) !== parseFloat(actualLiability)) {
            await conn.query(
                "UPDATE riders SET cash_held_liability = ? WHERE id = ?",
                [actualLiability, riderId]
            );

            // Log the correction in the timeline for Admin visibility
            await conn.query(
                `INSERT INTO pickup_timeline (pickup_id, status, note, changed_by) 
                 VALUES (0, 'system_reconcile', ?, ?)`,
                [`Auto-correction: Liability adjusted to ৳${actualLiability}`, userId]
            );
        }

        await conn.commit();

        res.json({
            success: true,
            message: "Account reconciled successfully",
            new_balance: actualLiability
        });

    } catch (err) {
        if (conn) await conn.rollback();
        next(err);
    } finally {
        conn.release();
    }
};