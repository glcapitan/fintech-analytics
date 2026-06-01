--
-- PostgreSQL database dump
--

\restrict ZnUJIOHKjV2WBfcWse8MoxMNZchLSWtrpNgzihsUhakgOX5fRZxiGwtZsaTdSjI

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
-- Name: fact_customer_cohorts; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.fact_customer_cohorts AS
 WITH customer_activity AS (
         SELECT DISTINCT raw_transactions.name_orig AS customer_id,
            (((raw_transactions.step - 1) / 168) + 1) AS week_number
           FROM public.raw_transactions
        ), customer_cohort AS (
         SELECT customer_activity.customer_id,
            min(customer_activity.week_number) AS cohort_week
           FROM customer_activity
          GROUP BY customer_activity.customer_id
        ), cohort_activity AS (
         SELECT cc.cohort_week,
            ca.week_number AS active_week,
            (ca.week_number - cc.cohort_week) AS weeks_since_start,
            ca.customer_id
           FROM (customer_activity ca
             JOIN customer_cohort cc USING (customer_id))
        ), cohort_matrix AS (
         SELECT cohort_activity.cohort_week,
            cohort_activity.weeks_since_start,
            count(DISTINCT cohort_activity.customer_id) AS retained_customers
           FROM cohort_activity
          GROUP BY cohort_activity.cohort_week, cohort_activity.weeks_since_start
        ), cohort_size AS (
         SELECT cohort_matrix.cohort_week,
            cohort_matrix.retained_customers AS cohort_size_customers
           FROM cohort_matrix
          WHERE (cohort_matrix.weeks_since_start = 0)
        )
 SELECT cm.cohort_week,
    cm.weeks_since_start,
    cm.retained_customers,
    cs.cohort_size_customers,
    round(((100.0 * (cm.retained_customers)::numeric) / (NULLIF(cs.cohort_size_customers, 0))::numeric), 2) AS retention_pct
   FROM (cohort_matrix cm
     JOIN cohort_size cs USING (cohort_week))
  ORDER BY cm.cohort_week, cm.weeks_since_start
  WITH NO DATA;


--
-- Name: idx_fcc_cohort; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fcc_cohort ON public.fact_customer_cohorts USING btree (cohort_week);


--
-- Name: idx_fcc_since; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fcc_since ON public.fact_customer_cohorts USING btree (weeks_since_start);


--
-- Name: fact_customer_cohorts; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: -
--

REFRESH MATERIALIZED VIEW public.fact_customer_cohorts;


--
-- PostgreSQL database dump complete
--

\unrestrict ZnUJIOHKjV2WBfcWse8MoxMNZchLSWtrpNgzihsUhakgOX5fRZxiGwtZsaTdSjI

