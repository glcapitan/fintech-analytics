-- =============================================================================
-- 02_fact_daily_metrics.sql
--
-- Purpose: Pre-aggregate daily metrics by transaction type for fast dashboard reads.
--
-- Approach:
--   1. Convert raw step (hour) to day_number
--   2. Aggregate per day per type: txn count, total amount, fraud count
--   3. Add window-function metrics:
--        - 7-day rolling average (smooths over data anomalies)
--        - Day-over-day percent change
--        - Cumulative running total
--
-- Output: Materialized view fact_daily_metrics
--         Granularity: one row per (day_number, type)
-- =============================================================================

DROP MATERIALIZED VIEW IF EXISTS fact_daily_metrics CASCADE;

CREATE MATERIALIZED VIEW fact_daily_metrics AS
WITH
-- ---------------------------------------------------------------------------
-- Step 1: Per-day aggregation.
-- Compute totals for each (day, type) combination.
-- ---------------------------------------------------------------------------
daily_base AS (
    SELECT
        (step - 1) / 24 + 1 AS day_number,
        type,
        COUNT(*) AS txn_count,
        SUM(amount) AS total_amount,
        AVG(amount) AS avg_amount,
        COUNT(*) FILTER (WHERE is_fraud = 1) AS fraud_count,
        SUM(amount) FILTER (WHERE is_fraud = 1) AS fraud_amount
    FROM raw_transactions
    GROUP BY (step - 1) / 24 + 1, type
)

-- ---------------------------------------------------------------------------
-- Step 2: Add window-function metrics.
-- For each transaction type, compute:
--   - Previous day's txn count (LAG)
--   - Day-over-day percent change
--   - 7-day rolling average of txn count
--   - Cumulative txn count
-- ---------------------------------------------------------------------------
SELECT
    day_number,
    type,
    txn_count,
    ROUND(total_amount, 2) AS total_amount,
    ROUND(avg_amount, 2) AS avg_amount,
    fraud_count,
    ROUND(COALESCE(fraud_amount, 0), 2) AS fraud_amount,
    ROUND(100.0 * fraud_count / NULLIF(txn_count, 0), 4) AS fraud_rate_pct,

    -- Day-over-day comparison: get previous day's count for this same type
    LAG(txn_count, 1) OVER (PARTITION BY type ORDER BY day_number) AS prev_day_count,

    -- Day-over-day percent change
    ROUND(
        100.0 * (txn_count - LAG(txn_count, 1) OVER (PARTITION BY type ORDER BY day_number))
        / NULLIF(LAG(txn_count, 1) OVER (PARTITION BY type ORDER BY day_number), 0),
        2
    ) AS dod_pct_change,

    -- 7-day rolling average: smooths over anomalies (like days 3-5)
    ROUND(
        AVG(txn_count) OVER (
            PARTITION BY type
            ORDER BY day_number
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS rolling_7d_avg,

    -- Cumulative running total per type
    SUM(txn_count) OVER (
        PARTITION BY type
        ORDER BY day_number
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_txn_count

FROM daily_base
ORDER BY type, day_number;

-- ---------------------------------------------------------------------------
-- Indexes — the dashboard filters on day and type heavily
-- ---------------------------------------------------------------------------
CREATE INDEX idx_fdm_day  ON fact_daily_metrics (day_number);
CREATE INDEX idx_fdm_type ON fact_daily_metrics (type);
CREATE INDEX idx_fdm_day_type ON fact_daily_metrics (day_number, type);
