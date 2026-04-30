# Lesson 1 — CTEs (Common Table Expressions)

## What is a CTE?
A CTE is a temporary named result set defined with the WITH keyword.
It exists only for the duration of the query and makes complex
queries readable by breaking them into named steps.

## Syntax
WITH cte_name AS (
    -- your query here
)
SELECT * FROM cte_name;

## Key rules
- CTEs are defined before the main SELECT
- Multiple CTEs are separated by commas
- Each CTE can reference a previous CTE
- Filter early inside CTEs for better performance
- Use CTEs when logic has 2+ steps or needs to be reused

## CTE vs Subquery
| Situation | Use |
|---|---|
| Logic has 2+ steps | CTE |
| Need to reuse same result | CTE |
| Someone else will read this | CTE |
| Simple one-liner filter | Subquery is fine |

## SQL clause order
SELECT → FROM → WHERE → GROUP BY → HAVING → ORDER BY

## Key insight
Filter inside the CTE so that downstream CTEs don't 
inherit dirty data and the database processes fewer rows.
