-- 👇 Funnel analysis segmented by user country
SELECT
    u.country,             -- User's country (from users table)
    e.event_type,          -- Funnel step (from events table)
    COUNT(DISTINCT e.user_id) AS unique_users  -- Unique users at each step
FROM
    events e
JOIN
    users u ON e.user_id = u.user_id  -- Join to access country
WHERE
    e.event_type IN ('view_product', 'add_to_cart', 'start_checkout', 'purchase')
GROUP BY
    u.country, e.event_type
ORDER BY
    u.country,
    CASE e.event_type
        WHEN 'view_product' THEN 1
        WHEN 'add_to_cart' THEN 2
        WHEN 'start_checkout' THEN 3
        WHEN 'purchase' THEN 4
    END;
