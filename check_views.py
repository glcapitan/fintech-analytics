import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()

DB_URL = (
    f"postgresql+psycopg2://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
    f"@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
)
engine = create_engine(DB_URL)

views = ['dim_customers', 'fact_daily_metrics', 'fact_customer_cohorts', 'fact_fraud_signals']

with engine.connect() as conn:
    for v in views:
        n = conn.execute(text(f'SELECT COUNT(*) FROM {v}')).scalar()
        print(f'{v}: {n:,} rows')
        