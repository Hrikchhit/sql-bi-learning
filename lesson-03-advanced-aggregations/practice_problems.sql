sql-- ============================================
-- Lesson 3: Advanced Aggregations — Practice Problems
-- Tool: MySQL 8.0
-- ============================================


-- -----------------------------------------------
-- PROBLEM 1: Customer order summary using conditional aggregation
-- -----------------------------------------------
SELECT
    customer_id,
    COUNT(*)                                                              AS total_orders,
    COUNT(CASE WHEN status = 'completed' THEN 1 END)                    AS completed_orders,
    COUNT(CASE WHEN status = 'cancelled' THEN 1 END)                    AS cancelled_orders,
    SUM(CASE WHEN status = 'completed' THEN amount ELSE 0 END)          AS completed_revenue,
    ROUND(
        COUNT(CASE WHEN status = 'completed' THEN 1 END) /
        COUNT(order_id) * 100
    , 1)                                                                  AS completion_rate
FROM orders
GROUP BY customer_id;


-- -----------------------------------------------
-- PROBLEM 2: Months where completed revenue exceeded $500
-- -----------------------------------------------
SELECT
    DATE_FORMAT(order_date, '%Y-%m')                                     AS month,
    SUM(CASE WHEN status = 'completed' THEN amount ELSE 0 END)          AS completed_revenue,
    COUNT(*)                                                              AS total_orders
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
HAVING completed_revenue > 500
ORDER BY month;


-- -----------------------------------------------
-- PROBLEM 3: Customer performance report
-- -----------------------------------------------
WITH completed_cancelled_revenue AS (
    SELECT
        customer_id,
        SUM(CASE WHEN status = 'completed' THEN amount ELSE 0 END)      AS completed_revenue,
        SUM(CASE WHEN status = 'cancelled' THEN amount ELSE 0 END)      AS cancelled_revenue,
        ROUND(
            COUNT(CASE WHEN status = 'completed' THEN 1 END) /
            COUNT(order_id) * 100
        , 1)                                                              AS completion_rate
    FROM orders
    GROUP BY customer_id
    HAVING COUNT(CASE WHEN status = 'completed' THEN 1 END) >= 1
),
customer_rank AS (
    SELECT *,
        RANK() OVER (ORDER BY completed_revenue DESC)                    AS revenue_rank
    FROM completed_cancelled_revenue
)
SELECT *,
    CASE
        WHEN revenue_rank = 1       THEN 'Top'
        WHEN revenue_rank BETWEEN 2 AND 3 THEN 'Mid'
        ELSE 'Low'
    END AS performance
FROM customer_rank;
