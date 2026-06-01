"""
Create and export pre-aggregated deploy_* tables for cloud deployment.
Run this once locally — it creates the tables in local Postgres AND
exports CSVs to cloud_data/ for uploading to Supabase.
"""

import os
import pandas as pd
from pathlib import Path
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()

LOCAL_URL = (
    f"postgresql+psycopg2://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
    f"@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
)
engine = create_engine(LOCAL_URL)

OUTPUT_DIR = Path("cloud_data")
OUTPUT_DIR.mkdir(exist_ok=True)

DEPLOY_TABLES = {
    "deploy_fact_daily_metrics": "SELECT * FROM fact_daily_metrics;",

    "deploy_fact_customer_cohorts": "SELECT * FROM fact_customer_cohorts;",

    "deploy_tier_summary": """
        SELECT
            customer_tier,
            COUNT(*)                    AS customer_count,
            ROUND(AVG(total_amount), 2) AS avg_total_amount,
            ROUND(AVG(total_txns), 2)   AS avg_txns,
            SUM(ever_involved_in_fraud) AS fraud_customers,
            ROUND(SUM(total_amount), 2) AS total_volume_tier
        FROM dim_customers
        GROUP BY customer_tier
        ORDER BY customer_tier;
    """,

    "deploy_customer_behavior": """
        SELECT
            CASE WHEN txns_sent > 0 THEN 'Active Sender'
                 ELSE 'Receive-Only' END AS behavior_type,
            COUNT(*) AS customer_count
        FROM dim_customers
        GROUP BY CASE WHEN txns_sent > 0 THEN 'Active Sender'
                      ELSE 'Receive-Only' END;
    """,

    "deploy_customer_top20": """
        SELECT customer_id, total_txns, amount_sent, amount_received,
               total_amount, customer_tier, ever_involved_in_fraud
        FROM dim_customers
        ORDER BY total_amount DESC
        LIMIT 20;
    """,

    "deploy_fraud_overall": """
        SELECT
            COUNT(*)                                    AS flagged_txns,
            SUM(is_fraud)                               AS true_fraud,
            COUNT(*) FILTER (WHERE risk_score = 1)      AS score1_count,
            SUM(is_fraud) FILTER (WHERE risk_score = 1) AS score1_fraud
        FROM fact_fraud_signals;
    """,

    "deploy_fraud_risk_dist": """
        SELECT
            risk_score,
            COUNT(*)                                    AS flagged_txns,
            SUM(is_fraud)                               AS true_fraud,
            ROUND(100.0 * SUM(is_fraud) / COUNT(*), 2) AS precision_pct
        FROM fact_fraud_signals
        GROUP BY risk_score
        ORDER BY risk_score;
    """,

    "deploy_fraud_type_summary": """
        SELECT type, COUNT(*) AS flagged_txns, SUM(is_fraud) AS true_fraud
        FROM fact_fraud_signals
        GROUP BY type
        ORDER BY flagged_txns DESC;
    """,

    "deploy_fraud_suspicious": """
        SELECT day_number, type, name_orig, name_dest, amount, risk_score, is_fraud
        FROM (
            SELECT *,
                ROW_NUMBER() OVER (PARTITION BY risk_score ORDER BY amount DESC) AS rn
            FROM fact_fraud_signals
        ) t
        WHERE rn <= 100
        ORDER BY risk_score, amount DESC;
    """,
}

print("Creating deploy_ tables locally and exporting CSVs...\n")

with engine.connect() as conn:
    for table_name, query in DEPLOY_TABLES.items():
        df = pd.read_sql(text(query), conn)
        df.to_csv(OUTPUT_DIR / f"{table_name}.csv", index=False)
        df.to_sql(table_name, conn, if_exists="replace", index=False, method="multi")
        conn.commit()
        print(f"  ✓ {table_name}: {len(df):,} rows")

print(f"\nDone. Run 'python load_to_cloud.py' to upload to Supabase.")
