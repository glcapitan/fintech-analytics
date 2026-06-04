"""Upload deploy tables to Neon."""

import os
import pandas as pd
from pathlib import Path
from sqlalchemy import create_engine
from dotenv import load_dotenv

load_dotenv()

NEON_URL = (
    f"postgresql+psycopg2://{os.getenv('NEON_DB_USER')}:{os.getenv('NEON_DB_PASSWORD')}"
    f"@{os.getenv('NEON_DB_HOST')}:{os.getenv('NEON_DB_PORT')}/{os.getenv('NEON_DB_NAME')}"
    f"?sslmode=require"
)
engine = create_engine(NEON_URL)

INPUT_DIR = Path("cloud_data")

print("Uploading deploy tables to Neon...\n")

for csv_path in sorted(INPUT_DIR.glob("*.csv")):
    table_name = csv_path.stem
    df = pd.read_csv(csv_path)
    df.to_sql(table_name, engine, if_exists="replace", index=False,
              method="multi", chunksize=5_000)
    print(f"  ✓ {table_name}: {len(df):,} rows")

print("\nAll tables loaded to Neon!")