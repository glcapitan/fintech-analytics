--
-- PostgreSQL database dump
--

\restrict IrHhmnQc8tosss3A1yF5a15ZbvaVl0e6eKr1pRkArFN2zw5sDNf9VGQlV9hfYQj

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: fact_daily_metrics; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.fact_daily_metrics AS
 WITH daily_base AS (
         SELECT (((raw_transactions.step - 1) / 24) + 1) AS day_number,
            raw_transactions.type,
            count(*) AS txn_count,
            sum(raw_transactions.amount) AS total_amount,
            avg(raw_transactions.amount) AS avg_amount,
            count(*) FILTER (WHERE (raw_transactions.is_fraud = 1)) AS fraud_count,
            sum(raw_transactions.amount) FILTER (WHERE (raw_transactions.is_fraud = 1)) AS fraud_amount
           FROM public.raw_transactions
          GROUP BY (((raw_transactions.step - 1) / 24) + 1), raw_transactions.type
        )
 SELECT day_number,
    type,
    txn_count,
    round(total_amount, 2) AS total_amount,
    round(avg_amount, 2) AS avg_amount,
    fraud_count,
    round(COALESCE(fraud_amount, (0)::numeric), 2) AS fraud_amount,
    round(((100.0 * (fraud_count)::numeric) / (NULLIF(txn_count, 0))::numeric), 4) AS fraud_rate_pct,
    lag(txn_count, 1) OVER (PARTITION BY type ORDER BY day_number) AS prev_day_count,
    round(((100.0 * ((txn_count - lag(txn_count, 1) OVER (PARTITION BY type ORDER BY day_number)))::numeric) / (NULLIF(lag(txn_count, 1) OVER (PARTITION BY type ORDER BY day_number), 0))::numeric), 2) AS dod_pct_change,
    round(avg(txn_count) OVER (PARTITION BY type ORDER BY day_number ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS rolling_7d_avg,
    sum(txn_count) OVER (PARTITION BY type ORDER BY day_number ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_txn_count
   FROM daily_base
  ORDER BY type, day_number
  WITH NO DATA;


--
-- Name: idx_fdm_day; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fdm_day ON public.fact_daily_metrics USING btree (day_number);


--
-- Name: idx_fdm_day_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fdm_day_type ON public.fact_daily_metrics USING btree (day_number, type);


--
-- Name: idx_fdm_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fdm_type ON public.fact_daily_metrics USING btree (type);


--
-- Name: fact_daily_metrics; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: -
--

REFRESH MATERIALIZED VIEW public.fact_daily_metrics;


--
-- PostgreSQL database dump complete
--

\unrestrict IrHhmnQc8tosss3A1yF5a15ZbvaVl0e6eKr1pRkArFN2zw5sDNf9VGQlV9hfYQj

