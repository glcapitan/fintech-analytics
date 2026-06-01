"""
ETL script: Load PaySim CSV into PostgreSQL raw_transactions table.

EXTRACT and LOAD layer. Transformation logic lives in SQL (sql/transformations/).
Re-runs are idempotent: the table is TRUNCATED before loading, so running this
multiple times always produces exactly one clean load. TRUNCATE (not DROP) keeps
the table and its dependent materialized views intact.
"""

import os
import logging
from pathlib import Path

import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
)
logger = logging.getLogger(__name__)

DB_URL = (
    f"postgresql+psycopg2://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
    f"@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
)

CSV_PATH = Path(r"C:\Users\glcap\Documents\portfolio\fintech-analytics\data\paysim.csv")
TARGET_TABLE = "raw_transactions"
CHUNK_SIZE = 5_000

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


def load_csv_to_postgres():
    """Read the PaySim CSV in chunks and load into Postgres (idempotent)."""

    logger.info(f"Starting ETL: {CSV_PATH.name} -> {TARGET_TABLE}")
    logger.info(f"Chunk size: {CHUNK_SIZE:,} rows")

    if not CSV_PATH.exists():
        raise FileNotFoundError(f"CSV not found at {CSV_PATH}")

    engine = create_engine(DB_URL)

    # Empty the table first so re-runs don't duplicate data.
    with engine.connect() as conn:
        logger.info("Database connection successful.")
        conn.execute(text(f"TRUNCATE TABLE {TARGET_TABLE};"))
        conn.commit()
        logger.info(f"Truncated {TARGET_TABLE} — starting clean.")

    total_rows_loaded = 0

    chunk_iterator = pd.read_csv(CSV_PATH, chunksize=CHUNK_SIZE)

    for chunk_number, chunk in enumerate(chunk_iterator, start=1):

        chunk = chunk.rename(columns=COLUMN_MAPPING)

        chunk.to_sql(
            name=TARGET_TABLE,
            con=engine,
            if_exists="append",
            index=False,
            method="multi",
        )

        total_rows_loaded += len(chunk)
        logger.info(
            f"Chunk {chunk_number}: loaded {len(chunk):,} rows "
            f"| total so far: {total_rows_loaded:,}"
        )

    logger.info(f"ETL complete. Total rows loaded: {total_rows_loaded:,}")


if __name__ == "__main__":
    load_csv_to_postgres()
