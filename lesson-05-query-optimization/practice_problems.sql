-- ============================================
-- Lesson 5: Query Optimization — Practice Problems
-- Tool: MySQL 8.0
-- ============================================


-- -----------------------------------------------
-- PROBLEM 1: Spot and fix anti-patterns
-- -----------------------------------------------
-- Original slow query:
-- SELECT DISTINCT *
-- FROM orders
-- WHERE YEAR(order_date) = 2024
-- AND status = 'completed'
-- AND customer_id != NULL
-- GROUP BY DATE_FORMAT(order_date, '%Y-%m')
-- HAVING SUM(amount) > 0
-- ORDER BY DATE_FORMAT(order_date, '%Y-%m');

-- Issues identified:
-- 1. DISTINCT unnecessary — GROUP BY already deduplicates
-- 2. SELECT * — fetches unnecessary columns
-- 3. YEAR() breaks index — use date range instead
-- 4. != NULL never works — use IS NOT NULL
-- 5. HAVING SUM(amount) > 0 — unnecessary, completed orders always > 0

-- Optimised version:
SELECT
    order_id,
    customer_id,
    order_date,
    amount,
    status
FROM orders
WHERE order_date >= '2024-01-01'
  AND order_date < '2025-01-01'
  AND status = 'completed'
  AND customer_id IS NOT NULL
ORDER BY DATE_FORMAT(order_date, '%Y-%m');


-- -----------------------------------------------
-- PROBLEM 2: Rewrite correlated subquery
-- -----------------------------------------------
-- Original slow query (runs subquery once per row):
-- SELECT order_id, customer_id, amount,
--     (SELECT SUM(amount) FROM orders o2
--      WHERE o2.customer_id = o1.customer_id
--      AND o2.status = 'completed') AS customer_total
-- FROM orders o1
-- WHERE o1.status = 'completed';

-- Optimised version (single pass):
SELECT
    order_id,
    customer_id,
    amount,
    SUM(amount) OVER (PARTITION BY customer_id) AS customer_total
FROM orders
WHERE status = 'completed';


-- -----------------------------------------------
-- PROBLEM 3: Full rewrite
-- -----------------------------------------------
-- Fix all anti-patterns from:
-- SELECT DISTINCT *
-- FROM orders
-- WHERE YEAR(order_date) = 2024
-- AND status = 'completed'
-- AND customer_id != NULL
-- HAVING amount > 50
-- ORDER BY order_date;

SELECT
    order_id,
    customer_id,
    order_date,
    amount,
    status
FROM orders
WHERE order_date >= '2024-01-01'
  AND order_date < '2025-01-01'
  AND status = 'completed'
  AND customer_id IS NOT NULL
  AND amount > 50
ORDER BY order_date;
