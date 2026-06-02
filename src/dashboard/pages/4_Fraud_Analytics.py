"""Fraud Analytics page."""

import streamlit as st
import plotly.express as px
import plotly.graph_objects as go

import sys
from pathlib import Path
sys.path.append(str(Path(__file__).resolve().parents[1]))
from db import run_query
from theme import style_fig, COLORS
from ui import (
    inject_css, render_sidebar_brand, render_footer,
    render_insight_box, render_hero_kpi,
)

st.set_page_config(page_title="Fraud Analytics", page_icon="🚨", layout="wide")

inject_css()
render_sidebar_brand()

st.title("Fraud Analytics")
st.markdown(
    "<div style='color: #64748b; font-size: 1.0rem; margin-top: -0.5rem;'>"
    "Rule-based fraud signals and risk scoring. Each transaction is scored 1-3 "
    "based on how many risk signals it triggers."
    "</div>",
    unsafe_allow_html=True,
)
st.divider()

# Load pre-aggregated deploy tables
overall   = run_query("SELECT * FROM deploy_fraud_overall;").iloc[0]
risk_dist = run_query("SELECT * FROM deploy_fraud_risk_dist ORDER BY risk_score;")
type_fraud = run_query("SELECT * FROM deploy_fraud_type_summary ORDER BY flagged_txns DESC;")

score1_precision = 100.0 * float(overall["score1_fraud"]) / float(overall["score1_count"])

render_hero_kpi(
    label="Risk Score 1 Precision",
    value=f"{score1_precision:.1f}%",
    context=(
        f"{int(overall['score1_fraud']):,} of {int(overall['score1_count']):,} "
        "Risk Score 1 flags are confirmed fraud — the strongest single signal "
        "in the scoring model."
    ),
)

c1, c2, c3 = st.columns(3)
c1.metric("Flagged Transactions", f"{int(overall['flagged_txns']):,}")
c2.metric("Confirmed Fraud (in flagged)", f"{int(overall['true_fraud']):,}")
c3.metric("Risk Score 1 Transactions", f"{int(overall['score1_count']):,}")

st.divider()

render_insight_box(
    insight=(
        f"<b>Risk Score 1 detects fraud with ~{score1_precision:.0f}% precision</b> "
        f"({int(overall['score1_fraud']):,} of {int(overall['score1_count']):,} "
        "flagged transactions are real fraud). Higher scores (2 and 3) have "
        "near-zero precision because a balance-mismatch signal fires on most "
        "TRANSFER/CASH_OUT transactions regardless of fraud."
    ),
    why_it_matters=(
        "Adding 'more signals' doesn't increase precision — it dilutes the "
        "score when one signal is noisy. Score 2's 2.5M false positives would "
        "overwhelm any investigation team."
    ),
    action=(
        "Drop the balance-mismatch signal from scoring weight, or replace "
        "additive scoring with a weighted/Bayesian approach that down-weights "
        "low-precision signals."
    ),
)

risk_dist["risk_label"] = "Score " + risk_dist["risk_score"].astype(str)

st.subheader("Risk Score Precision")
st.markdown(
    "<div style='color: #64748b; font-size: 0.95rem;'>"
    "Score 1 catches fraud cleanly; Scores 2 and 3 are diluted by the noisy "
    "balance-mismatch signal."
    "</div>",
    unsafe_allow_html=True,
)

gauge_col, flagged_col, precision_col = st.columns([1, 1, 1])

with gauge_col:
    st.markdown("**Score 1 Precision Gauge**")
    fig_gauge = go.Figure(go.Indicator(
        mode="gauge+number",
        value=score1_precision,
        number={"suffix": "%", "font": {"size": 36, "color": "#0f172a"}},
        gauge={
            "axis": {"range": [0, 100], "tickwidth": 1, "tickcolor": "#cbd5e1"},
            "bar": {"color": "#059669", "thickness": 0.7},
            "bgcolor": "#f1f5f9",
            "borderwidth": 0,
            "steps": [
                {"range": [0, 50],  "color": "#fee2e2"},
                {"range": [50, 80], "color": "#fef3c7"},
                {"range": [80, 100],"color": "#dcfce7"},
            ],
            "threshold": {
                "line": {"color": "#1e3a8a", "width": 3},
                "thickness": 0.75,
                "value": score1_precision,
            },
        },
    ))
    fig_gauge.update_layout(
        height=280, margin=dict(l=20, r=20, t=20, b=20),
        paper_bgcolor="rgba(0,0,0,0)",
        font=dict(family="Inter, system-ui, sans-serif", color="#475569"),
    )
    st.plotly_chart(fig_gauge, use_container_width=True)

with flagged_col:
    st.markdown("**Transactions Flagged**")
    fig1 = px.bar(
        risk_dist, x="risk_label", y="flagged_txns", text_auto=".2s",
        labels={"flagged_txns": "Flagged", "risk_label": "Risk Score"},
        color="risk_label",
    )
    st.plotly_chart(style_fig(fig1, height=280, show_legend=False), use_container_width=True)

with precision_col:
    st.markdown("**Precision by Score (%)**")
    fig2 = px.bar(
        risk_dist, x="risk_label", y="precision_pct", text_auto=".2f",
        labels={"precision_pct": "Precision (%)", "risk_label": "Risk Score"},
        color="precision_pct", color_continuous_scale="RdYlGn",
    )
    st.plotly_chart(style_fig(fig2, height=280, show_legend=False), use_container_width=True)

st.divider()

st.subheader("Flagged Transactions by Type")
fig3 = px.bar(
    type_fraud, x="type", y=["flagged_txns", "true_fraud"], barmode="group",
    labels={"value": "Count", "type": "Transaction Type", "variable": "Metric"},
)
st.plotly_chart(style_fig(fig3), use_container_width=True)

st.divider()

st.subheader("Suspicious Transactions")
st.markdown(
    "<div style='color: #64748b; font-size: 0.95rem;'>"
    "Filter by risk score to investigate flagged transactions."
    "</div>",
    unsafe_allow_html=True,
)

risk_filter = st.selectbox("Minimum risk score:", options=[1, 2, 3], index=0)
suspicious = run_query(f"""
    SELECT day_number, type, name_orig, name_dest, amount, risk_score, is_fraud
    FROM deploy_fraud_suspicious
    WHERE risk_score >= {risk_filter}
    ORDER BY amount DESC
    LIMIT 100;
""")
st.caption(f"Showing top 100 flagged transactions with risk score ≥ {risk_filter}")
st.dataframe(suspicious, use_container_width=True)

with st.expander("View risk score summary"):
    st.dataframe(risk_dist, use_container_width=True)

render_footer()