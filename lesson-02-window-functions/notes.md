# Lesson 2 — Window Functions

## What is a Window Function?
A window function performs a calculation across a set of rows
without collapsing them into a single result — unlike GROUP BY.
Every original row stays visible with the calculated column alongside it.

## Syntax
```sql
function_name() OVER (
    PARTITION BY column   -- divides rows into groups (like GROUP BY but no collapse)
    ORDER BY column       -- orders rows within each partition
)
```

## PARTITION BY vs GROUP BY
| | GROUP BY | PARTITION BY |
|---|---|---|
| Collapses rows | Yes | No |
| Shows individual rows | No | Yes |
| Used with | Aggregates | Window functions |

## SQL Execution Order
FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY

Window functions live in SELECT — so you CANNOT filter on them in WHERE.
Always wrap in a CTE first, then filter.

## Family 1 — Ranking Functions
| Function | Ties | Gaps after ties |
|---|---|---|
| ROW_NUMBER() | Unique, breaks ties arbitrarily | N/A |
| RANK() | Same rank for ties | Yes — skips next number |
| DENSE_RANK() | Same rank for ties | No — no gaps |

## Family 2 — Offset Functions
- LAG(col, n) — looks n rows BEHIND current row
- LEAD(col, n) — looks n rows AHEAD of current row
- First/last rows return NULL where no previous/next row exists
- Always use ORDER BY inside OVER() with LAG/LEAD

## Family 3 — Aggregate Window Functions
- SUM, COUNT, AVG, MAX, MIN used with OVER()
- Without ORDER BY: returns total for entire partition on every row
- With ORDER BY: creates a running/cumulative calculation

## Key Mental Checklist
Before writing a window function ask:
1. What am I calculating? → picks the function
2. Over which group? → PARTITION BY
3. In what order? → ORDER BY inside OVER()
4. Do I need all rows visible? → yes = window function, no = GROUP BY

## Common Mistakes
- Filtering on window function result in WHERE → wrap in CTE first
- LAG/LEAD without ORDER BY → unpredictable results
- PARTITION BY order_id for percentage → always 100%, meaningless
- Forgetting PARTITION BY → calculation runs across entire table
