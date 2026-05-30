"""Executive Overview page."""

import streamlit as st
import plotly.express as px

import sys
from pathlib import Path
sys.path.append(str(Path(__file__).resolve().parents[1]))
from db import run_query
from theme import style_fig, COLORS
from ui import (
    inject_css, render_sidebar_brand, render_footer,
    render_insight_box, render_hero_kpi,
)

st.set_page_config(page_title="Executive Overview", page_icon="📊", layout="wide")

inject_css()
render_sidebar_brand()

st.title("Executive Overview")
st.markdown(
    "<div style='color: #64748b; font-size: 1.0rem; margin-top: -0.5rem;'>"
    "High-level view of transaction activity, volume, and fraud exposure."
    "</div>",
    unsafe_allow_html=True,
)
st.divider()

# Data
type_summary = run_query("""
    SELECT type,
           SUM(txn_count)    AS txn_count,
           SUM(total_amount) AS total_amount,
           SUM(fraud_count)  AS fraud_count
    FROM fact_daily_metrics
    GROUP BY type
    ORDER BY txn_count DESC;
""")
type_summary["fraud_rate_pct"] = (
    100.0 * type_summary["fraud_count"] / type_summary["txn_count"]
).round(4)

# Computed values
total_txns = int(type_summary["txn_count"].sum())
total_volume = float(type_summary["total_amount"].sum())
total_fraud = int(type_summary["fraud_count"].sum())
overall_fraud_rate = 100.0 * total_fraud / total_txns

# Hero KPI: total volume (the headline executive number)
render_hero_kpi(
    label="Total Volume Processed",
    value=f"${total_volume / 1e9:,.1f}B",
    context=(
        f"{total_txns:,} transactions across 5 types · "
        f"{total_fraud:,} fraud cases ({overall_fraud_rate:.3f}% overall rate)"
    ),
)

# Supporting KPIs
c1, c2, c3, c4 = st.columns(4)
c1.metric("Total Transactions", f"{total_txns:,}")
c2.metric("Total Volume", f"${total_volume / 1e9:,.1f}B")
c3.metric("Total Fraud", f"{total_fraud:,}")
c4.metric("Overall Fraud Rate", f"{overall_fraud_rate:.3f}%")

st.divider()

# Insight box
render_insight_box(
    insight=(
        "Fraud is concentrated entirely in <b>TRANSFER (0.77%)</b> and "
        "<b>CASH_OUT (0.18%)</b> — the transaction types that move money "
        "<i>out</i> of the system. Cash-ins, payments, and debits show "
        "zero fraud across 3.6M+ transactions."
    ),
    why_it_matters=(
        "Fraudsters target outbound flows because that's where stolen money "
        "becomes spendable. This matches the classic 'transfer to mule account "
        "→ cash out → disappear' pattern."
    ),
    action=(
        "Concentrate real-time fraud detection on TRANSFER and CASH_OUT events. "
        "Other transaction types can be monitored at lower frequency without "
        "operational risk."
    ),
)

# Charts row 1
left, right = st.columns(2)

with left:
    st.subheader("Transaction Count by Type")
    fig_donut = px.pie(type_summary, names="type", values="txn_count", hole=0.55)
    fig_donut.update_traces(
        textposition="inside",
        textinfo="percent+label",
        textfont=dict(color="white", size=12),
    )
    st.plotly_chart(style_fig(fig_donut), use_container_width=True)

with right:
    st.subheader("Total Volume by Type")
    type_summary["volume_text"] = type_summary["total_amount"].apply(
        lambda v: f"${v / 1e9:.1f}B" if v >= 1e9 else f"${v / 1e6:.0f}M"
    )
    fig_vol = px.bar(
        type_summary, x="type", y="total_amount",
        text="volume_text",
        labels={"total_amount": "Total Volume ($)", "type": "Transaction Type"},
    )
    fig_vol.update_traces(marker_color=COLORS["primary"], textposition="outside")
    st.plotly_chart(style_fig(fig_vol, show_legend=False), use_container_width=True)

st.divider()

# Fraud rate
st.subheader("Fraud Rate by Transaction Type")
st.markdown(
    "<div style='color: #64748b; font-size: 0.95rem;'>"
    "Fraud is concentrated in <strong>TRANSFER</strong> and <strong>CASH_OUT</strong> "
    "— the transaction types that move money out of the system."
    "</div>",
    unsafe_allow_html=True,
)
fig_fraud = px.bar(
    type_summary, x="type", y="fraud_rate_pct", text_auto=".4f",
    color="fraud_rate_pct", color_continuous_scale=[[0, "#fee2e2"], [1, "#991b1b"]],
    labels={"fraud_rate_pct": "Fraud Rate (%)", "type": "Transaction Type"},
)
fig_fraud.add_annotation(
    x="TRANSFER", y=0.77,
    text="<b>Highest fraud rate</b><br>0.77% of TRANSFERs<br>are fraudulent",
    showarrow=True, arrowhead=2, arrowcolor="#475569",
    ax=80, ay=-50,
    bgcolor="white", bordercolor="#cbd5e1", borderwidth=1, borderpad=6,
    font=dict(size=11, color="#0f172a"),
)
st.plotly_chart(style_fig(fig_fraud, show_legend=False), use_container_width=True)

with st.expander("View underlying data"):
    st.dataframe(type_summary, use_container_width=True)

render_footer()