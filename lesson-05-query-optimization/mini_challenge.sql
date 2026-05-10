sql-- ============================================
-- Lesson 5: Mini BI Challenge
-- Scenario: Optimise slow monthly revenue report
-- Tool: MySQL 8.0
-- ============================================

-- Original slow query had these issues:
-- 1. SELECT DISTINCT * — unnecessary, fetches all columns
-- 2. YEAR(order_date) — breaks index, use date range
-- 3. customer_id != NULL — never works, use IS NOT NULL
-- 4. HAVING SUM(amount) > 0 — unnecessary overhead
-- 5. No running total or best month flag

-- Optimised version:
WITH monthly_totals AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(amount)                      AS monthly_revenue
    FROM orders
    WHERE status = 'completed'
      AND order_date >= '2024-01-01'
      AND order_date < '2025-01-01'
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
),
running_rank AS (
    SELECT *,
        SUM(monthly_revenue) OVER (ORDER BY month) AS running_totals,
        RANK() OVER (ORDER BY monthly_revenue DESC) AS month_rank
    FROM monthly_totals
),
rank_month AS (
    SELECT *,
        CASE WHEN month_rank = 1 THEN 'Yes'
             ELSE 'No'
        END AS best_month
    FROM running_rank
)
SELECT
    month,
    monthly_revenue,
    running_totals,
    best_month
FROM rank_month;
