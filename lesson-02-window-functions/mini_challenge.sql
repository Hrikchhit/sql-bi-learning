sql-- ============================================
-- Lesson 2: Mini BI Challenge
-- Scenario: Monthly sales trend + order rankings
-- Tool: MySQL 8.0
-- ============================================

-- -----------------------------------------------
-- PART A: Monthly trend summary
-- -----------------------------------------------
WITH monthly_trend AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m')                                              AS month,
        SUM(amount)                                                                   AS monthly_revenue,
        LAG(SUM(amount), 1) OVER (ORDER BY DATE_FORMAT(order_date, '%Y-%m'))         AS prev_month_revenue,
        SUM(amount) - LAG(SUM(amount), 1) OVER (ORDER BY DATE_FORMAT(order_date, '%Y-%m')) AS mom_change,
        CASE
            WHEN SUM(amount) - LAG(SUM(amount), 1) OVER (ORDER BY DATE_FORMAT(order_date, '%Y-%m')) > 0 THEN 'Growth'
            WHEN SUM(amount) - LAG(SUM(amount), 1) OVER (ORDER BY DATE_FORMAT(order_date, '%Y-%m')) < 0 THEN 'Decline'
            ELSE 'First Month'
        END AS trend
    FROM orders
    WHERE status = 'completed'
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
),

-- -----------------------------------------------
-- PART B: Order rankings within each month
-- -----------------------------------------------
order_ranking AS (
    SELECT
        order_id,
        customer_id,
        order_date,
        amount,
        DENSE_RANK() OVER (
            PARTITION BY DATE_FORMAT(order_date, '%Y-%m')
            ORDER BY amount DESC
        ) AS order_rank
    FROM orders
    WHERE status = 'completed'
)

-- -----------------------------------------------
-- COMBINED: Join both CTEs into one report
-- -----------------------------------------------
SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    o.amount,
    o.order_rank,
    m.monthly_revenue,
    m.mom_change,
    m.trend
FROM order_ranking o
JOIN monthly_trend m
    ON DATE_FORMAT(o.order_date, '%Y-%m') = m.month
ORDER BY o.order_date;
