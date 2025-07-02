SELECT
    event_type,
    COUNT(DISTINCT user_id) AS unique_users
FROM events
WHERE event_type IN ('view_product', 'add_to_cart', 'start_checkout', 'purchase')
GROUP BY event_type
ORDER BY
    CASE event_type
        WHEN 'view_product' THEN 1
        WHEN 'add_to_cart' THEN 2
        WHEN 'start_checkout' THEN 3
        WHEN 'purchase' THEN 4
    END;
