import db from "../../config/db.js";
import ApiError from "../../utils/ApiError.js";

const updateWallet = async (conn, userId, amount, type, source, refType, refId, descEn) => {
    // 1. Prevent Double Processing: Check if this reference transaction already exists
    const [existing] = await conn.query(
        "SELECT id FROM wallet_transactions WHERE reference_type = ? AND reference_id = ? AND source = ?",
        [refType, refId, source]
    );
    if (existing.length > 0) return;

    // 2. Fetch Wallet with Row Lock (FOR UPDATE) to prevent race conditions
    let [wallet] = await conn.query(
        "SELECT id, balance FROM wallet_accounts WHERE user_id = ? FOR UPDATE",
        [userId]
    );

    if (!wallet.length) {
        const [ins] = await conn.query(
            "INSERT INTO wallet_accounts (user_id, balance) VALUES (?, 0)",
            [userId]
        );
        wallet = [{ id: ins.insertId, balance: 0 }];
    }

    const balanceBefore = parseFloat(wallet[0].balance);
    const balanceAfter = type === 'credit' ? balanceBefore + amount : balanceBefore - amount;

    // 3. Update Balance
    await conn.query(
        "UPDATE wallet_accounts SET balance = ?, updated_at = NOW() WHERE id = ?",
        [balanceAfter, wallet[0].id]
    );

    // 4. Log Transaction
    await conn.query(
        `INSERT INTO wallet_transactions 
        (wallet_id, type, source, reference_type, reference_id, amount, balance_before, balance_after, description_en, status) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'completed')`,
        [wallet[0].id, type, source, refType, refId, amount, balanceBefore, balanceAfter, descEn]
    );
};

/**
 * GET PICKUP DETAILS
 * Provides a comprehensive view of a single pickup for the UI
 */
export const getPickupDetails = async (req, res, next) => {
    try {
        const { id } = req.params;

        // 1. Fetch main pickup info with Customer, Rider, Hub, and Address details
        const [pickupRows] = await db.query(
            `SELECT 
                p.*, 
                u.full_name as customer_name, 
                u.phone as customer_phone, 
                r_u.full_name as rider_name,
                r_u.phone as rider_phone,
                ag.business_name as hub_name,
                addr.address_line,
                addr.house_no,
                addr.road_no,
                addr.landmark
             FROM pickups p 
             JOIN customers c ON p.customer_id = c.id 
             JOIN users u ON c.user_id = u.id
             LEFT JOIN riders r ON p.rider_id = r.id 
             LEFT JOIN users r_u ON r.user_id = r_u.id
             LEFT JOIN agents ag ON p.agent_id = ag.id
             LEFT JOIN addresses addr ON p.customer_address_id = addr.id
             WHERE p.id = ?`, 
            [id]
        );

        if (!pickupRows.length) {
            throw new ApiError(404, "Pickup request not found");
        }

        const pickup = pickupRows[0];

        // Helper to format full URLs for images (handles both local paths and external links)
        const getFullUrl = (path) => {
            if (!path) return null;
            if (path.startsWith('http')) return path;
            const baseUrl = process.env.BASE_URL || 'http://localhost:4000';
            // Ensure single leading slash
            const cleanPath = path.startsWith('/') ? path : `/${path}`;
            return `${baseUrl.replace(/\/$/, "")}${cleanPath}`;
        };

        // 2. Fetch Itemized List with Catalog Images (Product Images)
        const [items] = await db.query(
            `SELECT 
                pi.*, 
                si.name_en, 
                si.name_bn, 
                si.unit,
                si.image_url as product_image
             FROM pickup_items pi 
             JOIN scrap_items si ON pi.item_id = si.id 
             WHERE pi.pickup_id = ?`,
            [id]
        );

        // Transform items to handle user-uploaded photos and catalog images
        const transformedItems = items.map(item => {
            let userPhotos = [];
            
            // Handle photo_url stored in pickup_items (User uploads from checkout)
            if (item.photo_url) {
                try {
                    // Try to parse if it's a JSON string, otherwise wrap in array
                    const parsed = typeof item.photo_url === 'string' 
                        ? JSON.parse(item.photo_url) 
                        : item.photo_url;
                    
                    userPhotos = Array.isArray(parsed) 
                        ? parsed.map(p => getFullUrl(p)) 
                        : [getFullUrl(parsed)];
                } catch (e) {
                    // Fallback for plain string paths
                    userPhotos = [getFullUrl(item.photo_url)];
                }
            }

            return {
                ...item,
                product_image: getFullUrl(item.product_image), // Image from catalog
                user_photos: userPhotos // Proof images uploaded by user
            };
        });

        // 3. Fetch Event Timeline with Changer Name
        const [timeline] = await db.query(
            `SELECT 
                pt.*, 
                u.full_name as changer_name
             FROM pickup_timeline pt
             LEFT JOIN users u ON pt.changed_by = u.id
             WHERE pt.pickup_id = ? 
             ORDER BY pt.created_at DESC`, // Latest updates first
            [id]
        );

        // 4. Transform top-level pickup images (proof_image_before/after)
        pickup.proof_image_before = getFullUrl(pickup.proof_image_before);
        pickup.proof_image_after = getFullUrl(pickup.proof_image_after);

        // Final Response
        res.json({
            success: true,
            data: {
                pickup: pickup,
                items: transformedItems,
                timeline: timeline
            }
        });

    } catch (err) {
        console.error("Detailed Pickup Error:", err);
        next(err);
    }
};

