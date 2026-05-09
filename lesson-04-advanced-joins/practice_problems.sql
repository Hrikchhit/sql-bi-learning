-- ============================================
-- Lesson 4: Advanced JOINs — Practice Problems
-- Tool: MySQL 8.0
-- ============================================


-- -----------------------------------------------
-- PROBLEM 1: SELF JOIN — employees with managers
-- -----------------------------------------------
SELECT
    e.name           AS employee_name,
    e.salary         AS employee_salary,
    e.department     AS department,
    m.name           AS manager_name,
    m.salary         AS manager_salary
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id
ORDER BY e.department, e.salary DESC;


-- -----------------------------------------------
-- PROBLEM 2: UNION ALL — combine 2023 and 2024 orders
-- -----------------------------------------------
SELECT order_id, customer_id, order_date, amount, '2023' AS year
FROM orders_2023
WHERE status = 'completed'

UNION ALL

SELECT order_id, customer_id, order_date, amount, '2024' AS year
FROM orders_2024
WHERE status = 'completed'

ORDER BY order_date;


-- -----------------------------------------------
-- PROBLEM 3: FULL OUTER JOIN workaround
-- Customer spend comparison 2023 vs 2024
-- -----------------------------------------------
WITH summary_2023 AS (
    SELECT customer_id, SUM(amount) AS total_2023
    FROM orders_2023
    WHERE status = 'completed'
    GROUP BY customer_id
),
summary_2024 AS (
    SELECT customer_id, SUM(amount) AS total_2024
    FROM orders_2024
    WHERE status = 'completed'
    GROUP BY customer_id
)
SELECT
    COALESCE(a.customer_id, b.customer_id) AS customer_id,
    a.total_2023,
    b.total_2024
FROM summary_2023 a
LEFT JOIN summary_2024 b ON a.customer_id = b.customer_id

UNION

SELECT
    COALESCE(a.customer_id, b.customer_id) AS customer_id,
    a.total_2023,
    b.total_2024
FROM summary_2023 a
RIGHT JOIN summary_2024 b ON a.customer_id = b.customer_id;
