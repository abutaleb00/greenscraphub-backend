import ApiError from "../utils/ApiError.js";
import db from "../config/db.js";

export const getMarketOverview = async (req, res, next) => {
    try {
        // 1. Extract optional filter from query string
        const { categoryId } = req.query;

        // 2. Build the base query
        let sql = `
            SELECT 
                si.id, 
                si.name_en, 
                si.unit, 
                si.current_min_rate as price,
                si.category_id,
                si.image_url, -- Make sure this column name matches your 'scrap_items' table
                sc.name_en as category,
                -- Subquery to find the most recent price difference
                (SELECT (new_min_price - old_min_price) 
                 FROM scrap_price_history 
                 WHERE scrap_item_id = si.id 
                 ORDER BY changed_at DESC LIMIT 1) as price_diff,
                -- Subquery to calculate the percentage change
                (SELECT ((new_min_price - old_min_price) / old_min_price) * 100 
                 FROM scrap_price_history 
                 WHERE scrap_item_id = si.id 
                 ORDER BY changed_at DESC LIMIT 1) as change_percentage
            FROM scrap_items si
            JOIN scrap_categories sc ON si.category_id = sc.id
            WHERE si.is_active = 1
        `;

        const queryParams = [];

        // 3. Add dynamic filter if categoryId is provided
        if (categoryId && categoryId !== 'all') {
            sql += ` AND si.category_id = ?`;
            queryParams.push(categoryId);
        }

        // 4. Grouping/Ordering
        sql += ` ORDER BY si.name_en ASC`;

        const [items] = await db.query(sql, queryParams);

        // Helper to format the full image URL
        const getFullUrl = (path) => {
            if (!path) return null;
            return path.startsWith('http') ? path : `${process.env.BASE_URL || 'http://localhost:4000'}${path}`;
        };

        // 5. Format the data for the Frontend
        const formattedData = items.map(item => ({
            ...item,
            product_image: getFullUrl(item.image_url),
            price: parseFloat(item.price || 0).toFixed(2),
            trend: (item.price_diff || 0) > 0 ? 'up' : (item.price_diff || 0) < 0 ? 'down' : 'stable',
            change: parseFloat(item.change_percentage || 0).toFixed(1)
        }));

        res.json({
            success: true,
            count: formattedData.length,
            data: formattedData
        });

    } catch (err) {
        console.error("Market Overview Error:", err);
        next(err);
    }
};