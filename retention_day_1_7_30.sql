-- Retention rates at Day 1, 7, and 30 based on signup date
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
days_between AS (
    SELECT
        s.user_id,
        s.cohort_day,
        a.active_day,
        (a.active_day - s.cohort_day) AS days_since_signup
    FROM signup_dates s
    JOIN activity_dates a ON s.user_id = a.user_id
),
retention_flags AS (
    SELECT
        cohort_day,
        COUNT(DISTINCT CASE WHEN days_since_signup = 1 THEN user_id END) AS day_1_retained,
        COUNT(DISTINCT CASE WHEN days_since_signup = 7 THEN user_id END) AS day_7_retained,
        COUNT(DISTINCT CASE WHEN days_since_signup = 30 THEN user_id END) AS day_30_retained,
        COUNT(DISTINCT user_id) AS total_users
    FROM days_between
    GROUP BY cohort_day
)
SELECT
    cohort_day,
    total_users,
    day_1_retained,
    ROUND(100.0 * day_1_retained / total_users, 2) AS day_1_retention_rate,
    day_7_retained,
    ROUND(100.0 * day_7_retained / total_users, 2) AS day_7_retention_rate,
    day_30_retained,
    ROUND(100.0 * day_30_retained / total_users, 2) AS day_30_retention_rate
FROM retention_flags
ORDER BY cohort_day;
