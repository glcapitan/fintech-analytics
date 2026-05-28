"""
Database connection module for the Streamlit dashboard.

Provides cached connection and query functions that all dashboard pages import.
"""

import os

import pandas as pd
import streamlit as st
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

# Load environment variables from .env in the project root.
# We walk up from this file's location to find it reliably.
from pathlib import Path
env_path = Path(__file__).resolve().parents[2] / ".env"
load_dotenv(dotenv_path=env_path)


@st.cache_resource
def get_engine():
    """Create and cache the SQLAlchemy engine (runs once per session)."""
    db_url = (
        f"postgresql+psycopg2://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
        f"@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
    )
    return create_engine(db_url)


@st.cache_data(ttl=600)
def run_query(query: str) -> pd.DataFrame:
    """Run a SQL query and return results as a pandas DataFrame (cached 10 min)."""
    engine = get_engine()
    with engine.connect() as conn:
        return pd.read_sql(text(query), conn)