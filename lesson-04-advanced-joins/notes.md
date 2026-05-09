markdown# Lesson 4 — Advanced JOINs & Set Operations

## SELF JOIN
Joining a table with itself. Used when rows have relationships
with other rows in the same table (e.g. employee-manager hierarchy).

```sql
SELECT e.name AS employee, m.name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id;
```

Always use LEFT JOIN so rows with no match (e.g. CEO) still appear.

## CROSS JOIN
Combines every row from one table with every row from another.
No ON clause needed.

### Two use cases:
1. Attach a single-value CTE to every row (percentage calculations)
2. Generate all possible combinations (product × region matrix)

```sql
FROM orders o
CROSS JOIN total_revenue t  -- t has one row, attaches to every order
```

## FULL OUTER JOIN
Returns all rows from both tables, NULLs where no match.
NOT supported in MySQL — use workaround:

```sql
SELECT ... FROM a LEFT JOIN b ON a.id = b.id
UNION
SELECT ... FROM a RIGHT JOIN b ON a.id = b.id
```

UNION removes duplicates automatically.

## UNION vs UNION ALL
| | UNION | UNION ALL |
|---|---|---|
| Duplicates | Removed | Kept |
| Performance | Slower | Faster |
| Use when | Need deduplication | Combining without overlap |

## Key rules
- Always pre-aggregate before joining to avoid double counting
- Use COALESCE(a.col, b.col) to handle NULLs from both sides
- NULL comparison: always use IS NULL / IS NOT NULL, never = NULL
- AND not & for multiple conditions

## NULL comparison rules
```sql
-- ❌ never works
WHERE col = NULL
WHERE col <> NULL

-- ✅ always use
WHERE col IS NULL
WHERE col IS NOT NULL
