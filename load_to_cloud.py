"""Upload cloud_data/ CSVs to Supabase."""

import os
import pandas as pd
from pathlib import Path
from sqlalchemy import create_engine
from dotenv import load_dotenv

load_dotenv()

SUPABASE_URL = (
    f"postgresql+psycopg2://{os.getenv('SUPABASE_DB_USER')}:{os.getenv('SUPABASE_DB_PASSWORD')}"
    f"@{os.getenv('SUPABASE_DB_HOST')}:{os.getenv('SUPABASE_DB_PORT')}/{os.getenv('SUPABASE_DB_NAME')}"
)
engine = create_engine(SUPABASE_URL)

INPUT_DIR = Path("cloud_data")

print("Uploading deploy tables to Supabase...\n")

for csv_path in sorted(INPUT_DIR.glob("*.csv")):
    table_name = csv_path.stem
    df = pd.read_csv(csv_path)
    df.to_sql(table_name, engine, if_exists="replace", index=False,
              method="multi", chunksize=5_000)
    print(f"  ✓ {table_name}: {len(df):,} rows")

print("\nAll tables loaded to Supabase. Ready for Streamlit Cloud deployment.")