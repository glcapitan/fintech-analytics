import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()
DB_URL = (
    f"postgresql+psycopg2://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
    f"@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
)
engine = create_engine(DB_URL)

checks = {
    "raw_transactions count        ": "SELECT COUNT(*) FROM raw_transactions;",
    "fact_daily_metrics summed txns ": "SELECT SUM(txn_count) FROM fact_daily_metrics;",
    "dim_customers count           ": "SELECT COUNT(*) FROM dim_customers;",
    "distinct fraud rows in raw    ": "SELECT COUNT(*) FROM raw_transactions WHERE is_fraud = 1;",
}
with engine.connect() as conn:
    for label, q in checks.items():
        val = conn.execute(text(q)).scalar()
        print(f"{label}: {val:,}")