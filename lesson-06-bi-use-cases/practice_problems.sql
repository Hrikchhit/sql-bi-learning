sql-- ============================================
-- Lesson 6: BI Use Cases — Practice Problems
-- Tool: MySQL 8.0
-- ============================================


-- -----------------------------------------------
-- PATTERN 1: Year over Year comparison (LAG approach)
-- -----------------------------------------------
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(amount)                       AS revenue
    FROM orders
    WHERE status = 'completed'
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
),
yoy AS (
    SELECT
        month,
        revenue,
        LAG(revenue, 12) OVER (ORDER BY month)                AS prev_revenue,
        revenue - LAG(revenue, 12) OVER (ORDER BY month)      AS yoy_change,
        ROUND(
            (revenue - LAG(revenue, 12) OVER (ORDER BY month))
            / LAG(revenue, 12) OVER (ORDER BY month) * 100
        , 2)                                                   AS yoy_pct_change
    FROM monthly_revenue
)
SELECT * FROM yoy
ORDER BY month;


-- -----------------------------------------------
-- PATTERN 2: Cohort Analysis
-- -----------------------------------------------
WITH first_order AS (
    SELECT
        customer_id,
        MIN(DATE_FORMAT(order_date, '%Y-%m')) AS cohort_month
    FROM orders
    WHERE status = 'completed'
    GROUP BY customer_id
),
cohort_activity AS (
    SELECT
        f.customer_id,
        f.cohort_month,
        DATE_FORMAT(o.order_date, '%Y-%m') AS activity_month
    FROM first_order f
    JOIN orders o ON f.customer_id = o.customer_id
    WHERE o.status = 'completed'
),
cohort_size AS (
    SELECT cohort_month, COUNT(DISTINCT customer_id) AS cohort_customers
    FROM first_order
    GROUP BY cohort_month
)
SELECT
    ca.cohort_month,
    ca.activity_month,
    COUNT(DISTINCT ca.customer_id)                      AS active_customers,
    cs.cohort_customers                                 AS original_cohort_size,
    ROUND(
        COUNT(DISTINCT ca.customer_id)
        / cs.cohort_customers * 100
    , 1)                                                AS retention_pct
FROM cohort_activity ca
JOIN cohort_size cs ON ca.cohort_month = cs.cohort_month
GROUP BY ca.cohort_month, ca.activity_month, cs.cohort_customers
ORDER BY ca.cohort_month, ca.activity_month;


-- -----------------------------------------------
-- PATTERN 3: Retention Analysis
-- -----------------------------------------------
WITH distinct_customers AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        customer_id
    FROM orders
    WHERE status = 'completed'
    GROUP BY DATE_FORMAT(order_date, '%Y-%m'), customer_id
),
retention AS (
    SELECT
        curr.month,
        COUNT(DISTINCT curr.customer_id)       AS current_customers,
        COUNT(DISTINCT next_month.customer_id) AS retained_customers
    FROM distinct_customers curr
    LEFT JOIN distinct_customers next_month
        ON curr.customer_id = next_month.customer_id
        AND next_month.month = DATE_FORMAT(
            DATE_ADD(
                STR_TO_DATE(CONCAT(curr.month, '-01'), '%Y-%m-%d'),
                INTERVAL 1 MONTH
            ), '%Y-%m')
    GROUP BY curr.month
)
SELECT
    month,
    current_customers,
    retained_customers,
    ROUND(retained_customers / current_customers * 100, 1) AS retention_rate
FROM retention
ORDER BY month;


-- -----------------------------------------------
-- PATTERN 4: Funnel Analysis
-- -----------------------------------------------
SELECT
    COUNT(DISTINCT customer_id)                                    AS total_customers,
    COUNT(DISTINCT CASE WHEN status = 'completed'
          THEN customer_id END)                                    AS completed_customers,
    COUNT(DISTINCT CASE WHEN status = 'completed'
          AND amount > 400 THEN customer_id END)                   AS high_value_customers,
    ROUND(COUNT(DISTINCT CASE WHEN status = 'completed'
          THEN customer_id END)
          / COUNT(DISTINCT customer_id) * 100, 1)                 AS completion_rate,
    ROUND(COUNT(DISTINCT CASE WHEN status = 'completed'
          AND amount > 400 THEN customer_id END)
          / COUNT(DISTINCT CASE WHEN status = 'completed'
          THEN customer_id END) * 100, 1)                         AS high_value_rate
FROM orders;


-- -----------------------------------------------
-- PATTERN 5: Moving Averages
-- -----------------------------------------------
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(amount)                       AS monthly_revenue
    FROM orders
    WHERE status = 'completed'
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT
    month,
    monthly_revenue,
    ROUND(AVG(monthly_revenue) OVER (
        ORDER BY month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2)                                               AS moving_avg_3month,
    ROUND(AVG(monthly_revenue) OVER (
        ORDER BY month
        ROWS BETWEEN 5 PRECEDING AND CURRENT ROW
    ), 2)                                               AS moving_avg_6month,
    SUM(monthly_revenue) OVER (ORDER BY month)          AS running_total
FROM monthly_revenue;
