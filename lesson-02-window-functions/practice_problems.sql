sql-- ============================================
-- Lesson 2: Window Functions — Practice Problems
-- Tool: MySQL 8.0
-- ============================================


-- -----------------------------------------------
-- PROBLEM 1: Rank completed orders by amount
-- -----------------------------------------------
-- Same rank for ties, no gaps after tied ranks
SELECT 
    order_id,
    customer_id,
    amount,
    DENSE_RANK() OVER (ORDER BY amount DESC) AS amount_rank
FROM orders
WHERE status = 'completed';


-- -----------------------------------------------
-- PROBLEM 2: Monthly revenue with MoM change
-- -----------------------------------------------
WITH monthly_totals AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(amount)                      AS monthly_revenue
    FROM orders
    WHERE status = 'completed'
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
),
mom AS (
    SELECT
        month,
        monthly_revenue,
        LAG(monthly_revenue, 1) OVER (ORDER BY month) AS prev_month_revenue,
        monthly_revenue - LAG(monthly_revenue, 1) OVER (ORDER BY month) AS mom_change
    FROM monthly_totals
)
SELECT * FROM mom;


-- -----------------------------------------------
-- PROBLEM 3: Running total + % of customer spend
-- -----------------------------------------------
SELECT
    order_id,
    customer_id,
    order_date,
    amount,
    SUM(amount) OVER (ORDER BY order_date)                                    AS running_total,
    ROUND(amount / SUM(amount) OVER (PARTITION BY customer_id) * 100, 1)     AS pct_of_customer_spend
FROM orders
WHERE status = 'completed'
ORDER BY order_date;