export const completePickup = async (req, res, next) => {
    const conn = await db.getConnection();
    const { id: pickupId } = req.params;

    // items should be: [{ id: pickup_item_id, actual_weight: 10.5, final_rate: 45 }]
    const { items, payment_method, note } = req.body;

    try {
        await conn.beginTransaction();

        // 1. Fetch Master Record with Locks
        const [p] = await conn.query(`
            SELECT p.*, c.user_id as customer_uid, r.user_id as rider_uid, a.owner_user_id as agent_uid 
            FROM pickups p
            JOIN customers c ON p.customer_id = c.id
            LEFT JOIN riders r ON p.rider_id = r.id
            LEFT JOIN agents a ON p.agent_id = a.id
            WHERE p.id = ? FOR UPDATE`, [pickupId]);

        if (!p.length) throw new ApiError(404, "Pickup request not found.");
        if (p[0].status === 'completed') throw new ApiError(400, "This pickup is already finalized.");

        const pickup = p[0];

        // 2. Fetch System Commission Settings (Optional but recommended)
        // Defaulting to your logic if settings table doesn't exist yet
        const adminCommRate = 0.05; // 5%
        const agentCommRate = 0.05; // 5%
        const riderCommRate = 0.02; // 2% incentive

        let netPayable = 0;
        let totalWeight = 0;
        const parsedItems = typeof items === 'string' ? JSON.parse(items) : items;

        // 3. Process Verified Weights
        for (const it of parsedItems) {
            const weight = parseFloat(it.actual_weight) || 0;
            const rate = parseFloat(it.final_rate) || 0;
            const itemSubtotal = weight * rate;

            netPayable += itemSubtotal;
            totalWeight += weight;

            await conn.query(
                `UPDATE pickup_items SET 
                    actual_weight = ?, 
                    final_rate_per_unit = ?, 
                    final_amount = ?, 
                    updated_at = NOW() 
                 WHERE id = ? AND pickup_id = ?`,
                [weight, rate, itemSubtotal, it.id, pickupId]
            );
        }

        // 4. Calculate Commissions
        const adminComm = netPayable * adminCommRate;
        const agentComm = netPayable * agentCommRate;
        const riderComm = netPayable * riderCommRate;

        // 5. Financial Settlement (Wallets)
        // Credit Agent Commission
        if (pickup.agent_uid) {
            await updateWallet(conn, pickup.agent_uid, agentComm, 'credit', 'pickup_commission', 'pickup', pickupId,
                `Commission for Shipment #${pickup.booking_code}`);
        }

        // Credit Rider Incentive
        if (pickup.rider_uid) {
            await updateWallet(conn, pickup.rider_uid, riderComm, 'credit', 'pickup_commission', 'pickup', pickupId,
                `Incentive for Shipment #${pickup.booking_code}`);
        }

        // Credit Customer (Only if payment method is wallet)
        if (payment_method === 'wallet') {
            await updateWallet(conn, pickup.customer_uid, netPayable, 'credit', 'pickup_payment', 'pickup', pickupId,
                `Payment for Shipment #${pickup.booking_code}`);
        }

        // 6. Finalize Master Record
        const proofImage = req.file ? `/uploads/pickups/${req.file.filename}` : null;

        await conn.query(
            `UPDATE pickups SET 
                status = 'completed', 
                actual_weight_kg = ?, 
                net_payable_amount = ?, 
                admin_commission_amount = ?, 
                agent_commission_amount = ?, 
                rider_commission_amount = ?,
                payment_method = ?, 
                payment_status = ?,
                proof_image_after = ?, 
                completed_at = NOW(),
                updated_at = NOW()
            WHERE id = ?`,
            [
                totalWeight,
                netPayable,
                adminComm,
                agentComm,
                riderComm,
                payment_method,
                (payment_method === 'wallet' ? 'paid' : 'pending'),
                proofImage,
                pickupId
            ]
        );

        // 7. Log Final Timeline Event
        await conn.query(
            `INSERT INTO pickup_timeline (pickup_id, status, note, created_at) 
             VALUES (?, 'completed', ?, NOW())`,
            [pickupId, note || 'Shipment verified and finalized by rider']
        );

        await conn.commit();

        res.json({
            success: true,
            message: "Shipment finalized successfully!",
            total_weight: totalWeight,
            net_amount: netPayable
        });

    } catch (err) {
        await conn.rollback();
        console.error("Settlement Error:", err);
        next(err);
    } finally {
        conn.release();
    }
};

export const getReceipt = async (req, res, next) => {
    try {
        const { id } = req.params;
        const [pickup] = await db.query(`
            SELECT p.*, u.full_name as customer_name, ag.business_name as hub_name
            FROM pickups p 
            JOIN customers c ON p.customer_id = c.id 
            JOIN users u ON c.user_id = u.id
            LEFT JOIN agents ag ON p.agent_id = ag.id
            WHERE p.id = ? AND p.status = 'completed'`, [id]);

        if (!pickup.length) throw new ApiError(404, "Receipt not available.");

        const [items] = await db.query(
            `SELECT pi.*, si.name_en 
             FROM pickup_items pi 
             JOIN scrap_items si ON pi.item_id = si.id 
             WHERE pi.pickup_id = ?`, [id]);

        res.json({ success: true, data: { pickup: pickup[0], items } });
    } catch (err) {
        next(err);
    }
};