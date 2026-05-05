markdown# Lesson 3 — Advanced Aggregations

## Conditional Aggregation
Using CASE WHEN inside SUM() and COUNT() to segment 
data without multiple queries.

### Pattern
```sql
SUM(CASE WHEN condition THEN value ELSE 0 END)
COUNT(CASE WHEN condition THEN 1 END)  -- NULL ignored by COUNT automatically
```

### When to use
- Revenue split by status in same row
- Counting specific segments side by side
- Calculating rates and percentages per group

## HAVING vs WHERE
| | WHERE | HAVING |
|---|---|---|
| When it runs | Before GROUP BY | After GROUP BY |
| Filters | Raw rows | Aggregated results |
| Use for | Row-level conditions | Aggregate conditions |
| Performance | Faster — fewer rows enter aggregation | Slower — processes all rows first |

### Key rule
Never use HAVING where WHERE would work — it's slower.

```sql
-- ❌ slow
GROUP BY customer_id
HAVING status = 'completed'

-- ✅ fast
WHERE status = 'completed'
GROUP BY customer_id
```

## ROLLUP
Automatically adds subtotal and grand total rows to GROUP BY results.

```sql
GROUP BY col1, col2 WITH ROLLUP
```

NULL rows in output = subtotals/grand totals.
Use COALESCE to replace NULLs with labels:
```sql
COALESCE(col1, 'Grand Total') AS col1
```

## Key insight — Conditional aggregation replaces multiple queries
One query with CASE WHEN inside aggregates gives the full 
picture in a single result set — completed revenue, cancelled 
revenue, counts, and rates all in one row per group.

## HAVING with conditional aggregation
```sql
HAVING COUNT(CASE WHEN status = 'completed' THEN 1 END) >= 1
```
More precise than `HAVING completed_revenue > 0` — handles 
edge cases where completed orders might have $0 amount.
