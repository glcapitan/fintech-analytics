--
-- PostgreSQL database dump
--

\restrict XInofR6IneDq5cE0FBqOYauIX6CqZhCAClj7EbVhRr07ZTTokokLJuvawcJffpf

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
-- Name: fact_fraud_signals; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.fact_fraud_signals AS
 WITH type_thresholds AS (
         SELECT raw_transactions.type,
            percentile_cont((0.99)::double precision) WITHIN GROUP (ORDER BY ((raw_transactions.amount)::double precision)) AS p99_amount
           FROM public.raw_transactions
          GROUP BY raw_transactions.type
        ), flagged AS (
         SELECT rt.step,
            (((rt.step - 1) / 24) + 1) AS day_number,
            rt.type,
            rt.name_orig,
            rt.name_dest,
            rt.amount,
            rt.oldbalance_orig,
            rt.newbalance_orig,
            rt.is_fraud,
            tt.p99_amount,
                CASE
                    WHEN ((rt.amount)::double precision > tt.p99_amount) THEN 1
                    ELSE 0
                END AS sig_large_amount,
                CASE
                    WHEN ((rt.newbalance_orig = (0)::numeric) AND (rt.amount > (0)::numeric)) THEN 1
                    ELSE 0
                END AS sig_account_drained,
                CASE
                    WHEN (abs(((rt.oldbalance_orig - rt.amount) - rt.newbalance_orig)) > (1)::numeric) THEN 1
                    ELSE 0
                END AS sig_balance_mismatch
           FROM (public.raw_transactions rt
             JOIN type_thresholds tt USING (type))
          WHERE ((rt.type)::text = ANY ((ARRAY['TRANSFER'::character varying, 'CASH_OUT'::character varying])::text[]))
        )
 SELECT step,
    day_number,
    type,
    name_orig,
    name_dest,
    amount,
    oldbalance_orig,
    newbalance_orig,
    is_fraud,
    sig_large_amount,
    sig_account_drained,
    sig_balance_mismatch,
    ((sig_large_amount + sig_account_drained) + sig_balance_mismatch) AS risk_score
   FROM flagged
  WHERE (((sig_large_amount + sig_account_drained) + sig_balance_mismatch) > 0)
  WITH NO DATA;


--
-- Name: idx_ffs_day; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ffs_day ON public.fact_fraud_signals USING btree (day_number);


--
-- Name: idx_ffs_is_fraud; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ffs_is_fraud ON public.fact_fraud_signals USING btree (is_fraud);


--
-- Name: idx_ffs_risk_score; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ffs_risk_score ON public.fact_fraud_signals USING btree (risk_score);


--
-- Name: idx_ffs_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ffs_type ON public.fact_fraud_signals USING btree (type);


--
-- Name: fact_fraud_signals; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: -
--

REFRESH MATERIALIZED VIEW public.fact_fraud_signals;


--
-- PostgreSQL database dump complete
--

\unrestrict XInofR6IneDq5cE0FBqOYauIX6CqZhCAClj7EbVhRr07ZTTokokLJuvawcJffpf

