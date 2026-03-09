import ApiError from "../utils/ApiError.js";
import db from "../config/db.js";

export const getMarketOverview = async (req, res, next) => {
    try {
        // 1. Extract categoryId AND lang (default to 'bn')
        const { categoryId, lang = 'bn' } = req.query;

        // 2. Select columns dynamically based on language
        // We alias them simply as 'name' and 'category' so the frontend logic remains static
        const nameColumn = lang === 'en' ? 'si.name_en' : 'si.name_bn';
        const categoryColumn = lang === 'en' ? 'sc.name_en' : 'sc.name_bn';

        let sql = `
            SELECT 
                si.id, 
                ${nameColumn} as name, 
                si.unit, 
                si.current_min_rate,
                si.current_max_rate,
                si.category_id,
                si.image_url,
                ${categoryColumn} as category,
                -- Subquery for price difference
                (SELECT (new_min_price - old_min_price) 
                 FROM scrap_price_history 
                 WHERE scrap_item_id = si.id 
                 ORDER BY changed_at DESC LIMIT 1) as price_diff,
                -- Subquery for percentage change
                (SELECT ((new_min_price - old_min_price) / NULLIF(old_min_price, 0)) * 100 
                 FROM scrap_price_history 
                 WHERE scrap_item_id = si.id 
                 ORDER BY changed_at DESC LIMIT 1) as change_percentage
            FROM scrap_items si
            JOIN scrap_categories sc ON si.category_id = sc.id
            WHERE si.is_active = 1
        `;

        const queryParams = [];

        if (categoryId && categoryId !== 'all') {
            sql += ` AND si.category_id = ?`;
            queryParams.push(categoryId);
        }

        sql += ` ORDER BY name ASC`;

        const [items] = await db.query(sql, queryParams);

        const getFullUrl = (path) => {
            if (!path) return null;
            return path.startsWith('http') ? path : `${process.env.BASE_URL || 'https://webapp.prosfata.space'}${path}`;
        };

        // 3. Format the data for strict Frontend consumption
        const formattedData = items.map(item => {
            // CRITICAL: Convert to Number here so frontend calculations (maxEarn) work immediately
            const minRate = parseFloat(item.current_min_rate || 0);
            const maxRate = parseFloat(item.current_max_rate || 0);
            const diff = parseFloat(item.price_diff || 0);
            const changePercent = parseFloat(item.change_percentage || 0);

            return {
                id: item.id,
                name: item.name || (lang === 'en' ? 'Unnamed Item' : 'নামহীন আইটেম'),
                category: item.category || (lang === 'en' ? 'General' : 'সাধারণ'),
                category_id: item.category_id,
                unit: item.unit,
                product_image: getFullUrl(item.image_url),
                // We provide 'price' as the main display value (usually the max rate for selling)
                price: maxRate,
                current_min_rate: minRate,
                current_max_rate: maxRate,
                trend: diff > 0 ? 'up' : diff < 0 ? 'down' : 'stable',
                change: changePercent.toFixed(1)
            };
        });

        res.json({
            success: true,
            lang: lang,
            count: formattedData.length,
            data: formattedData
        });

    } catch (err) {
        console.error("Market Overview Error:", err);
        next(err);
    }
};