-- 👇 Count unique users at each funnel step, grouped by device type
SELECT
    device,                -- Device type: Mobile, Desktop, or Tablet
    event_type,            -- Funnel step: view, add_to_cart, etc.
    COUNT(DISTINCT e.user_id) AS unique_users -- Count of users at that step
FROM
    events e
JOIN
    users u ON e.user_id = u.user_id  -- Join to get device info from users table
WHERE
    event_type IN ('view_product', 'add_to_cart', 'start_checkout', 'purchase')
GROUP BY
    device, event_type
ORDER BY
    device,
    CASE event_type
        WHEN 'view_product' THEN 1
        WHEN 'add_to_cart' THEN 2
        WHEN 'start_checkout' THEN 3
        WHEN 'purchase' THEN 4
    END;

