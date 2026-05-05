sql-- ============================================
-- Lesson 3: Mini BI Challenge
-- Scenario: Monthly performance summary for manager
-- Tool: MySQL 8.0
-- ============================================

WITH completed_cancelled AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m')                                 AS month,
        SUM(CASE WHEN status = 'completed' THEN amount ELSE 0 END)      AS completed_revenue,
        SUM(CASE WHEN status = 'cancelled' THEN amount ELSE 0 END)      AS cancelled_revenue,
        ROUND(
            COUNT(CASE WHEN status = 'completed' THEN 1 END) /
            COUNT(order_id) * 100
        , 1)                                                              AS completion_rate
    FROM orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
),
prev_month_comparison AS (
    SELECT *,
        LAG(completed_revenue, 1) OVER (ORDER BY month)                  AS prev_month_revenue,
        completed_revenue - LAG(completed_revenue, 1) OVER (ORDER BY month) AS mom_change,
        RANK() OVER (ORDER BY completed_revenue DESC)                    AS month_rank
    FROM completed_cancelled
),
best_month AS (
    SELECT *,
        CASE
            WHEN month_rank = 1 THEN 'Yes'
            ELSE 'No'
        END AS is_best_month
    FROM prev_month_comparison
)
SELECT
    month,
    completed_revenue,
    cancelled_revenue,
    completion_rate,
    prev_month_revenue,
    mom_change,
    is_best_month
FROM best_month
ORDER BY month;
