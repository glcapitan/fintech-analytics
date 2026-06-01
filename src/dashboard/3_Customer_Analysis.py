"""Customer Analysis page."""

import streamlit as st
import plotly.express as px

import sys
from pathlib import Path
sys.path.append(str(Path(__file__).resolve().parents[1]))
from db import run_query
from theme import style_fig, COLORS
from ui import (
    inject_css, render_sidebar_brand, render_footer,
    render_insight_box, render_hero_kpi, render_rank_list,
)

st.set_page_config(page_title="Customer Analysis", page_icon="👥", layout="wide")

inject_css()
render_sidebar_brand()

st.title("Customer Analysis")
st.markdown(
    "<div style='color: #64748b; font-size: 1.0rem; margin-top: -0.5rem;'>"
    "Customer segmentation by transaction volume tier, behavior, and fraud exposure. "
    "Tiers are quartiles (1 = top 25% by volume, 4 = bottom 25%)."
    "</div>",
    unsafe_allow_html=True,
)
st.divider()

# Load pre-aggregated deploy tables
tier_data = run_query("SELECT * FROM deploy_tier_summary ORDER BY customer_tier;")
behavior  = run_query("SELECT * FROM deploy_customer_behavior;")
top20     = run_query("SELECT * FROM deploy_customer_top20;")

# Derive tier_summary and tier_volume from the single deploy table
tier_summary = tier_data.copy()
tier_summary["fraud_rate_pct"] = (
    100.0 * tier_summary["fraud_customers"] / tier_summary["customer_count"]
).round(4)
tier_summary["tier_label"] = "Tier " + tier_summary["customer_tier"].astype(str)

tier_volume = tier_data[["customer_tier", "total_volume_tier"]].copy()
tier_volume["tier_label"] = "Tier " + tier_volume["customer_tier"].astype(str)
tier_volume["pct_of_total"] = (
    100.0 * tier_volume["total_volume_tier"] / tier_volume["total_volume_tier"].sum()
).round(1)
tier_volume["display_text"] = tier_volume["pct_of_total"].apply(lambda v: f"{v}%")

tier1_pct        = tier_volume.loc[tier_volume["customer_tier"] == 1, "pct_of_total"].iloc[0]
total_customers  = int(tier_summary["customer_count"].sum())
total_fraud_cust = int(tier_summary["fraud_customers"].sum())

render_hero_kpi(
    label="Volume Concentration — Tier 1",
    value=f"{tier1_pct}%",
    context=(
        f"Top 25% of {total_customers:,} customers control {tier1_pct}% of total volume. "
        "Classic long-tail distribution typical of payment networks."
    ),
)

c1, c2, c3 = st.columns(3)
c1.metric("Total Customers", f"{total_customers:,}")
c2.metric("Fraud-Exposed Customers", f"{total_fraud_cust:,}")
c3.metric("Fraud Exposure Rate", f"{100.0 * total_fraud_cust / total_customers:.3f}%")

st.divider()

render_insight_box(
    insight=(
        f"Customer transaction volume follows an extreme long-tail. "
        f"<b>Tier 1 customers concentrate ~{tier1_pct}% of total volume</b> "
        "despite being 25% of the customer base. The base also includes "
        "~570K receive-only customers (8%) who never initiate transactions."
    ),
    why_it_matters=(
        "Tier 1 customers concentrate revenue exposure — anomalies here are "
        "high-stakes. Receive-only customers represent a different opportunity: "
        "they're in the platform but not transacting."
    ),
    action=(
        "Apply tier-aware risk thresholds (Tier 1 anomalies merit same-day "
        "review). Run an activation campaign targeting receive-only customers."
    ),
)

left, right = st.columns(2)

with left:
    st.subheader("Volume Concentration by Tier")
    st.caption(
        "Each tier has the same customer count by design (NTILE quartiles). "
        "This chart shows the volume concentrated in each — the real story."
    )
    fig1 = px.bar(
        tier_volume, x="tier_label", y="total_volume_tier",
        text="display_text",
        labels={"total_volume_tier": "Total Volume ($)", "tier_label": "Tier"},
        color="tier_label",
    )
    fig1.update_traces(textposition="outside")
    st.plotly_chart(style_fig(fig1, show_legend=False), use_container_width=True)

with right:
    st.subheader("Avg Transaction Volume per Tier")
    fig2 = px.bar(
        tier_summary, x="tier_label", y="avg_total_amount", text_auto=".2s",
        labels={"avg_total_amount": "Avg Volume ($)", "tier_label": "Tier"},
        color="avg_total_amount", color_continuous_scale="Blues",
    )
    fig2.add_annotation(
        x="Tier 1",
        y=tier_summary.loc[tier_summary["tier_label"] == "Tier 1", "avg_total_amount"].iloc[0],
        text="<b>164× more volume</b><br>than Tier 4",
        showarrow=True, arrowhead=2, arrowcolor="#475569",
        ax=60, ay=-40,
        bgcolor="white", bordercolor="#cbd5e1", borderwidth=1, borderpad=6,
        font=dict(size=11, color="#0f172a"),
    )
    st.plotly_chart(style_fig(fig2, show_legend=False), use_container_width=True)

st.divider()

st.subheader("Customer Behavior: Senders vs Receive-Only")
st.markdown(
    "<div style='color: #64748b; font-size: 0.95rem;'>"
    "About 8% of customers only ever <em>receive</em> transactions — they never "
    "initiate one. Capturing them prevents undercounting the customer base."
    "</div>",
    unsafe_allow_html=True,
)

left2, right2 = st.columns([1, 1])

with left2:
    fig3 = px.pie(behavior, names="behavior_type", values="customer_count", hole=0.55)
    fig3.update_traces(textposition="inside", textinfo="percent+label",
                       textfont=dict(color="white", size=12))
    st.plotly_chart(style_fig(fig3, height=320), use_container_width=True)

with right2:
    st.subheader("Fraud Exposure by Tier")
    fig4 = px.bar(
        tier_summary, x="tier_label", y="fraud_rate_pct", text_auto=".4f",
        labels={"fraud_rate_pct": "Fraud Rate (%)", "tier_label": "Tier"},
        color="fraud_rate_pct", color_continuous_scale="Reds",
    )
    st.plotly_chart(style_fig(fig4, height=320, show_legend=False), use_container_width=True)

st.divider()

st.subheader("Top 10 Customers by Total Volume")
st.markdown(
    "<div style='color: #64748b; font-size: 0.95rem; margin-bottom: 1rem;'>"
    "The customers concentrating the most transaction activity. "
    "Top 3 highlighted in navy."
    "</div>",
    unsafe_allow_html=True,
)

top10 = top20.head(10).reset_index(drop=True)
ranked_items = []
for idx, row in top10.iterrows():
    ranked_items.append({
        "rank": idx + 1,
        "name": row["customer_id"],
        "meta": f"Tier {int(row['customer_tier'])} · {int(row['total_txns'])} transactions",
        "value": f"${row['total_amount'] / 1e6:.1f}M",
    })
render_rank_list(ranked_items)

st.divider()

with st.expander("View full top 20 (table view)"):
    st.dataframe(top20, use_container_width=True)

with st.expander("View tier summary"):
    st.dataframe(tier_summary, use_container_width=True)

render_footer()