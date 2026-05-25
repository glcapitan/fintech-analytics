"""
ETL script: Load PaySim CSV into PostgreSQL raw_transactions table.

This is the EXTRACT and LOAD layer of our pipeline.
Transformation logic lives in SQL (see sql/transformations/).
"""

import os
import logging
from pathlib import Path

import pandas as pd
from sqlalchemy import create_engine
from dotenv import load_dotenv
from tqdm import tqdm

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

# Load environment variables from .env file
load_dotenv()

# Configure logging — better than using print() in production code
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
)
logger = logging.getLogger(__name__)

# Build the database connection string from environment variables
DB_URL = (
    f"postgresql+psycopg2://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
    f"@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
)

# Path to the source CSV
CSV_PATH = Path(r"C:\Users\glcap\Documents\portfolio\fintech-analytics\data\paysim.csv")

# Table we're loading into
TARGET_TABLE = "raw_transactions"

# How many rows to read at a time — prevents loading all 6M rows into memory at once
CHUNK_SIZE = 100_000

# PaySim CSV column names -> our database column names
# The CSV uses camelCase, our DB uses snake_case (standard SQL convention)
COLUMN_MAPPING = {
    "step": "step",
    "type": "type",
    "amount": "amount",
    "nameOrig": "name_orig",
    "oldbalanceOrg": "oldbalance_orig",
    "newbalanceOrig": "newbalance_orig",
    "nameDest": "name_dest",
    "oldbalanceDest": "oldbalance_dest",
    "newbalanceDest": "newbalance_dest",
    "isFraud": "is_fraud",
    "isFlaggedFraud": "is_flagged_fraud",
}


# ---------------------------------------------------------------------------
# Main ETL logic
# ---------------------------------------------------------------------------

def load_csv_to_postgres():
    """Read the PaySim CSV in chunks and append each chunk to Postgres."""

    logger.info(f"Starting ETL: {CSV_PATH.name} -> {TARGET_TABLE}")
    logger.info(f"Chunk size: {CHUNK_SIZE:,} rows")

    # Verify the file exists before doing anything else
    if not CSV_PATH.exists():
        raise FileNotFoundError(f"CSV not found at {CSV_PATH}")

    # Create the database engine — this manages the connection pool
    engine = create_engine(DB_URL)

    # Test the connection before starting the long load
    with engine.connect() as conn:
        logger.info("Database connection successful.")

    total_rows_loaded = 0

    # Read the CSV in chunks of 100k rows
    # This is the key to handling files larger than your RAM
    chunk_iterator = pd.read_csv(CSV_PATH, chunksize=CHUNK_SIZE)

    for chunk_number, chunk in enumerate(chunk_iterator, start=1):

        # Rename CSV columns to match our DB schema (camelCase -> snake_case)
        chunk = chunk.rename(columns=COLUMN_MAPPING)

        # Append this chunk to the table
        # if_exists="append" means: don't recreate the table, just add rows
        chunk.to_sql(
            name=TARGET_TABLE,
            con=engine,
            if_exists="append",
            index=False,
            method="multi",  # bulk insert — much faster than row-by-row
        )

        total_rows_loaded += len(chunk)
        logger.info(
            f"Chunk {chunk_number}: loaded {len(chunk):,} rows "
            f"| total so far: {total_rows_loaded:,}"
        )

    logger.info(f"ETL complete. Total rows loaded: {total_rows_loaded:,}")


if __name__ == "__main__":
    load_csv_to_postgres()
    