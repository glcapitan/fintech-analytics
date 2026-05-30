"""
Shared chart styling for the Fintech Analytics dashboard.
Corporate light theme — navy/slate palette.
"""

# Navy/slate corporate palette
COLORS = {
    "primary": "#1e3a8a",     # navy
    "secondary": "#475569",   # slate
    "accent": "#0ea5e9",      # sky blue
    "success": "#059669",     # emerald
    "danger": "#b91c1c",      # crimson
    "warning": "#d97706",     # amber
    "muted": "#94a3b8",       # cool gray
}

# Ordered palette for categorical charts (5 transaction types)
CATEGORICAL_PALETTE = [
    "#1e3a8a",  # navy
    "#0ea5e9",  # sky
    "#059669",  # emerald
    "#d97706",  # amber
    "#b91c1c",  # crimson
    "#475569",  # slate
]


def style_fig(fig, height: int = 380, show_legend: bool = True):
    """Apply consistent corporate styling to a Plotly figure."""
    fig.update_layout(
        height=height,
        margin=dict(l=50, r=30, t=40, b=40),
        font=dict(family="Inter, -apple-system, system-ui, sans-serif",
                  size=13, color="#0f172a"),
        plot_bgcolor="rgba(0,0,0,0)",
        paper_bgcolor="rgba(0,0,0,0)",
        title="",
        title_font=dict(size=15, color="#0f172a"),
        hoverlabel=dict(
            font_size=13,
            bgcolor="white",
            bordercolor="#cbd5e1",
        ),
        showlegend=show_legend,
        legend=dict(
            orientation="h",
            yanchor="bottom", y=1.02,
            xanchor="right", x=1,
            font=dict(size=12, color="#475569"),
        ),
        legend_title_text="",
        colorway=CATEGORICAL_PALETTE,
    )
    fig.update_xaxes(
        showgrid=False,
        linecolor="#cbd5e1",
        tickfont=dict(color="#475569"),
        title_font=dict(color="#475569", size=12),
    )
    fig.update_yaxes(
        showgrid=True,
        gridcolor="#f1f5f9",
        linecolor="#cbd5e1",
        tickfont=dict(color="#475569"),
        title_font=dict(color="#475569", size=12),
    )
    return fig