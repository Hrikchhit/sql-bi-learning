# Lesson 6 — BI Use Cases

## Pattern 1 — Year over Year (YoY) Comparison
How does this month compare to same month last year?

Two approaches:
- Self-join — safer, works with gaps in data
- LAG(12) — cleaner, needs 12 consecutive monthly rows

Key insight: LAG counts ROWS not time periods.
Always ensure consecutive monthly data for LAG to work correctly.

## Pattern 2 — Cohort Analysis
Of customers who first ordered in January, how many are still ordering?

Structure:
- CTE 1 — find each customer's first order month (cohort)
- CTE 2 — join back to ALL their subsequent orders
- CTE 3 — count cohort sizes
- Final — calculate retention % per cohort per month

## Pattern 3 — Retention Analysis
Of this month's customers, what % came back next month?

Structure:
- CTE 1 — distinct customers per month
- Final — LEFT JOIN to next month on customer_id

Critical rule — WHERE vs ON with LEFT JOIN:
- Condition in ON preserves NULL rows — true LEFT JOIN
- Condition in WHERE removes NULL rows — becomes INNER JOIN

New customers joining next month do not count as retained.
Retention only tracks existing customers returning.

## Pattern 4 — Funnel Analysis
How many customers move from one stage to the next?

Each stage uses previous stage as denominator:
- Completion rate = completed / total
- High value rate = high value / completed

## Pattern 5 — Moving Averages
Smooth out short-term fluctuations to show underlying trend.

Frame counting rule:
- ROWS BETWEEN N PRECEDING AND CURRENT ROW = N+1 total rows
- 2 PRECEDING = 3-period moving average
- 5 PRECEDING = 6-period moving average

Frame options:
- ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW — running total
- ROWS BETWEEN 2 PRECEDING AND CURRENT ROW — 3-period moving avg
- ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING — centered moving avg

## Key insight
Most real BI reports combine multiple patterns:
- Monthly revenue + moving avg + YoY + best month flag
- Customer funnel + retention + cohort in one dashboard
