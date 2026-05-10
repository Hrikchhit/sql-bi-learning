# Lesson 5 — Query Optimization

## How indexes work
An index is like a book's index — lets MySQL jump directly 
to matching rows instead of scanning every row (full table scan).

Indexes are auto-created on: primary keys, unique constraints
Manually create on: WHERE columns, JOIN columns, ORDER BY columns

## What breaks indexes — the 4 killers

### 1 — Function on indexed column
```sql
-- ❌ breaks index
WHERE YEAR(order_date) = 2024

-- ✅ index works
WHERE order_date >= '2024-01-01' AND order_date < '2025-01-01'
```

### 2 — Leading wildcard in LIKE
```sql
-- ❌ full table scan
WHERE name LIKE '%Smith'

-- ✅ index works
WHERE name LIKE 'Smith%'
```

### 3 — OR across different columns
```sql
-- ❌ can't use indexes efficiently
WHERE customer_id = 101 OR order_date = '2024-01-01'

-- ✅ use UNION instead
SELECT * FROM orders WHERE customer_id = 101
UNION
SELECT * FROM orders WHERE order_date = '2024-01-01'
```

### 4 — Implicit type conversion
```sql
-- ❌ customer_id is INT but comparing to string
WHERE customer_id = '101'

-- ✅ match the data type
WHERE customer_id = 101
```

## EXPLAIN
Shows MySQL's execution plan before running the query.

```sql
EXPLAIN SELECT * FROM orders WHERE customer_id = 101;
```

### Key columns
| Column | Good | Bad |
|---|---|---|
| type | ref, eq_ref | ALL |
| key | index name | NULL |
| rows | small number | large number |
| Extra | — | Using filesort, Using temporary |

Golden rule: type: ALL + key: NULL on large table = needs index

## Common anti-patterns

### SELECT *
```sql
-- ❌ fetches all columns
SELECT * FROM orders

-- ✅ only needed columns
SELECT order_id, customer_id, amount FROM orders
```

### Correlated subquery
```sql
-- ❌ runs once per row
SELECT customer_id,
    (SELECT SUM(amount) FROM orders o2
     WHERE o2.customer_id = o1.customer_id) AS total
FROM orders o1

-- ✅ single pass with window function
SELECT customer_id,
    SUM(amount) OVER (PARTITION BY customer_id) AS total
FROM orders
```

### HAVING instead of WHERE
```sql
-- ❌ processes all rows first
HAVING status = 'completed'

-- ✅ filter early
WHERE status = 'completed'
```

### Unnecessary DISTINCT
Only use DISTINCT when duplicates are genuinely possible
and need removing. Otherwise it adds overhead for nothing.

### NULL comparison
```sql
-- ❌ never works
WHERE customer_id != NULL
WHERE customer_id = NULL

-- ✅ always use
WHERE customer_id IS NOT NULL
WHERE customer_id IS NULL
```

## Query execution order
FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT

Key insight: Filter as early as possible in WHERE.
Every row eliminated in WHERE never reaches GROUP BY or SELECT.

## Function placement rule
```
Function in WHERE   → ❌ breaks index, always avoid
Function in GROUP BY → ⚠️  minor cost, generally acceptable
Function in SELECT  → ✅ fine, just formatting
```
