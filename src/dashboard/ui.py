"""
Shared UI helpers — custom CSS, sidebar brand, footer, insight boxes, hero KPI.
"""

import streamlit as st
from datetime import datetime


def inject_css():
    """Inject custom CSS — light theme, navy/slate, soft shadows, larger KPI cards."""
    st.markdown(
        """
        <style>
        .block-container {
            padding-top: 2rem;
            padding-bottom: 3rem;
            max-width: 1400px;
        }
        hr {
            margin: 1.5rem 0 !important;
            border-color: #e2e8f0 !important;
        }
        h2, h3 {
            color: #0f172a;
            letter-spacing: -0.01em;
        }
        /* KPI cards — bigger padding, soft shadow */
        div[data-testid="stMetric"] {
            background: #ffffff;
            border: 1px solid #f1f5f9;
            border-radius: 12px;
            padding: 22px 26px;
            box-shadow: 0 1px 3px rgba(15, 23, 42, 0.04),
                        0 4px 8px rgba(15, 23, 42, 0.03);
            transition: box-shadow 0.15s ease;
        }
        div[data-testid="stMetric"]:hover {
            box-shadow: 0 2px 6px rgba(15, 23, 42, 0.06),
                        0 8px 16px rgba(15, 23, 42, 0.04);
        }
        div[data-testid="stMetricLabel"] > div {
            text-transform: uppercase;
            font-size: 0.7rem;
            letter-spacing: 0.05em;
            color: #64748b;
            font-weight: 600;
        }
        div[data-testid="stMetricValue"] {
            font-size: 2.1rem;
            font-weight: 700;
            color: #0f172a;
            letter-spacing: -0.02em;
        }
        section[data-testid="stSidebar"] [data-testid="stSidebarNavLink"] {
            padding: 0.45rem 0.75rem;
        }
        div[data-testid="stDataFrame"] {
            border: 1px solid #e2e8f0;
            border-radius: 6px;
        }
        .dashboard-footer {
            margin-top: 3rem;
            padding-top: 1rem;
            border-top: 1px solid #e2e8f0;
            color: #94a3b8;
            font-size: 0.8rem;
            text-align: center;
        }
        h1 {
            color: #0f172a;
            letter-spacing: -0.02em;
            font-weight: 700;
        }
        /* Hero KPI card */
        .hero-kpi {
            background: linear-gradient(135deg, #1e3a8a 0%, #1e40af 100%);
            border-radius: 14px;
            padding: 28px 32px;
            margin-bottom: 1.5rem;
            box-shadow: 0 4px 12px rgba(30, 58, 138, 0.15),
                        0 12px 32px rgba(30, 58, 138, 0.08);
            color: #ffffff;
        }
        .hero-kpi-label {
            text-transform: uppercase;
            font-size: 0.75rem;
            letter-spacing: 0.08em;
            color: rgba(255, 255, 255, 0.75);
            font-weight: 600;
            margin-bottom: 6px;
        }
        .hero-kpi-value {
            font-size: 3rem;
            font-weight: 700;
            line-height: 1;
            letter-spacing: -0.03em;
            margin-bottom: 8px;
        }
        .hero-kpi-context {
            font-size: 0.95rem;
            color: rgba(255, 255, 255, 0.85);
            line-height: 1.4;
        }
        /* List-style ranked items (for top customers) */
        .rank-list {
            background: #ffffff;
            border: 1px solid #f1f5f9;
            border-radius: 10px;
            padding: 4px 0;
            box-shadow: 0 1px 3px rgba(15, 23, 42, 0.04);
        }
        .rank-item {
            display: flex;
            align-items: center;
            padding: 12px 18px;
            border-bottom: 1px solid #f1f5f9;
        }
        .rank-item:last-child {
            border-bottom: none;
        }
        .rank-badge {
            background: #f1f5f9;
            color: #475569;
            font-weight: 700;
            font-size: 0.85rem;
            width: 28px;
            height: 28px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 14px;
            flex-shrink: 0;
        }
        .rank-badge-top {
            background: #1e3a8a;
            color: white;
        }
        .rank-name {
            font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
            font-size: 0.9rem;
            color: #0f172a;
            font-weight: 500;
            flex-grow: 1;
        }
        .rank-meta {
            font-size: 0.78rem;
            color: #64748b;
            margin-top: 2px;
        }
        .rank-value {
            font-size: 1rem;
            font-weight: 700;
            color: #1e3a8a;
            margin-left: 14px;
        }
        </style>
        """,
        unsafe_allow_html=True,
    )


