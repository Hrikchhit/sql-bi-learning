sql-- ============================================
-- Lesson 1: Mini BI Challenge
-- Scenario: Customer activity report for manager
-- Tool: MySQL 8.0
-- ============================================

-- Task: Active customers (2+ completed orders),
-- ranked by spend, labelled VIP or Regular

WITH active_customers AS (
    SELECT
        customer_id,
        COUNT(order_id)  AS total_orders,
        SUM(amount)      AS total_spent,
        MAX(order_date)  AS last_order_date
    FROM orders
    WHERE status = 'completed'
    GROUP BY customer_id
    HAVING total_orders >= 2
),
ranked_customers AS (
    SELECT *,
        RANK() OVER (ORDER BY total_spent DESC) AS spend_rank
    FROM active_customers
),
labelled_customers AS (
    SELECT *,
        CASE
            WHEN total_spent > 700 THEN 'VIP'
            ELSE 'Regular'
        END AS customer_segment
    FROM ranked_customers
)
SELECT * FROM labelled_customers;
