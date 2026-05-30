"""Transaction Trends page."""

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

st.set_page_config(page_title="Transaction Trends", page_icon="📈", layout="wide")

inject_css()
render_sidebar_brand()

st.title("Transaction Trends")
st.markdown(
    "<div style='color: #64748b; font-size: 1.0rem; margin-top: -0.5rem;'>"
    "Daily transaction patterns with rolling averages and growth metrics."
    "</div>",
    unsafe_allow_html=True,
)
st.divider()

# Pull aggregate for hero KPI
overall = run_query("""
    SELECT SUM(txn_count) AS total_txns,
           COUNT(DISTINCT day_number) AS day_count
    FROM fact_daily_metrics;
""").iloc[0]

# Hero KPI
render_hero_kpi(
    label="Activity Window",
    value=f"{int(overall['day_count'])} Days",
    context=(
        f"{int(overall['total_txns']):,} transactions captured across "
        f"5 transaction types. Rolling 7-day averages smooth daily noise."
    ),
)

# Insight box
render_insight_box(
    insight=(
        "Daily transaction volume shows anomalous drops on <b>days 3–5</b> "
        "(down ~99% from baseline). The <b>rolling 7-day average</b> smooths "
        "these spikes, providing a more trustworthy view than raw daily counts."
    ),
    why_it_matters=(
        "Stakeholders viewing raw charts would see a 'business collapse' that "
        "isn't real. The smoothed view prevents false alarms and supports "
        "reliable period-over-period comparisons."
    ),
    action=(
        "Use rolling averages (not raw daily counts) as the default time-series "
        "view for executive reporting. Investigate raw anomalies separately as "
        "data-quality flags."
    ),
)

# Filter
types_df = run_query("SELECT DISTINCT type FROM fact_daily_metrics ORDER BY type;")
type_options = types_df["type"].tolist()
selected_type = st.selectbox(
    "Select transaction type:",
    options=type_options,
    index=type_options.index("TRANSFER") if "TRANSFER" in type_options else 0,
)

trend_data = run_query(f"""
    SELECT day_number, txn_count, total_amount, rolling_7d_avg,
           dod_pct_change, cumulative_txn_count
    FROM fact_daily_metrics
    WHERE type = '{selected_type}'
    ORDER BY day_number;
""")

# Combo chart
st.subheader(f"Daily Transaction Count — {selected_type}")
st.markdown(
    "<div style='color: #64748b; font-size: 0.95rem;'>"
    "The <strong>rolling 7-day average</strong> (orange) smooths over daily volatility, "
    "including the data anomalies around days 3-5."
    "</div>",
    unsafe_allow_html=True,
)

fig1 = go.Figure()
fig1.add_trace(go.Bar(
    x=trend_data["day_number"], y=trend_data["txn_count"],
    name="Daily Count", marker_color=COLORS["primary"], opacity=0.5,
))
fig1.add_trace(go.Scatter(
    x=trend_data["day_number"], y=trend_data["rolling_7d_avg"],
    name="7-Day Rolling Avg", mode="lines+markers",
    line=dict(color=COLORS["warning"], width=3),
))
fig1.update_layout(
    xaxis_title="Day Number", yaxis_title="Transaction Count",
    hovermode="x unified",
)

day4_row = trend_data[trend_data["day_number"] == 4]
if not day4_row.empty:
    fig1.add_annotation(
        x=4, y=day4_row["txn_count"].iloc[0],
        text="<b>Data anomaly</b><br>Days 3-5 are simulation gaps,<br>smoothed by the rolling avg",
        showarrow=True, arrowhead=2, arrowcolor="#475569",
        ax=80, ay=-60,
        bgcolor="white", bordercolor="#cbd5e1", borderwidth=1, borderpad=6,
        font=dict(size=11, color="#0f172a"),
    )

st.plotly_chart(style_fig(fig1, height=420), use_container_width=True)

st.divider()

# Charts row 2
left, right = st.columns(2)

with left:
    st.subheader("Day-over-Day Growth (%, excl. anomaly)")
    st.caption(
        "Days 3-6 omitted (simulation gap & recovery). "
        "Shows normal business volatility."
    )
    trend_normal = trend_data[~trend_data["day_number"].isin([3, 4, 5, 6])].copy()
    fig2 = px.bar(
        trend_normal, x="day_number", y="dod_pct_change",
        labels={"dod_pct_change": "DoD Change (%)", "day_number": "Day"},
        color="dod_pct_change", color_continuous_scale="RdYlGn",
        range_color=[-30, 30],
    )
    fig2.update_yaxes(range=[-30, 30])
    st.plotly_chart(style_fig(fig2, show_legend=False), use_container_width=True)

with right:
    st.subheader("Cumulative Transactions")
    fig3 = px.area(
        trend_data, x="day_number", y="cumulative_txn_count",
        labels={"cumulative_txn_count": "Cumulative Count", "day_number": "Day"},
    )
    fig3.update_traces(line_color=COLORS["success"], fillcolor="rgba(5,150,105,0.15)")
    st.plotly_chart(style_fig(fig3, show_legend=False), use_container_width=True)

st.divider()

# Summary metrics
total_for_type = int(trend_data["txn_count"].sum())
peak_day = int(trend_data.loc[trend_data["txn_count"].idxmax(), "day_number"])
peak_count = int(trend_data["txn_count"].max())

m1, m2, m3 = st.columns(3)
m1.metric(f"Total {selected_type} Transactions", f"{total_for_type:,}")
m2.metric("Peak Day", f"Day {peak_day}")
m3.metric("Peak Day Count", f"{peak_count:,}")

with st.expander("View underlying data"):
    st.dataframe(trend_data, use_container_width=True)

render_footer()