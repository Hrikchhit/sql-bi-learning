sql-- ============================================
-- Lesson 1: CTEs — Practice Problems
-- Tool: MySQL 8.0
-- ============================================

-- -----------------------------------------------
-- PROBLEM 1: Customers with more than 1 completed order
-- -----------------------------------------------
WITH customer_completed AS (
    SELECT 
        customer_id,
        COUNT(order_id) AS total_orders
    FROM orders
    WHERE status = 'completed'
    GROUP BY customer_id
    HAVING total_orders > 1
)
SELECT * FROM customer_completed;


-- -----------------------------------------------
-- PROBLEM 2: Monthly revenue with high/low label
-- -----------------------------------------------
WITH total_revenue AS (
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(amount)                      AS total_amount
    FROM orders
    WHERE status = 'completed'
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
),
high_low AS (
    SELECT
        month,
        total_amount,
        CASE
            WHEN total_amount > 700 THEN 'High'
            ELSE 'Low'
        END AS performance_label
    FROM total_revenue
)
SELECT * FROM high_low;


-- -----------------------------------------------
-- PROBLEM 3: Top 2 customers by spend with % of total revenue
-- -----------------------------------------------
WITH total_revenue AS (
    SELECT SUM(amount) AS revenue
    FROM orders
    WHERE status = 'completed'
),
top_customers AS (
    SELECT
        o.customer_id,
        SUM(o.amount)                              AS total_spent,
        ROUND(SUM(o.amount) / t_r.revenue * 100, 1) AS pct_of_revenue
    FROM orders AS o
    CROSS JOIN total_revenue AS t_r
    WHERE o.status = 'completed'
    GROUP BY o.customer_id, t_r.revenue
    ORDER BY total_spent DESC
    LIMIT 2
)
SELECT * FROM top_customers;
