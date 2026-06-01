--
-- PostgreSQL database dump
--

\restrict DtAcfZFXhQOleOKANri0HQzqSGx7fABErRUvluLDAFU8bUCViuf6ZXv1vMSgDLr

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
-- Name: dim_customers; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.dim_customers AS
 WITH all_customer_activity AS (
         SELECT raw_transactions.name_orig AS customer_id,
            raw_transactions.step,
            raw_transactions.amount,
            raw_transactions.is_fraud,
            'sender'::text AS role
           FROM public.raw_transactions
        UNION ALL
         SELECT raw_transactions.name_dest AS customer_id,
            raw_transactions.step,
            raw_transactions.amount,
            raw_transactions.is_fraud,
            'receiver'::text AS role
           FROM public.raw_transactions
          WHERE ("left"((raw_transactions.name_dest)::text, 1) = 'C'::text)
        ), customer_metrics AS (
         SELECT all_customer_activity.customer_id,
            min(all_customer_activity.step) AS first_seen_step,
            max(all_customer_activity.step) AS last_seen_step,
            count(*) FILTER (WHERE (all_customer_activity.role = 'sender'::text)) AS txns_sent,
            count(*) FILTER (WHERE (all_customer_activity.role = 'receiver'::text)) AS txns_received,
            count(*) AS total_txns,
            sum(all_customer_activity.amount) FILTER (WHERE (all_customer_activity.role = 'sender'::text)) AS amount_sent,
            sum(all_customer_activity.amount) FILTER (WHERE (all_customer_activity.role = 'receiver'::text)) AS amount_received,
            max(all_customer_activity.is_fraud) AS ever_involved_in_fraud
           FROM all_customer_activity
          GROUP BY all_customer_activity.customer_id
        )
 SELECT customer_id,
    first_seen_step,
    last_seen_step,
    (last_seen_step - first_seen_step) AS lifespan_steps,
    txns_sent,
    txns_received,
    total_txns,
    COALESCE(amount_sent, (0)::numeric) AS amount_sent,
    COALESCE(amount_received, (0)::numeric) AS amount_received,
    (COALESCE(amount_sent, (0)::numeric) + COALESCE(amount_received, (0)::numeric)) AS total_amount,
    ever_involved_in_fraud,
    ntile(4) OVER (ORDER BY (COALESCE(amount_sent, (0)::numeric) + COALESCE(amount_received, (0)::numeric)) DESC) AS customer_tier
   FROM customer_metrics
  WITH NO DATA;


--
-- Name: idx_dim_customers_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_dim_customers_customer_id ON public.dim_customers USING btree (customer_id);


--
-- Name: idx_dim_customers_fraud; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dim_customers_fraud ON public.dim_customers USING btree (ever_involved_in_fraud);


--
-- Name: idx_dim_customers_tier; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dim_customers_tier ON public.dim_customers USING btree (customer_tier);


--
-- Name: dim_customers; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: -
--

REFRESH MATERIALIZED VIEW public.dim_customers;


--
-- PostgreSQL database dump complete
--

\unrestrict DtAcfZFXhQOleOKANri0HQzqSGx7fABErRUvluLDAFU8bUCViuf6ZXv1vMSgDLr

