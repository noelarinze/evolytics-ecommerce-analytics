--Repeat buyer analysis: users who purchased more than once
WITH purchases AS (
    SELECT
        user_id,
        COUNT(*) AS total_purchases,
        MIN(event_time::date) AS first_purchase_date,
        MAX(event_time::date) AS last_purchase_date
    FROM events
    WHERE event_type = 'purchase'
    GROUP BY user_id
)
SELECT
    user_id,
    total_purchases,
    first_purchase_date,
    last_purchase_date,
    (last_purchase_date - first_purchase_date) AS purchase_span_days,
    CASE 
        WHEN total_purchases = 1 THEN 'One-time buyer'
        WHEN total_purchases BETWEEN 2 AND 4 THEN 'Occasional buyer'
        ELSE 'Frequent buyer'
    END AS buyer_segment
FROM purchases
ORDER BY total_purchases DESC;
