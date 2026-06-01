import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()

DB_URL = (
    f"postgresql+psycopg2://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
    f"@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
)

engine = create_engine(DB_URL)

files = [
    'sql/transformations/01_dim_customers.sql',
    'sql/transformations/02_fact_daily_metrics.sql',
    'sql/transformations/03_fact_customer_cohorts.sql',
    'sql/transformations/04_fact_fraud_signals.sql',
]

for f in files:
    print(f'Running {f}...')
    with engine.connect() as conn:
        conn.execute(text(open(f).read()))
        conn.commit()
    print(f'Done: {f}')

print('All transformations complete!')