def render_sidebar_brand():
    """Render a branded header in the sidebar above the page nav."""
    st.sidebar.markdown(
        """
        <div style="padding: 0.5rem 0 1rem 0; border-bottom: 1px solid #e2e8f0; margin-bottom: 1rem;">
            <div style="font-size: 1.05rem; font-weight: 700; color: #1e3a8a; letter-spacing: -0.01em;">
                💳 Fintech Analytics
            </div>
            <div style="font-size: 0.75rem; color: #64748b; margin-top: 0.15rem;">
                Transaction Intelligence
            </div>
        </div>
        """,
        unsafe_allow_html=True,
    )


def render_footer(data_through: str = "Day 31"):
    """Footer with data freshness and project context."""
    now = datetime.now().strftime("%b %d, %Y")
    footer_html = (
        '<div class="dashboard-footer">'
        f'Data through <strong>{data_through}</strong> &nbsp;•&nbsp; '
        f'Page rendered {now} &nbsp;•&nbsp; '
        'Built with PostgreSQL, Python, and Streamlit'
        '</div>'
    )
    st.markdown(footer_html, unsafe_allow_html=True)


def render_insight_box(insight: str, why_it_matters: str, action: str):
    """The analyst-narrative callout."""
    html = (
        '<div style="background: #f8fafc; border-left: 4px solid #1e3a8a; '
        'border-radius: 6px; padding: 1rem 1.25rem; margin: 1rem 0 1.5rem 0;">'

        '<div style="font-size: 0.78rem; font-weight: 700; color: #1e3a8a; '
        'text-transform: uppercase; letter-spacing: 0.04em; margin-bottom: 0.5rem;">'
        '🔍 Key Insight</div>'

        f'<div style="color: #0f172a; font-size: 0.95rem; margin-bottom: 0.75rem;">{insight}</div>'

        '<div style="font-size: 0.78rem; font-weight: 700; color: #64748b; '
        'text-transform: uppercase; letter-spacing: 0.04em; margin-bottom: 0.25rem;">'
        'Why it matters</div>'

        f'<div style="color: #334155; font-size: 0.9rem; margin-bottom: 0.75rem;">{why_it_matters}</div>'

        '<div style="font-size: 0.78rem; font-weight: 700; color: #059669; '
        'text-transform: uppercase; letter-spacing: 0.04em; margin-bottom: 0.25rem;">'
        '✓ Recommended action</div>'

        f'<div style="color: #334155; font-size: 0.9rem;">{action}</div>'

        '</div>'
    )
    st.markdown(html, unsafe_allow_html=True)


def render_hero_kpi(label: str, value: str, context: str):
    """
    The big primary KPI at the top of a page — the single number that
    anchors the page's story.
    """
    html = (
        '<div class="hero-kpi">'
        f'<div class="hero-kpi-label">{label}</div>'
        f'<div class="hero-kpi-value">{value}</div>'
        f'<div class="hero-kpi-context">{context}</div>'
        '</div>'
    )
    st.markdown(html, unsafe_allow_html=True)


def render_rank_list(items: list):
    """
    Render a list-style ranked component (top customers, top transactions).

    Each item should be a dict with keys: rank, name, meta, value.
    """
    rows_html = ""
    for item in items:
        badge_class = "rank-badge rank-badge-top" if item.get("rank", 99) <= 3 else "rank-badge"
        rows_html += (
            '<div class="rank-item">'
            f'<div class="{badge_class}">{item["rank"]}</div>'
            '<div style="flex-grow: 1;">'
            f'<div class="rank-name">{item["name"]}</div>'
            f'<div class="rank-meta">{item["meta"]}</div>'
            '</div>'
            f'<div class="rank-value">{item["value"]}</div>'
            '</div>'
        )
    html = f'<div class="rank-list">{rows_html}</div>'
    st.markdown(html, unsafe_allow_html=True)