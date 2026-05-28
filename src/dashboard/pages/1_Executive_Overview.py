"""
Executive Overview page.

High-level KPIs and transaction-type breakdowns for leadership.
Reads from pre-aggregated materialized views for fast loads.
"""

import streamlit as st
import plotly.express as px

# db.py lives one folder up (in src/dashboard/), so we add it to the path
import sys
from pathlib import Path
sys.path.append(str(Path(__file__).resolve().parents[1]))
from db import run_query

# -----------------------------------------------------------------------------
# Page config
# -----------------------------------------------------------------------------
st.set_page_config(page_title="Executive Overview", page_icon="📊", layout="wide")

st.title("📊 Executive Overview")
st.markdown("High-level view of transaction activity, volume, and fraud exposure.")
st.divider()

# -----------------------------------------------------------------------------
# Load the data once (cached)
# -----------------------------------------------------------------------------
type_summary = run_query("""
    SELECT
        type,
        SUM(txn_count)    AS txn_count,
        SUM(total_amount) AS total_amount,
        SUM(fraud_count)  AS fraud_count
    FROM fact_daily_metrics
    GROUP BY type
    ORDER BY txn_count DESC;
""")

# Derive a fraud rate column in pandas (percentage)
type_summary["fraud_rate_pct"] = (
    100.0 * type_summary["fraud_count"] / type_summary["txn_count"]
).round(4)

# -----------------------------------------------------------------------------
# KPI row
# -----------------------------------------------------------------------------
total_txns = int(type_summary["txn_count"].sum())
total_volume = float(type_summary["total_amount"].sum())
total_fraud = int(type_summary["fraud_count"].sum())
overall_fraud_rate = 100.0 * total_fraud / total_txns

c1, c2, c3, c4 = st.columns(4)
c1.metric("Total Transactions", f"{total_txns:,}")
c2.metric("Total Volume", f"${total_volume / 1e9:,.1f}B")
c3.metric("Total Fraud", f"{total_fraud:,}")
c4.metric("Overall Fraud Rate", f"{overall_fraud_rate:.3f}%")

st.divider()

# -----------------------------------------------------------------------------
# Charts row 1: donut (count) + bar (volume)
# -----------------------------------------------------------------------------
left, right = st.columns(2)

with left:
    st.subheader("Transaction Count by Type")
    fig_donut = px.pie(
        type_summary,
        names="type",
        values="txn_count",
        hole=0.5,  # makes it a donut instead of a pie
    )
    fig_donut.update_traces(textposition="inside", textinfo="percent+label")
    st.plotly_chart(fig_donut, use_container_width=True)

with right:
    st.subheader("Total Volume by Type")
    fig_vol = px.bar(
        type_summary,
        x="type",
        y="total_amount",
        text_auto=".2s",  # auto-format bar labels (e.g. 2.2G)
        labels={"total_amount": "Total Volume ($)", "type": "Transaction Type"},
    )
    st.plotly_chart(fig_vol, use_container_width=True)

st.divider()

# -----------------------------------------------------------------------------
# Charts row 2: fraud rate by type
# -----------------------------------------------------------------------------
st.subheader("Fraud Rate by Transaction Type")
st.markdown(
    "Fraud is concentrated in **TRANSFER** and **CASH_OUT** — the transaction "
    "types that move money out of the system."
)

fig_fraud = px.bar(
    type_summary,
    x="type",
    y="fraud_rate_pct",
    text_auto=".4f",
    color="fraud_rate_pct",
    color_continuous_scale="Reds",
    labels={"fraud_rate_pct": "Fraud Rate (%)", "type": "Transaction Type"},
)
st.plotly_chart(fig_fraud, use_container_width=True)

# -----------------------------------------------------------------------------
# Raw data table (expandable)
# -----------------------------------------------------------------------------
with st.expander("View underlying data"):
    st.dataframe(type_summary, use_container_width=True)