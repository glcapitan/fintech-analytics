"""
Fintech Transaction Analytics Dashboard — Home page.

This is the entry point. Streamlit auto-discovers files in pages/ and adds
them to the sidebar navigation.
"""

import streamlit as st
from db import run_query

# -----------------------------------------------------------------------------
# Page configuration — must be the first Streamlit command
# -----------------------------------------------------------------------------
st.set_page_config(
    page_title="Fintech Analytics",
    page_icon="💳",
    layout="wide",  # use full browser width
    initial_sidebar_state="expanded",
)

# -----------------------------------------------------------------------------
# Header
# -----------------------------------------------------------------------------
st.title("💳 Fintech Transaction Analytics")
st.markdown(
    """
    A business intelligence dashboard analyzing **6.36 million** mobile money
    transactions — covering transaction trends, customer segmentation, and
    fraud detection.
    """
)

st.divider()

# -----------------------------------------------------------------------------
# Top-line KPIs — pulled live from the database
# -----------------------------------------------------------------------------
st.subheader("Dataset at a Glance")

# Query the headline numbers
# Fast KPI query — reads from pre-aggregated materialized views (tiny + indexed)
# instead of scanning 6.36M raw rows. Original version took ~60s; this is <1s.
kpi_query = """
    SELECT
        (SELECT SUM(txn_count)    FROM fact_daily_metrics) AS total_txns,
        (SELECT SUM(total_amount) FROM fact_daily_metrics) AS total_volume,
        (SELECT SUM(fraud_count)  FROM fact_daily_metrics) AS total_fraud,
        (SELECT COUNT(*)          FROM dim_customers)       AS unique_customers;
"""
kpi = run_query(kpi_query).iloc[0]

# Display as 4 metric cards across the page
col1, col2, col3, col4 = st.columns(4)

col1.metric(
    label="Total Transactions",
    value=f"{int(kpi['total_txns']):,}",
)
col2.metric(
    label="Total Volume",
    value=f"${kpi['total_volume'] / 1e9:,.1f}B",
)
col3.metric(
    label="Fraud Cases",
    value=f"{int(kpi['total_fraud']):,}",
)
col4.metric(
    label="Unique Customers",
    value=f"{int(kpi['unique_customers']) / 1e6:,.2f}M",
)

st.divider()

# -----------------------------------------------------------------------------
# Navigation guide
# -----------------------------------------------------------------------------
st.subheader("Explore the Dashboard")
st.markdown(
    """
    Use the sidebar to navigate:

    - **Executive Overview** — headline KPIs and transaction-type breakdown
    - **Transaction Trends** — daily volume, rolling averages, growth
    - **Customer Analysis** — customer tiers and behavior segments
    - **Fraud Analytics** — risk signals and suspicious transactions

    ---
    *Built with PostgreSQL, Python, and Streamlit. Data: PaySim synthetic
    mobile money dataset.*
    """
)