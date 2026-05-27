-- =============================================================================
-- 01_dim_customers.sql
--
-- Purpose: Build the customer dimension table from raw_transactions.
--
-- Approach:
--   1. Combine all sender + receiver appearances into a single customer list
--   2. Filter to customer accounts only (exclude merchants 'M')
--   3. For each customer, aggregate behavior metrics:
--      - First/last activity (step number)
--      - Number of transactions sent and received
--      - Total amount sent and received
--      - Whether they've ever been involved in fraud
--
-- Output: Materialized view dim_customers, one row per unique customer.
-- =============================================================================

-- Drop any existing version so re-runs are clean.
-- IF EXISTS prevents an error on the very first run.
DROP MATERIALIZED VIEW IF EXISTS dim_customers CASCADE;

CREATE MATERIALIZED VIEW dim_customers AS
WITH
-- ---------------------------------------------------------------------------
-- Step 1: Combine sender and receiver activity into one unified list.
-- A single customer might be both a sender AND a receiver across transactions,
-- so we tag each row with a 'role' to preserve the distinction.
-- ---------------------------------------------------------------------------
all_customer_activity AS (
    -- Sender side: every transaction's originator
    SELECT
        name_orig AS customer_id,
        step,
        amount,
        is_fraud,
        'sender' AS role
    FROM raw_transactions

    UNION ALL

    -- Receiver side: every transaction's destination
    -- Filtered to customers only (exclude merchants)
    SELECT
        name_dest AS customer_id,
        step,
        amount,
        is_fraud,
        'receiver' AS role
    FROM raw_transactions
    WHERE LEFT(name_dest, 1) = 'C'
),

-- ---------------------------------------------------------------------------
-- Step 2: Aggregate per customer.
-- One row per customer with their full behavioral profile.
-- ---------------------------------------------------------------------------
customer_metrics AS (
    SELECT
        customer_id,
        MIN(step) AS first_seen_step,
        MAX(step) AS last_seen_step,
        COUNT(*) FILTER (WHERE role = 'sender') AS txns_sent,
        COUNT(*) FILTER (WHERE role = 'receiver') AS txns_received,
        COUNT(*) AS total_txns,
        SUM(amount) FILTER (WHERE role = 'sender') AS amount_sent,
        SUM(amount) FILTER (WHERE role = 'receiver') AS amount_received,
        MAX(is_fraud) AS ever_involved_in_fraud
    FROM all_customer_activity
    GROUP BY customer_id
)

-- ---------------------------------------------------------------------------
-- Step 3: Final select with derived columns.
-- We add a customer_tier using a window function (NTILE) to bucket customers
-- by total transaction volume.
-- ---------------------------------------------------------------------------
SELECT
    customer_id,
    first_seen_step,
    last_seen_step,
    (last_seen_step - first_seen_step) AS lifespan_steps,
    txns_sent,
    txns_received,
    total_txns,
    COALESCE(amount_sent, 0)     AS amount_sent,
    COALESCE(amount_received, 0) AS amount_received,
    COALESCE(amount_sent, 0) + COALESCE(amount_received, 0) AS total_amount,
    ever_involved_in_fraud,
    NTILE(4) OVER (ORDER BY (COALESCE(amount_sent, 0) + COALESCE(amount_received, 0)) DESC)
        AS customer_tier  -- 1 = top 25% of customers by volume, 4 = bottom 25%
FROM customer_metrics;

-- ---------------------------------------------------------------------------
-- Indexes for query performance.
-- The dashboard will filter on customer_id, customer_tier, and fraud history,
-- so we index those columns.
-- ---------------------------------------------------------------------------
CREATE UNIQUE INDEX idx_dim_customers_customer_id ON dim_customers (customer_id);
CREATE INDEX idx_dim_customers_tier              ON dim_customers (customer_tier);
CREATE INDEX idx_dim_customers_fraud             ON dim_customers (ever_involved_in_fraud);

-- ---------------------------------------------------------------------------
-- Sanity check query: total customers in dim_customers
-- (You can comment this out after the first run.)
-- ---------------------------------------------------------------------------
-- SELECT COUNT(*) FROM dim_customers;