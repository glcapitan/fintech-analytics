-- =============================================================================
-- 03_fact_customer_cohorts.sql
--
-- Purpose: Cohort retention analysis. Group customers by the week they first
--          appeared, then track how many remain active in each subsequent week.
--
-- Approach:
--   1. Determine each customer's cohort_week (week of first activity)
--   2. Determine each customer's active weeks (any week they had a transaction)
--   3. Cross-join cohort_week with activity_week to compute retention
--   4. Aggregate into a retention matrix
--
-- Granularity: one row per (cohort_week, weeks_since_start)
-- Output: materialized view fact_customer_cohorts
-- =============================================================================

DROP MATERIALIZED VIEW IF EXISTS fact_customer_cohorts CASCADE;

CREATE MATERIALIZED VIEW fact_customer_cohorts AS
WITH
-- ---------------------------------------------------------------------------
-- Step 1: Convert step (hour) to week_number for every transaction.
-- Each PaySim step = 1 hour. 168 hours = 1 week.
-- We use only the sender side (name_orig) since 100% of senders are customers.
-- ---------------------------------------------------------------------------
customer_activity AS (
    SELECT DISTINCT
        name_orig AS customer_id,
        (step - 1) / 168 + 1 AS week_number
    FROM raw_transactions
),

-- ---------------------------------------------------------------------------
-- Step 2: Determine each customer's cohort_week = their FIRST active week.
-- This is the "starting point" that defines which cohort they belong to.
-- ---------------------------------------------------------------------------
customer_cohort AS (
    SELECT
        customer_id,
        MIN(week_number) AS cohort_week
    FROM customer_activity
    GROUP BY customer_id
),

-- ---------------------------------------------------------------------------
-- Step 3: Join cohort info back to each activity event.
-- Each row now has: customer, their cohort_week, and an active week.
-- ---------------------------------------------------------------------------
cohort_activity AS (
    SELECT
        cc.cohort_week,
        ca.week_number AS active_week,
        ca.week_number - cc.cohort_week AS weeks_since_start,
        ca.customer_id
    FROM customer_activity ca
    JOIN customer_cohort cc USING (customer_id)
),

-- ---------------------------------------------------------------------------
-- Step 4: Aggregate to one row per (cohort_week, weeks_since_start).
-- Count distinct customers retained in each cell of the retention matrix.
-- ---------------------------------------------------------------------------
cohort_matrix AS (
    SELECT
        cohort_week,
        weeks_since_start,
        COUNT(DISTINCT customer_id) AS retained_customers
    FROM cohort_activity
    GROUP BY cohort_week, weeks_since_start
),

-- ---------------------------------------------------------------------------
-- Step 5: Compute cohort size (the denominator) for retention percent.
-- A cohort's size is the number of distinct customers in week 0
-- (weeks_since_start = 0).
-- ---------------------------------------------------------------------------
cohort_size AS (
    SELECT
        cohort_week,
        retained_customers AS cohort_size_customers
    FROM cohort_matrix
    WHERE weeks_since_start = 0
)

-- ---------------------------------------------------------------------------
-- Final: join matrix with cohort size to compute retention rate.
-- ---------------------------------------------------------------------------
SELECT
    cm.cohort_week,
    cm.weeks_since_start,
    cm.retained_customers,
    cs.cohort_size_customers,
    ROUND(
        100.0 * cm.retained_customers / NULLIF(cs.cohort_size_customers, 0),
        2
    ) AS retention_pct
FROM cohort_matrix cm
JOIN cohort_size cs USING (cohort_week)
ORDER BY cm.cohort_week, cm.weeks_since_start;

-- Indexes — the dashboard filters and pivots on these columns
CREATE INDEX idx_fcc_cohort ON fact_customer_cohorts (cohort_week);
CREATE INDEX idx_fcc_since  ON fact_customer_cohorts (weeks_since_start);
