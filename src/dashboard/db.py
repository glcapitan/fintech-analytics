"""
Database connection helper.

Reads credentials from Streamlit secrets (works on Streamlit Cloud)
with a fallback to local .env for development.
"""

import os
import streamlit as st
import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

# Load .env for local development
load_dotenv()


def _get_credential(key: str, default: str = "") -> str:
    """
    Get a credential from Streamlit secrets first, then env vars.
    This lets the same code work both locally and on Streamlit Cloud.
    """
    try:
        return st.secrets[key]
    except (KeyError, FileNotFoundError, AttributeError):
        return os.getenv(key, default)


@st.cache_resource
def get_engine():
    """Build and cache a SQLAlchemy engine for the project's database."""
    db_host     = _get_credential("DB_HOST", "localhost")
    db_port     = _get_credential("DB_PORT", "5432")
    db_name     = _get_credential("DB_NAME", "fintech_analytics")
    db_user     = _get_credential("DB_USER", "postgres")
    db_password = _get_credential("DB_PASSWORD", "")
    db_sslmode  = _get_credential("DB_SSLMODE", "")

    ssl_suffix = f"?sslmode={db_sslmode}" if db_sslmode else ""

    url = (
        f"postgresql+psycopg2://{db_user}:{db_password}"
        f"@{db_host}:{db_port}/{db_name}{ssl_suffix}"
    )
    return create_engine(url, pool_pre_ping=True)


@st.cache_data(ttl=600)
def run_query(query: str) -> pd.DataFrame:
    """Run a SQL query and return the results as a DataFrame."""
    engine = get_engine()
    with engine.connect() as conn:
        return pd.read_sql(text(query), conn)