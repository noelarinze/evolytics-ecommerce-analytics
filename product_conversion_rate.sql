-- Conversion rate per product with fallback for missing product names
WITH views AS (
    SELECT
        product_id,
        COUNT(DISTINCT user_id) AS product_views
    FROM events
    WHERE event_type = 'view_product'
    GROUP BY product_id
),
purchases AS (
    SELECT
        product_id,
        COUNT(DISTINCT user_id) AS product_purchases
    FROM events
    WHERE event_type = 'purchase'
    GROUP BY product_id
)
SELECT
    v.product_id,
    COALESCE(pr.product_name, 'Unknown') AS product_name,
    COALESCE(pr.category, 'Unknown') AS category,
    v.product_views,
    COALESCE(p.product_purchases, 0) AS product_purchases,
    ROUND(
        COALESCE(p.product_purchases::decimal, 0) / NULLIF(v.product_views, 0),
        3
    ) AS conversion_rate
FROM views v
LEFT JOIN purchases p ON v.product_id = p.product_id
LEFT JOIN products pr ON v.product_id = pr.product_id
ORDER BY conversion_rate DESC;
