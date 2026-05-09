sql-- ============================================
-- Lesson 4: Mini BI Challenge
-- Scenario: Employee comparison report for HR
-- Tool: MySQL 8.0
-- ============================================

WITH full_outer_join AS (
    SELECT
        COALESCE(a.employee_id, b.employee_id)   AS employee_id,
        COALESCE(a.name, b.name)                 AS name,
        COALESCE(b.department, a.department)     AS department,
        a.salary                                 AS salary_2023,
        b.salary                                 AS salary_2024
    FROM employees_2023 a
    LEFT JOIN employees_2024 b ON a.employee_id = b.employee_id

    UNION

    SELECT
        COALESCE(a.employee_id, b.employee_id)   AS employee_id,
        COALESCE(a.name, b.name)                 AS name,
        COALESCE(b.department, a.department)     AS department,
        a.salary                                 AS salary_2023,
        b.salary                                 AS salary_2024
    FROM employees_2023 a
    RIGHT JOIN employees_2024 b ON a.employee_id = b.employee_id
),
salary_comparison AS (
    SELECT *,
        salary_2024 - salary_2023 AS salary_change
    FROM full_outer_join
),
trend_rank_status AS (
    SELECT *,
        CASE
            WHEN salary_change IS NULL  THEN 'N/A'
            WHEN salary_change > 0      THEN 'Raise'
            WHEN salary_change < 0      THEN 'Pay Cut'
            ELSE 'No Change'
        END AS salary_trend,
        RANK() OVER (
            PARTITION BY department
            ORDER BY salary_2024 DESC
        )                                        AS dept_rank_2024,
        CASE
            WHEN salary_2023 IS NOT NULL AND salary_2024 IS NOT NULL THEN 'Active'
            WHEN salary_2023 IS NULL     AND salary_2024 IS NOT NULL THEN 'New Joiner'
            WHEN salary_2023 IS NOT NULL AND salary_2024 IS NULL     THEN 'Left'
        END AS employment_status
    FROM salary_comparison
)
SELECT *
FROM trend_rank_status
ORDER BY department, salary_2024 DESC;
