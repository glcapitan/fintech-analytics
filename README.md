# Fintech Transaction Analytics Dashboard

> A business intelligence dashboard analyzing **6.36 million** mobile money transactions — surfacing fraud signals, customer segmentation insights, and transaction trends from a synthetic fintech dataset.

**Built with:** PostgreSQL · Python (pandas, SQLAlchemy) · Streamlit · Plotly

---

## 📊 Live Demo

> *Deployment pending — see [Setup](#setup) below to run locally.*

![Dashboard preview](docs/preview.png)

---

## 🎯 The Problem

A fintech processing millions of mobile money transactions per day needs leadership and ops teams to answer recurring questions without waiting on manual SQL pulls:

- *Where is fraud actually happening, and at what rate?*
- *Which customers concentrate the most volume — and the most risk?*
- *Is daily transaction volume trending up or down, and how do we read past data anomalies?*

This dashboard turns those questions into a self-service tool backed by a real data pipeline, eliminating the "ad-hoc SQL request → 4-hour Excel export → email back" cycle that bottlenecks analytics teams.

---

## 🔍 Key Findings

Each finding is surfaced directly on the relevant dashboard page with an insight box and chart annotation. Quick summary:

### 1. Fraud lives in outbound flows only
Across 6.36M transactions, fraud occurs **only in TRANSFER (0.77%) and CASH_OUT (0.18%)** — the transaction types that move money *out* of the system. Cash-ins, payments, and debits show **zero fraud across 3.6M+ records**. This matches the classic "transfer to mule account → cash out → disappear" pattern.

> **Action:** Concentrate real-time fraud monitoring on TRANSFER and CASH_OUT events. Lower-frequency monitoring on other types.

### 2. More signals ≠ better fraud detection
Built a rule-based risk scoring layer (1–3 signals). Discovered that **Risk Score 1 catches fraud with 97% precision (6,218 of 6,409 flagged are real fraud)**, while Risk Scores 2 and 3 have **near-zero precision** because a balance-mismatch signal fires on most TRANSFER/CASH_OUT transactions regardless of fraud.

> **Lesson:** Adding more signals can *dilute* detection if one signal is noisy. Validate each signal's standalone precision before combining.

### 3. Customer volume follows extreme long-tail
Tier 1 (top quartile) customers average **164× more transaction volume than Tier 4**. The customer base also includes **~570K receive-only customers (8%)** who never initiate a transaction — a segment that would be invisible if `dim_customers` only counted senders.

> **Action:** Apply tier-aware risk thresholds for Tier 1. Investigate receive-only customers for activation opportunities.

### 4. Data anomalies require smoothing, not hiding
Daily transaction volume drops ~99% on days 3–5 (simulation gaps in the source dataset). Rather than dropping the rows, the dashboard uses **7-day rolling averages** so the time-series view stays trustworthy without false-alarming on data-quality issues.

> **Lesson:** Don't hide data anomalies — surface them with appropriate smoothing and flag them separately for data-quality investigation.

---

## 🏗️ Architecture
┌──────────────────┐
                            │  PaySim CSV      │
                            │  (6.36M rows)    │
                            └────────┬─────────┘
                                     │
                                     ▼
                            ┌──────────────────┐
                            │  Python ETL      │  pandas + SQLAlchemy
                            │  (chunked load)  │  100k-row chunks, logging
                            └────────┬─────────┘
                                     │
                                     ▼
            ┌────────────────────────────────────────────┐
            │  PostgreSQL                                │
            │                                            │
            │   raw_transactions  (bronze layer)         │
            │           │                                │
            │           ▼  (CTEs + window functions)     │
            │   dim_customers                            │
            │   fact_daily_metrics                       │
            │   fact_customer_cohorts                    │
            │   fact_fraud_signals     (gold layer)      │
            └────────────────────┬───────────────────────┘
                                 │
                                 ▼
                        ┌──────────────────┐
                        │  Streamlit App   │  5 pages, Plotly charts
                        │  (cached queries)│  insight boxes
                        └──────────────────┘
                        **Pattern**: Medallion architecture (bronze → gold). Raw data is ingested once, then transformations build pre-aggregated analytics tables (materialized views) that the dashboard queries directly. This means the dashboard reads ~150 rows per page load instead of scanning 6.36M raw rows — making the UI snappy.

---

## 🧩 Tech Stack & Rationale

| Layer | Tool | Why |
|---|---|---|
| Database | PostgreSQL 18 | Free, supports advanced SQL (CTEs, window functions, materialized views, stored procedures) |
| ETL | Python + pandas + SQLAlchemy | Chunked CSV reads handle the 493 MB file without exhausting memory |
| Secrets | python-dotenv | `.env` file kept out of Git via `.gitignore` |
| Transformation | Raw SQL (in `sql/transformations/`) | Keeps logic close to the data; version-controlled |
| Dashboard | Streamlit + Plotly | Fast Python-only iteration; interactive charts |
| Caching | `@st.cache_data` / `@st.cache_resource` | Query results cached 10 min; engine instantiated once per session |
| Version control | Git + GitHub | Clean commit history per day's work |

---

## 🛠️ SQL Techniques Demonstrated

This project uses every SQL pattern commonly asked in analyst interviews:

- **CTEs** — multi-step transformation pipelines (e.g. `01_dim_customers.sql` chains 3 CTEs)
- **Window functions** — `LAG()` for day-over-day, `AVG() OVER (ROWS BETWEEN n PRECEDING...)` for rolling averages, `SUM() OVER (... UNBOUNDED PRECEDING ...)` for cumulative totals, `NTILE(4)` for tier quartiles
- **`PERCENTILE_CONT`** — statistically-derived thresholds in fraud signals (99th percentile by type)
- **`COUNT(*) FILTER (WHERE ...)`** — conditional aggregation without verbose CASE statements
- **Materialized views** — pre-aggregated tables for dashboard performance
- **`UNION ALL`** with `MIN()/MAX()` — combining sender + receiver activity into a unified customer dimension
- **`COALESCE` / `NULLIF`** — defensive NULL handling (especially for safe division)

See [`sql/transformations/`](sql/transformations/) for the full transformation layer.

---

## 📂 Project Structure
fintech-analytics/
├── data/
│   └── paysim.csv                        # raw dataset (not in repo, ~493 MB)
├── sql/
│   └── transformations/
│       ├── 01_dim_customers.sql          # customer dimension (NTILE tiers)
│       ├── 02_fact_daily_metrics.sql     # daily aggregates + window functions
│       ├── 03_fact_customer_cohorts.sql  # cohort retention pipeline
│       └── 04_fact_fraud_signals.sql     # rule-based fraud scoring
├── src/
│   ├── dashboard/
│   │   ├── Home.py                       # landing page
│   │   ├── db.py                         # cached DB connection
│   │   ├── theme.py                      # Plotly chart styling
│   │   ├── ui.py                         # custom CSS, insight boxes, footer
│   │   ├── pages/
│   │   │   ├── 1_Executive_Overview.py
│   │   │   ├── 2_Transaction_Trends.py
│   │   │   ├── 3_Customer_Analysis.py
│   │   │   └── 4_Fraud_Analytics.py
│   │   └── .streamlit/
│   │       └── config.toml               # navy/slate theme config
│   └── etl/
│       └── load_raw_data.py              # CSV → Postgres pipeline
├── requirements.txt
├── .gitignore
└── README.md
---

## ⚙️ Setup

### Prerequisites
- Python 3.10+
- PostgreSQL 15+
- ~1 GB free disk for the dataset

### Steps

1. **Clone the repo**
```bash
   git clone https://github.com/glcapitan/fintech-analytics.git
   cd fintech-analytics
```

2. **Set up Python environment**
```bash
   python -m venv venv
   venv\Scripts\activate          # Windows
   # source venv/bin/activate     # macOS/Linux
   pip install -r requirements.txt
```

3. **Set up PostgreSQL**
```bash
   psql -U postgres
   CREATE DATABASE fintech_analytics;
   \q
```

4. **Configure credentials**
   Create a `.env` file in the project root:
   DB_HOST=localhost
DB_PORT=5432
DB_NAME=fintech_analytics
DB_USER=postgres
DB_PASSWORD=your_password
5. **Download the dataset**
   Get [PaySim from Kaggle](https://www.kaggle.com/datasets/ealaxi/paysim1) and place the CSV at `data/paysim.csv`.

6. **Run the ETL**
```bash
   python src/etl/load_raw_data.py
```
   Loads ~6.36M rows in ~8 minutes (chunked, with progress logging).

7. **Build the analytics layer**
```bash
   psql -U postgres -d fintech_analytics -f sql/transformations/01_dim_customers.sql
   psql -U postgres -d fintech_analytics -f sql/transformations/02_fact_daily_metrics.sql
   psql -U postgres -d fintech_analytics -f sql/transformations/03_fact_customer_cohorts.sql
   psql -U postgres -d fintech_analytics -f sql/transformations/04_fact_fraud_signals.sql
```

8. **Run the dashboard**
```bash
   cd src/dashboard
   streamlit run Home.py
```
   Open [http://localhost:8501](http://localhost:8501).

---

## 📈 Performance Notes

- **Home page KPIs** originally queried raw transactions with `COUNT DISTINCT` (~60s). Repointed to pre-aggregated views — now **<1s**.
- **All dashboard pages** read from materialized views (152 rows for daily metrics, ~7M for customers but with unique indexes). No page query scans raw transactions directly.
- **Streamlit caching** (`@st.cache_data(ttl=600)`) prevents re-querying when users navigate between pages.

---

## 🚧 What I Would Add With More Time

- **dbt** to replace the raw `.sql` files — gives lineage tracking, tests, and documentation
- **Apache Airflow** to schedule ETL refreshes
- **Global filters** in the sidebar (date range, transaction type) that apply across all pages
- **Real cloud deployment** — migrate Postgres to Supabase/Neon and host the Streamlit app on Streamlit Community Cloud
- **A weighted/Bayesian fraud scoring approach** to fix the additive scoring dilution (per the Fraud Analytics page recommendation)

---

## 📬 Contact

Built by **Erwin Glenn Capitan** as a portfolio project demonstrating end-to-end BI analytics: data engineering, SQL transformation, dashboard development, and analytical narrative.

- GitHub: [@glcapitan](https://github.com/glcapitan)
- LinkedIn: *[https://www.linkedin.com/in/erwin-glenn-capitan-ii/]*

---

*Data source: [PaySim synthetic mobile money dataset](https://www.kaggle.com/datasets/ealaxi/paysim1) by Edgar Lopez-Rojas et al. (2016). The dataset is synthetic but modeled on real anonymized transaction patterns.*