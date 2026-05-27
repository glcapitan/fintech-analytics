-- =============================================================================
-- 04_fact_fraud_signals.sql
--
-- Purpose: Flag suspicious transactions using rule-based heuristics derived
--          from exploratory analysis. This is a "fraud signal" layer, not
--          ground truth — it's how a real analyst would surface anomalies for
--          investigation.
--
-- Approach:
--   1. Identify amount thresholds (99th percentile by type)
--   2. Flag large-amount transactions
--   3. Flag balance anomalies (sender's balance didn't decrease correctly)
--   4. Combine signals into a single risk score
--
-- Output: materialized view fact_fraud_signals
-- Granularity: one row per suspicious transaction
-- =============================================================================

DROP MATERIALIZED VIEW IF EXISTS fact_fraud_signals CASCADE;

CREATE MATERIALIZED VIEW fact_fraud_signals AS
WITH
-- ---------------------------------------------------------------------------
-- Step 1: Compute the 99th percentile amount per transaction type.
-- This becomes our "large transaction" threshold per type.
-- ---------------------------------------------------------------------------
type_thresholds AS (
    SELECT
        type,
        PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY amount) AS p99_amount
    FROM raw_transactions
    GROUP BY type
),

-- ---------------------------------------------------------------------------
-- Step 2: Flag each transaction with rule-based signals.
-- We focus on TRANSFER and CASH_OUT since fraud only occurs in those types.
-- ---------------------------------------------------------------------------
flagged AS (
    SELECT
        rt.step,
        (rt.step - 1) / 24 + 1 AS day_number,
        rt.type,
        rt.name_orig,
        rt.name_dest,
        rt.amount,
        rt.oldbalance_orig,
        rt.newbalance_orig,
        rt.is_fraud,
        tt.p99_amount,

        -- Signal 1: Amount exceeds 99th percentile for this type
        CASE WHEN rt.amount > tt.p99_amount THEN 1 ELSE 0 END AS sig_large_amount,

        -- Signal 2: Sender drained completely
        --   (newbalance_orig = 0 AND amount > 0)
        CASE
            WHEN rt.newbalance_orig = 0 AND rt.amount > 0
            THEN 1 ELSE 0
        END AS sig_account_drained,

        -- Signal 3: Balance math doesn't reconcile
        --   (oldbalance - amount != newbalance, with $1 tolerance)
        CASE
            WHEN ABS((rt.oldbalance_orig - rt.amount) - rt.newbalance_orig) > 1
            THEN 1 ELSE 0
        END AS sig_balance_mismatch

    FROM raw_transactions rt
    JOIN type_thresholds tt USING (type)
    WHERE rt.type IN ('TRANSFER', 'CASH_OUT')
)

-- ---------------------------------------------------------------------------
-- Step 3: Combine signals into a risk score and final output.
-- ---------------------------------------------------------------------------
SELECT
    step,
    day_number,
    type,
    name_orig,
    name_dest,
    amount,
    oldbalance_orig,
    newbalance_orig,
    is_fraud,
    sig_large_amount,
    sig_account_drained,
    sig_balance_mismatch,
    (sig_large_amount + sig_account_drained + sig_balance_mismatch) AS risk_score
FROM flagged
WHERE (sig_large_amount + sig_account_drained + sig_balance_mismatch) > 0;

-- Indexes for fast dashboard filtering
CREATE INDEX idx_ffs_day        ON fact_fraud_signals (day_number);
CREATE INDEX idx_ffs_type       ON fact_fraud_signals (type);
CREATE INDEX idx_ffs_risk_score ON fact_fraud_signals (risk_score);
CREATE INDEX idx_ffs_is_fraud   ON fact_fraud_signals (is_fraud);
