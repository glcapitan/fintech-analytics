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

# Tier summary
tier_summary = run_query("""
    SELECT customer_tier, COUNT(*) AS customer_count,
           ROUND(AVG(total_amount), 2) AS avg_total_amount,
           ROUND(AVG(total_txns), 2)   AS avg_txns,
           SUM(ever_involved_in_fraud) AS fraud_customers
    FROM dim_customers
    GROUP BY customer_tier
    ORDER BY customer_tier;
""")
tier_summary["fraud_rate_pct"] = (
    100.0 * tier_summary["fraud_customers"] / tier_summary["customer_count"]
).round(4)
tier_summary["tier_label"] = "Tier " + tier_summary["customer_tier"].astype(str)

# Volume concentration data
tier_volume = run_query("""
    SELECT customer_tier,
           ROUND(SUM(total_amount), 2) AS total_volume_tier
    FROM dim_customers
    GROUP BY customer_tier
    ORDER BY customer_tier;
""")
tier_volume["tier_label"] = "Tier " + tier_volume["customer_tier"].astype(str)
tier_volume["pct_of_total"] = (
    100.0 * tier_volume["total_volume_tier"] / tier_volume["total_volume_tier"].sum()
).round(1)
tier_volume["display_text"] = tier_volume["pct_of_total"].apply(lambda v: f"{v}%")

tier1_pct = tier_volume.loc[tier_volume["customer_tier"] == 1, "pct_of_total"].iloc[0]
total_customers = int(tier_summary["customer_count"].sum())
total_fraud_customers = int(tier_summary["fraud_customers"].sum())

# Hero KPI
render_hero_kpi(
    label="Volume Concentration — Tier 1",
    value=f"{tier1_pct}%",
    context=(
        f"Top 25% of {total_customers:,} customers control {tier1_pct}% of total volume. "
        f"Classic long-tail distribution typical of payment networks."
    ),
)

# Supporting KPIs
c1, c2, c3 = st.columns(3)
c1.metric("Total Customers", f"{total_customers:,}")
c2.metric("Fraud-Exposed Customers", f"{total_fraud_customers:,}")
c3.metric(
    "Fraud Exposure Rate",
    f"{100.0 * total_fraud_customers / total_customers:.3f}%",
)

st.divider()

# Insight box
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

# Charts row 1: volume concentration + avg volume per tier
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

# Sender vs receive-only
st.subheader("Customer Behavior: Senders vs Receive-Only")
st.markdown(
    "<div style='color: #64748b; font-size: 0.95rem;'>"
    "About 8% of customers only ever <em>receive</em> transactions — they never "
    "initiate one. Capturing them prevents undercounting the customer base."
    "</div>",
    unsafe_allow_html=True,
)

behavior = run_query("""
    SELECT CASE WHEN txns_sent > 0 THEN 'Active Sender'
                ELSE 'Receive-Only' END AS behavior_type,
           COUNT(*) AS customer_count
    FROM dim_customers
    GROUP BY CASE WHEN txns_sent > 0 THEN 'Active Sender'
                  ELSE 'Receive-Only' END;
""")

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

# Top customers — styled rank list (mockup inspiration)
st.subheader("Top 10 Customers by Total Volume")
st.markdown(
    "<div style='color: #64748b; font-size: 0.95rem; margin-bottom: 1rem;'>"
    "The customers concentrating the most transaction activity. "
    "Top 3 highlighted in navy."
    "</div>",
    unsafe_allow_html=True,
)

top10 = run_query("""
    SELECT customer_id, total_txns, total_amount, customer_tier
    FROM dim_customers
    ORDER BY total_amount DESC
    LIMIT 10;
""")

# Convert to ranked items for the rank list component
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
    full_top = run_query("""
        SELECT customer_id, total_txns, amount_sent, amount_received, total_amount,
               customer_tier, ever_involved_in_fraud
        FROM dim_customers
        ORDER BY total_amount DESC
        LIMIT 20;
    """)
    st.dataframe(full_top, use_container_width=True)

with st.expander("View tier summary"):
    st.dataframe(tier_summary, use_container_width=True)

render_footer()