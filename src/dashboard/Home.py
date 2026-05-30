"""Fintech Transaction Analytics Dashboard — Home page."""

import streamlit as st
from db import run_query
from ui import inject_css, render_sidebar_brand, render_footer, render_hero_kpi

st.set_page_config(
    page_title="Fintech Analytics",
    page_icon="💳",
    layout="wide",
    initial_sidebar_state="expanded",
)

inject_css()
render_sidebar_brand()

# Header
st.title("Fintech Transaction Analytics")
st.markdown(
    "<div style='color: #64748b; font-size: 1.05rem; margin-top: -0.5rem;'>"
    "A business intelligence dashboard analyzing mobile money transactions — "
    "covering transaction trends, customer segmentation, and fraud detection."
    "</div>",
    unsafe_allow_html=True,
)
st.divider()

# Hero KPI — the headline number for the whole project
render_hero_kpi(
    label="Total Transaction Volume Analyzed",
    value="$1.14T",
    context=(
        "Across 6.36 million mobile money transactions over 31 days. "
        "Each subsequent page drills into a dimension of this data."
    ),
)

# Supporting KPIs
st.subheader("Dataset at a Glance")

kpi_query = """
    SELECT
        (SELECT SUM(txn_count)    FROM fact_daily_metrics) AS total_txns,
        (SELECT SUM(total_amount) FROM fact_daily_metrics) AS total_volume,
        (SELECT SUM(fraud_count)  FROM fact_daily_metrics) AS total_fraud,
        (SELECT COUNT(*)          FROM dim_customers)       AS unique_customers;
"""
kpi = run_query(kpi_query).iloc[0]

col1, col2, col3, col4 = st.columns(4)
col1.metric("Total Transactions", f"{int(kpi['total_txns']):,}")
col2.metric("Total Volume", f"${kpi['total_volume'] / 1e9:,.1f}B")
col3.metric("Fraud Cases", f"{int(kpi['total_fraud']):,}")
col4.metric("Unique Customers", f"{int(kpi['unique_customers']) / 1e6:,.2f}M")

st.divider()

# Navigation guide
st.subheader("Explore the Dashboard")
st.markdown(
    """
    Use the sidebar to navigate:

    - **Executive Overview** — headline KPIs and transaction-type breakdown
    - **Transaction Trends** — daily volume, rolling averages, growth
    - **Customer Analysis** — customer tiers and behavior segments
    - **Fraud Analytics** — risk signals and suspicious transactions
    """
)

render_footer()