sql-- ============================================
-- Lesson 6: Mini BI Challenge
-- Scenario: Comprehensive business performance report
-- Tool: MySQL 8.0
-- ============================================


-- -----------------------------------------------
-- PART A: Monthly trend report
-- -----------------------------------------------
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(amount)                       AS revenue
    FROM orders
    WHERE status = 'completed'
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
),
yoy_comparison AS (
    SELECT
        month,
        revenue                                                    AS monthly_revenue,
        ROUND(AVG(revenue) OVER (
            ORDER BY month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2)                                                      AS moving_avg_3month,
        SUM(revenue) OVER (ORDER BY month)                        AS running_total,
        LAG(revenue, 12) OVER (ORDER BY month)                    AS prev_year_revenue,
        revenue - LAG(revenue, 12) OVER (ORDER BY month)          AS yoy_change,
        DENSE_RANK() OVER (ORDER BY revenue DESC)                 AS rank_1
    FROM monthly_revenue
),
ranking_3 AS (
    SELECT *,
        CASE WHEN rank_1 <= 3 THEN 'Yes'
             ELSE 'No'
        END AS is_top_3
    FROM yoy_comparison
)
SELECT
    month,
    monthly_revenue,
    moving_avg_3month,
    running_total,
    prev_year_revenue,
    yoy_change,
    is_top_3
FROM ranking_3
ORDER BY month;


-- -----------------------------------------------
-- PART B: Customer funnel
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
