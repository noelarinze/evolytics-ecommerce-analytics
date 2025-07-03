--Daily cohort retention matrix: signup day vs days retained
WITH signup_dates AS (
    SELECT
        user_id,
        signup_date::date AS cohort_day
    FROM users
),
activity_dates AS (
    SELECT
        user_id,
        event_time::date AS active_day
    FROM events
    GROUP BY user_id, event_time::date
),
days_active AS (
    SELECT
        s.user_id,
        s.cohort_day,
        a.active_day,
        (a.active_day - s.cohort_day) AS day_number
    FROM signup_dates s
    JOIN activity_dates a ON s.user_id = a.user_id
    WHERE a.active_day >= s.cohort_day
),
retention_raw AS (
    SELECT
        cohort_day,
        day_number,
        COUNT(DISTINCT user_id) AS retained_users
    FROM days_active
    WHERE day_number BETWEEN 0 AND 30  -- limit to first 30 days
    GROUP BY cohort_day, day_number
),
cohort_sizes AS (
    SELECT
        signup_date::date AS cohort_day,
        COUNT(DISTINCT user_id) AS cohort_size
    FROM users
    GROUP BY signup_date::date
),
retention_rates AS (
    SELECT
        r.cohort_day,
        r.day_number,
        ROUND(100.0 * r.retained_users / c.cohort_size, 1) AS retention_rate
    FROM retention_raw r
    JOIN cohort_sizes c ON r.cohort_day = c.cohort_day
)
-- 👇 Pivot-style output: each day becomes a column
SELECT
    cohort_day,
    MAX(CASE WHEN day_number = 0 THEN retention_rate ELSE NULL END) AS day_0,
    MAX(CASE WHEN day_number = 1 THEN retention_rate ELSE NULL END) AS day_1,
    MAX(CASE WHEN day_number = 2 THEN retention_rate ELSE NULL END) AS day_2,
    MAX(CASE WHEN day_number = 3 THEN retention_rate ELSE NULL END) AS day_3,
    MAX(CASE WHEN day_number = 7 THEN retention_rate ELSE NULL END) AS day_7,
    MAX(CASE WHEN day_number = 14 THEN retention_rate ELSE NULL END) AS day_14,
    MAX(CASE WHEN day_number = 30 THEN retention_rate ELSE NULL END) AS day_30
FROM retention_rates
GROUP BY cohort_day
ORDER BY cohort_day;
