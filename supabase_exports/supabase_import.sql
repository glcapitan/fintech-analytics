--
-- PostgreSQL database dump
--

\restrict enAtxbETxpAFScve1KAaZyCYOePUyBTIedUefHMajH7oFEgHfok5azNaF6zRYNw

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
-- Name: deploy_behavior_summary; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deploy_behavior_summary (
    behavior_type text,
    customer_count bigint
);


--
-- Name: deploy_fact_customer_cohorts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deploy_fact_customer_cohorts (
    cohort_week integer,
    weeks_since_start integer,
    retained_customers bigint,
    cohort_size_customers bigint,
    retention_pct numeric
);


--
-- Name: deploy_fact_daily_metrics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deploy_fact_daily_metrics (
    day_number integer,
    type character varying(20),
    txn_count bigint,
    total_amount numeric,
    avg_amount numeric,
    fraud_count bigint,
    fraud_amount numeric,
    fraud_rate_pct numeric,
    prev_day_count bigint,
    dod_pct_change numeric,
    rolling_7d_avg numeric,
    cumulative_txn_count numeric
);


--
-- Name: deploy_fraud_by_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deploy_fraud_by_type (
    type character varying(20),
    flagged_txns bigint,
    true_fraud bigint
);


--
-- Name: deploy_risk_summary; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deploy_risk_summary (
    risk_score integer,
    flagged_txns bigint,
    true_fraud bigint,
    precision_pct numeric
);


--
-- Name: deploy_suspicious; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deploy_suspicious (
    day_number integer,
    type character varying(20),
    name_orig character varying(20),
    name_dest character varying(20),
    amount numeric(15,2),
    risk_score integer,
    is_fraud smallint
);


--
-- Name: deploy_tier_summary; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deploy_tier_summary (
    customer_tier integer,
    customer_count bigint,
    avg_total_amount numeric,
    avg_txns numeric,
    fraud_customers bigint,
    total_volume_tier numeric
);


--
-- Name: deploy_top_customers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deploy_top_customers (
    customer_id character varying(20),
    total_txns bigint,
    amount_sent numeric,
    amount_received numeric,
    total_amount numeric,
    customer_tier integer,
    ever_involved_in_fraud smallint
);


--
-- Data for Name: deploy_behavior_summary; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.deploy_behavior_summary VALUES ('Active Sender', 6353307);
INSERT INTO public.deploy_behavior_summary VALUES ('Receive-Only', 570192);


--
-- Data for Name: deploy_fact_customer_cohorts; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.deploy_fact_customer_cohorts VALUES (1, 0, 1929323, 1929323, 100.00);
INSERT INTO public.deploy_fact_customer_cohorts VALUES (1, 1, 2592, 1929323, 0.13);
INSERT INTO public.deploy_fact_customer_cohorts VALUES (1, 2, 1145, 1929323, 0.06);
INSERT INTO public.deploy_fact_customer_cohorts VALUES (1, 3, 211, 1929323, 0.01);
INSERT INTO public.deploy_fact_customer_cohorts VALUES (1, 4, 58, 1929323, 0.00);
INSERT INTO public.deploy_fact_customer_cohorts VALUES (2, 0, 2850100, 2850100, 100.00);
INSERT INTO public.deploy_fact_customer_cohorts VALUES (2, 1, 1621, 2850100, 0.06);
INSERT INTO public.deploy_fact_customer_cohorts VALUES (2, 2, 302, 2850100, 0.01);
INSERT INTO public.deploy_fact_customer_cohorts VALUES (2, 3, 78, 2850100, 0.00);
INSERT INTO public.deploy_fact_customer_cohorts VALUES (3, 0, 1276128, 1276128, 100.00);
INSERT INTO public.deploy_fact_customer_cohorts VALUES (3, 1, 129, 1276128, 0.01);
INSERT INTO public.deploy_fact_customer_cohorts VALUES (3, 2, 31, 1276128, 0.00);
INSERT INTO public.deploy_fact_customer_cohorts VALUES (4, 0, 231482, 231482, 100.00);
INSERT INTO public.deploy_fact_customer_cohorts VALUES (4, 1, 7, 231482, 0.00);
INSERT INTO public.deploy_fact_customer_cohorts VALUES (5, 0, 66274, 66274, 100.00);


--
-- Data for Name: deploy_fact_daily_metrics; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.deploy_fact_daily_metrics VALUES (1, 'CASH_IN', 124026, 21238119433.10, 171239.25, 0, 0.00, 0.0000, NULL, NULL, 124026.00, 124026);
INSERT INTO public.deploy_fact_daily_metrics VALUES (2, 'CASH_IN', 99707, 16815829535.36, 168652.45, 0, 0.00, 0.0000, 124026, -19.61, 111866.50, 223733);
INSERT INTO public.deploy_fact_daily_metrics VALUES (3, 'CASH_IN', 137, 23705176.78, 173030.49, 0, 0.00, 0.0000, 99707, -99.86, 74623.33, 223870);
INSERT INTO public.deploy_fact_daily_metrics VALUES (4, 'CASH_IN', 4848, 784294262.02, 161776.87, 0, 0.00, 0.0000, 137, 3438.69, 57179.50, 228718);
INSERT INTO public.deploy_fact_daily_metrics VALUES (5, 'CASH_IN', 1450, 242178772.21, 167019.84, 0, 0.00, 0.0000, 4848, -70.09, 46033.60, 230168);
INSERT INTO public.deploy_fact_daily_metrics VALUES (6, 'CASH_IN', 99972, 17379844610.76, 173847.12, 0, 0.00, 0.0000, 1450, 6794.62, 55023.33, 330140);
INSERT INTO public.deploy_fact_daily_metrics VALUES (7, 'CASH_IN', 93735, 15839130158.79, 168977.76, 0, 0.00, 0.0000, 99972, -6.24, 60553.57, 423875);
INSERT INTO public.deploy_fact_daily_metrics VALUES (8, 'CASH_IN', 99924, 16683139677.33, 166958.29, 0, 0.00, 0.0000, 93735, 6.60, 57110.43, 523799);
INSERT INTO public.deploy_fact_daily_metrics VALUES (9, 'CASH_IN', 89361, 14255385478.59, 159525.81, 0, 0.00, 0.0000, 99924, -10.57, 55632.43, 613160);
INSERT INTO public.deploy_fact_daily_metrics VALUES (10, 'CASH_IN', 85807, 14692048873.30, 171222.03, 0, 0.00, 0.0000, 89361, -3.98, 67871.00, 698967);
INSERT INTO public.deploy_fact_daily_metrics VALUES (11, 'CASH_IN', 91109, 14978952974.81, 164406.95, 0, 0.00, 0.0000, 85807, 6.18, 80194.00, 790076);
INSERT INTO public.deploy_fact_daily_metrics VALUES (12, 'CASH_IN', 74454, 11448513498.55, 153766.27, 0, 0.00, 0.0000, 91109, -18.28, 90623.14, 864530);
INSERT INTO public.deploy_fact_daily_metrics VALUES (13, 'CASH_IN', 95840, 16810218128.56, 175398.77, 0, 0.00, 0.0000, 74454, 28.72, 90032.86, 960370);
INSERT INTO public.deploy_fact_daily_metrics VALUES (14, 'CASH_IN', 87298, 15310475051.39, 175381.74, 0, 0.00, 0.0000, 95840, -8.91, 89113.29, 1047668);
INSERT INTO public.deploy_fact_daily_metrics VALUES (15, 'CASH_IN', 89636, 15187645482.76, 169436.89, 0, 0.00, 0.0000, 87298, 2.68, 87643.57, 1137304);
INSERT INTO public.deploy_fact_daily_metrics VALUES (16, 'CASH_IN', 82591, 14072988949.33, 170393.73, 0, 0.00, 0.0000, 89636, -7.86, 86676.43, 1219895);
INSERT INTO public.deploy_fact_daily_metrics VALUES (17, 'CASH_IN', 93494, 16180255844.05, 173061.97, 0, 0.00, 0.0000, 82591, 13.20, 87774.57, 1313389);
INSERT INTO public.deploy_fact_daily_metrics VALUES (18, 'CASH_IN', 5065, 834857572.76, 164828.74, 0, 0.00, 0.0000, 93494, -94.58, 75482.57, 1318454);
INSERT INTO public.deploy_fact_daily_metrics VALUES (19, 'CASH_IN', 2709, 420175723.28, 155103.63, 0, 0.00, 0.0000, 5065, -46.52, 65233.29, 1321163);
INSERT INTO public.deploy_fact_daily_metrics VALUES (20, 'CASH_IN', 4366, 768702632.46, 176065.65, 0, 0.00, 0.0000, 2709, 61.17, 52165.57, 1325529);
INSERT INTO public.deploy_fact_daily_metrics VALUES (21, 'CASH_IN', 5634, 958074265.30, 170052.23, 0, 0.00, 0.0000, 4366, 29.04, 40499.29, 1331163);
INSERT INTO public.deploy_fact_daily_metrics VALUES (22, 'CASH_IN', 12005, 1977852667.94, 164752.41, 0, 0.00, 0.0000, 5634, 113.08, 29409.14, 1343168);
INSERT INTO public.deploy_fact_daily_metrics VALUES (23, 'CASH_IN', 11552, 1976997662.21, 171138.99, 0, 0.00, 0.0000, 12005, -3.77, 19260.71, 1354720);
INSERT INTO public.deploy_fact_daily_metrics VALUES (24, 'CASH_IN', 7417, 1297385680.66, 174920.54, 0, 0.00, 0.0000, 11552, -35.79, 6964.00, 1362137);
INSERT INTO public.deploy_fact_daily_metrics VALUES (25, 'CASH_IN', 13088, 2182680755.98, 166769.62, 0, 0.00, 0.0000, 7417, 76.46, 8110.14, 1375225);
INSERT INTO public.deploy_fact_daily_metrics VALUES (26, 'CASH_IN', 3289, 540132665.12, 164223.98, 0, 0.00, 0.0000, 13088, -74.87, 8193.00, 1378514);
INSERT INTO public.deploy_fact_daily_metrics VALUES (27, 'CASH_IN', 2093, 357315320.15, 170719.22, 0, 0.00, 0.0000, 3289, -36.36, 7868.29, 1380607);
INSERT INTO public.deploy_fact_daily_metrics VALUES (28, 'CASH_IN', 3576, 616923469.14, 172517.75, 0, 0.00, 0.0000, 2093, 70.86, 7574.29, 1384183);
INSERT INTO public.deploy_fact_daily_metrics VALUES (29, 'CASH_IN', 12682, 2102150748.55, 165758.61, 0, 0.00, 0.0000, 3576, 254.64, 7671.00, 1396865);
INSERT INTO public.deploy_fact_daily_metrics VALUES (30, 'CASH_IN', 2419, 391416841.22, 161809.36, 0, 0.00, 0.0000, 12682, -80.93, 6366.29, 1399284);
INSERT INTO public.deploy_fact_daily_metrics VALUES (1, 'CASH_OUT', 204397, 37494515023.43, 183439.65, 141, 105052284.00, 0.0690, NULL, NULL, 204397.00, 204397);
INSERT INTO public.deploy_fact_daily_metrics VALUES (2, 'CASH_OUT', 164605, 30174273583.15, 183313.23, 156, 189542212.63, 0.0948, 204397, -19.47, 184501.00, 369002);
INSERT INTO public.deploy_fact_daily_metrics VALUES (3, 'CASH_OUT', 240, 210208801.75, 875870.01, 155, 197254430.30, 64.5833, 164605, -99.85, 123080.67, 369242);
INSERT INTO public.deploy_fact_daily_metrics VALUES (4, 'CASH_OUT', 6252, 1266226024.29, 202531.35, 131, 219123408.01, 2.0953, 240, 2505.00, 93873.50, 375494);
INSERT INTO public.deploy_fact_daily_metrics VALUES (5, 'CASH_OUT', 1769, 421612593.09, 238333.86, 126, 122490289.06, 7.1227, 6252, -71.71, 75452.60, 377263);
INSERT INTO public.deploy_fact_daily_metrics VALUES (6, 'CASH_OUT', 159596, 29962552928.50, 187740.00, 114, 183616791.20, 0.0714, 1769, 8921.82, 89476.50, 536859);
INSERT INTO public.deploy_fact_daily_metrics VALUES (7, 'CASH_OUT', 151338, 27521970690.45, 181857.63, 136, 200895064.40, 0.0899, 159596, -5.17, 98313.86, 688197);
INSERT INTO public.deploy_fact_daily_metrics VALUES (8, 'CASH_OUT', 159368, 27933095710.36, 175274.18, 140, 176278328.06, 0.0878, 151338, 5.31, 91881.14, 847565);
INSERT INTO public.deploy_fact_daily_metrics VALUES (9, 'CASH_OUT', 147654, 23897607194.14, 161848.69, 128, 189954440.76, 0.0867, 159368, -7.35, 89459.57, 995219);
INSERT INTO public.deploy_fact_daily_metrics VALUES (10, 'CASH_OUT', 139113, 25039530978.48, 179994.18, 142, 186597841.10, 0.1021, 147654, -5.78, 109298.57, 1134332);
INSERT INTO public.deploy_fact_daily_metrics VALUES (11, 'CASH_OUT', 148021, 24527038700.32, 165699.72, 131, 209556941.33, 0.0885, 139113, 6.40, 129551.29, 1282353);
INSERT INTO public.deploy_fact_daily_metrics VALUES (12, 'CASH_OUT', 121504, 18001297741.46, 148153.95, 149, 213723259.99, 0.1226, 148021, -17.91, 146656.29, 1403857);
INSERT INTO public.deploy_fact_daily_metrics VALUES (13, 'CASH_OUT', 151884, 27505796082.75, 181097.39, 121, 212075245.21, 0.0797, 121504, 25.00, 145554.57, 1555741);
INSERT INTO public.deploy_fact_daily_metrics VALUES (14, 'CASH_OUT', 138626, 24833679745.22, 179141.57, 123, 136935916.96, 0.0887, 151884, -8.73, 143738.57, 1694367);
INSERT INTO public.deploy_fact_daily_metrics VALUES (15, 'CASH_OUT', 140175, 24414977154.40, 174174.98, 125, 194995405.36, 0.0892, 138626, 1.12, 140996.71, 1834542);
INSERT INTO public.deploy_fact_daily_metrics VALUES (16, 'CASH_OUT', 131588, 22830504394.17, 173499.90, 126, 167799567.40, 0.0958, 140175, -6.13, 138701.57, 1966130);
INSERT INTO public.deploy_fact_daily_metrics VALUES (17, 'CASH_OUT', 152162, 26218755453.93, 172308.17, 160, 316018128.53, 0.1052, 131588, 15.64, 140565.71, 2118292);
INSERT INTO public.deploy_fact_daily_metrics VALUES (18, 'CASH_OUT', 6201, 1268186670.97, 204513.25, 134, 262540484.50, 2.1609, 152162, -95.92, 120305.71, 2124493);
INSERT INTO public.deploy_fact_daily_metrics VALUES (19, 'CASH_OUT', 3230, 688469565.33, 213148.47, 128, 230364091.94, 3.9628, 6201, -47.91, 103409.43, 2127723);
INSERT INTO public.deploy_fact_daily_metrics VALUES (20, 'CASH_OUT', 6191, 1168512872.61, 188743.80, 118, 138341664.35, 1.9060, 3230, 91.67, 82596.14, 2133914);
INSERT INTO public.deploy_fact_daily_metrics VALUES (21, 'CASH_OUT', 7567, 1435561947.43, 189713.49, 136, 194611309.31, 1.7973, 6191, 22.23, 63873.43, 2141481);
INSERT INTO public.deploy_fact_daily_metrics VALUES (22, 'CASH_OUT', 16732, 2925898069.92, 174868.40, 128, 204409321.07, 0.7650, 7567, 121.12, 46238.71, 2158213);
INSERT INTO public.deploy_fact_daily_metrics VALUES (23, 'CASH_OUT', 16132, 2717095327.23, 168428.92, 108, 109694686.00, 0.6695, 16732, -3.59, 29745.00, 2174345);
INSERT INTO public.deploy_fact_daily_metrics VALUES (24, 'CASH_OUT', 10676, 1978674043.10, 185338.52, 140, 165457472.32, 1.3114, 16132, -33.82, 9532.71, 2185021);
INSERT INTO public.deploy_fact_daily_metrics VALUES (25, 'CASH_OUT', 19054, 3165375700.62, 166126.57, 120, 153925805.67, 0.6298, 10676, 78.48, 11368.86, 2204075);
INSERT INTO public.deploy_fact_daily_metrics VALUES (26, 'CASH_OUT', 4214, 795112322.83, 188683.51, 136, 196697165.16, 3.2273, 19054, -77.88, 11509.43, 2208289);
INSERT INTO public.deploy_fact_daily_metrics VALUES (27, 'CASH_OUT', 2834, 693212330.82, 244605.62, 140, 213598371.52, 4.9400, 4214, -32.75, 11029.86, 2211123);
INSERT INTO public.deploy_fact_daily_metrics VALUES (28, 'CASH_OUT', 4229, 935595788.07, 221233.34, 124, 187215492.45, 2.9321, 2834, 49.22, 10553.00, 2215352);
INSERT INTO public.deploy_fact_daily_metrics VALUES (29, 'CASH_OUT', 17965, 3262505549.91, 181603.43, 130, 250973387.33, 0.7236, 4229, 324.80, 10729.14, 2233317);
INSERT INTO public.deploy_fact_daily_metrics VALUES (30, 'CASH_OUT', 4047, 912604519.81, 225501.49, 134, 246915721.96, 3.3111, 17965, -77.47, 9002.71, 2237364);
INSERT INTO public.deploy_fact_daily_metrics VALUES (31, 'CASH_OUT', 136, 212547715.95, 1562850.85, 136, 212547715.95, 100.0000, 4047, -96.64, 7497.00, 2237500);
INSERT INTO public.deploy_fact_daily_metrics VALUES (1, 'DEBIT', 4470, 27922583.50, 6246.66, 0, 0.00, 0.0000, NULL, NULL, 4470.00, 4470);
INSERT INTO public.deploy_fact_daily_metrics VALUES (2, 'DEBIT', 2510, 12664019.28, 5045.43, 0, 0.00, 0.0000, 4470, -43.85, 3490.00, 6980);
INSERT INTO public.deploy_fact_daily_metrics VALUES (3, 'DEBIT', 24, 31606.65, 1316.94, 0, 0.00, 0.0000, 2510, -99.04, 2334.67, 7004);
INSERT INTO public.deploy_fact_daily_metrics VALUES (4, 'DEBIT', 340, 2031923.85, 5976.25, 0, 0.00, 0.0000, 24, 1316.67, 1836.00, 7344);
INSERT INTO public.deploy_fact_daily_metrics VALUES (5, 'DEBIT', 194, 933730.72, 4813.04, 0, 0.00, 0.0000, 340, -42.94, 1507.60, 7538);
INSERT INTO public.deploy_fact_daily_metrics VALUES (6, 'DEBIT', 2663, 12385027.87, 4650.78, 0, 0.00, 0.0000, 194, 1272.68, 1700.17, 10201);
INSERT INTO public.deploy_fact_daily_metrics VALUES (7, 'DEBIT', 2539, 13936392.76, 5488.93, 0, 0.00, 0.0000, 2663, -4.66, 1820.00, 12740);
INSERT INTO public.deploy_fact_daily_metrics VALUES (8, 'DEBIT', 2895, 14967433.62, 5170.10, 0, 0.00, 0.0000, 2539, 14.02, 1595.00, 15635);
INSERT INTO public.deploy_fact_daily_metrics VALUES (9, 'DEBIT', 2128, 7610290.79, 3576.26, 0, 0.00, 0.0000, 2895, -26.49, 1540.43, 17763);
INSERT INTO public.deploy_fact_daily_metrics VALUES (10, 'DEBIT', 2413, 11245611.27, 4660.43, 0, 0.00, 0.0000, 2128, 13.39, 1881.71, 20176);
INSERT INTO public.deploy_fact_daily_metrics VALUES (11, 'DEBIT', 2049, 21471848.55, 10479.18, 0, 0.00, 0.0000, 2413, -15.08, 2125.86, 22225);
INSERT INTO public.deploy_fact_daily_metrics VALUES (12, 'DEBIT', 2194, 13188206.32, 6011.03, 0, 0.00, 0.0000, 2049, 7.08, 2411.57, 24419);
INSERT INTO public.deploy_fact_daily_metrics VALUES (13, 'DEBIT', 2626, 15772032.32, 6006.11, 0, 0.00, 0.0000, 2194, 19.69, 2406.29, 27045);
INSERT INTO public.deploy_fact_daily_metrics VALUES (14, 'DEBIT', 2881, 16096044.89, 5586.96, 0, 0.00, 0.0000, 2626, 9.71, 2455.14, 29926);
INSERT INTO public.deploy_fact_daily_metrics VALUES (15, 'DEBIT', 3271, 14946773.34, 4569.48, 0, 0.00, 0.0000, 2881, 13.54, 2508.86, 33197);
INSERT INTO public.deploy_fact_daily_metrics VALUES (16, 'DEBIT', 2414, 13304412.25, 5511.36, 0, 0.00, 0.0000, 3271, -26.20, 2549.71, 35611);
INSERT INTO public.deploy_fact_daily_metrics VALUES (17, 'DEBIT', 2878, 16362774.36, 5685.47, 0, 0.00, 0.0000, 2414, 19.22, 2616.14, 38489);
INSERT INTO public.deploy_fact_daily_metrics VALUES (18, 'DEBIT', 186, 372801.08, 2004.31, 0, 0.00, 0.0000, 2878, -93.54, 2350.00, 38675);
INSERT INTO public.deploy_fact_daily_metrics VALUES (19, 'DEBIT', 66, 172813.11, 2618.38, 0, 0.00, 0.0000, 186, -64.52, 2046.00, 38741);
INSERT INTO public.deploy_fact_daily_metrics VALUES (20, 'DEBIT', 138, 288523.99, 2090.75, 0, 0.00, 0.0000, 66, 109.09, 1690.57, 38879);
INSERT INTO public.deploy_fact_daily_metrics VALUES (21, 'DEBIT', 112, 2938376.10, 26235.50, 0, 0.00, 0.0000, 138, -18.84, 1295.00, 38991);
INSERT INTO public.deploy_fact_daily_metrics VALUES (22, 'DEBIT', 522, 1721708.18, 3298.29, 0, 0.00, 0.0000, 112, 366.07, 902.29, 39513);
INSERT INTO public.deploy_fact_daily_metrics VALUES (23, 'DEBIT', 409, 1723238.21, 4213.30, 0, 0.00, 0.0000, 522, -21.65, 615.86, 39922);
INSERT INTO public.deploy_fact_daily_metrics VALUES (24, 'DEBIT', 196, 1084193.85, 5531.60, 0, 0.00, 0.0000, 409, -52.08, 232.71, 40118);
INSERT INTO public.deploy_fact_daily_metrics VALUES (25, 'DEBIT', 491, 1286473.70, 2620.11, 0, 0.00, 0.0000, 196, 150.51, 276.29, 40609);
INSERT INTO public.deploy_fact_daily_metrics VALUES (26, 'DEBIT', 110, 338979.90, 3081.64, 0, 0.00, 0.0000, 491, -77.60, 282.57, 40719);
INSERT INTO public.deploy_fact_daily_metrics VALUES (27, 'DEBIT', 30, 38197.02, 1273.23, 0, 0.00, 0.0000, 110, -72.73, 267.14, 40749);
INSERT INTO public.deploy_fact_daily_metrics VALUES (28, 'DEBIT', 96, 289546.37, 3016.11, 0, 0.00, 0.0000, 30, 220.00, 264.86, 40845);
INSERT INTO public.deploy_fact_daily_metrics VALUES (29, 'DEBIT', 462, 1563235.83, 3383.63, 0, 0.00, 0.0000, 96, 381.25, 256.29, 41307);
INSERT INTO public.deploy_fact_daily_metrics VALUES (30, 'DEBIT', 125, 510421.60, 4083.37, 0, 0.00, 0.0000, 462, -72.94, 215.71, 41432);
INSERT INTO public.deploy_fact_daily_metrics VALUES (1, 'PAYMENT', 194676, 2192430026.02, 11261.94, 0, 0.00, 0.0000, NULL, NULL, 194676.00, 194676);
INSERT INTO public.deploy_fact_daily_metrics VALUES (2, 'PAYMENT', 150147, 1661093173.18, 11063.11, 0, 0.00, 0.0000, 194676, -22.87, 172411.50, 344823);
INSERT INTO public.deploy_fact_daily_metrics VALUES (3, 'PAYMENT', 480, 3127637.43, 6515.91, 0, 0.00, 0.0000, 150147, -99.68, 115101.00, 345303);
INSERT INTO public.deploy_fact_daily_metrics VALUES (4, 'PAYMENT', 14286, 126117840.07, 8828.07, 0, 0.00, 0.0000, 480, 2876.25, 89897.25, 359589);
INSERT INTO public.deploy_fact_daily_metrics VALUES (5, 'PAYMENT', 5470, 49816138.16, 9107.16, 0, 0.00, 0.0000, 14286, -61.71, 73011.80, 365059);
INSERT INTO public.deploy_fact_daily_metrics VALUES (6, 'PAYMENT', 142460, 2021474975.80, 14189.77, 0, 0.00, 0.0000, 5470, 2504.39, 84586.50, 507519);
INSERT INTO public.deploy_fact_daily_metrics VALUES (7, 'PAYMENT', 138250, 1621642881.27, 11729.79, 0, 0.00, 0.0000, 142460, -2.96, 92252.71, 645769);
INSERT INTO public.deploy_fact_daily_metrics VALUES (8, 'PAYMENT', 149776, 1631345214.32, 10891.90, 0, 0.00, 0.0000, 138250, 8.34, 85838.43, 795545);
INSERT INTO public.deploy_fact_daily_metrics VALUES (9, 'PAYMENT', 144781, 1438059365.15, 9932.65, 0, 0.00, 0.0000, 149776, -3.33, 85071.86, 940326);
INSERT INTO public.deploy_fact_daily_metrics VALUES (10, 'PAYMENT', 132895, 1921698781.24, 14460.28, 0, 0.00, 0.0000, 144781, -8.21, 103988.29, 1073221);
INSERT INTO public.deploy_fact_daily_metrics VALUES (11, 'PAYMENT', 142592, 1656399391.69, 11616.36, 0, 0.00, 0.0000, 132895, 7.30, 122317.71, 1215813);
INSERT INTO public.deploy_fact_daily_metrics VALUES (12, 'PAYMENT', 123788, 1407104595.32, 11367.05, 0, 0.00, 0.0000, 142592, -13.19, 139220.29, 1339601);
INSERT INTO public.deploy_fact_daily_metrics VALUES (13, 'PAYMENT', 141460, 2501188710.69, 17681.24, 0, 0.00, 0.0000, 123788, 14.28, 139077.43, 1481061);
INSERT INTO public.deploy_fact_daily_metrics VALUES (14, 'PAYMENT', 135173, 2251686120.07, 16657.81, 0, 0.00, 0.0000, 141460, -4.44, 138637.86, 1616234);
INSERT INTO public.deploy_fact_daily_metrics VALUES (15, 'PAYMENT', 134424, 1971935186.73, 14669.52, 0, 0.00, 0.0000, 135173, -0.55, 136444.71, 1750658);
INSERT INTO public.deploy_fact_daily_metrics VALUES (16, 'PAYMENT', 127445, 1724076856.06, 13528.01, 0, 0.00, 0.0000, 134424, -5.19, 133968.14, 1878103);
INSERT INTO public.deploy_fact_daily_metrics VALUES (17, 'PAYMENT', 141614, 2298056690.98, 16227.61, 0, 0.00, 0.0000, 127445, 11.12, 135213.71, 2019717);
INSERT INTO public.deploy_fact_daily_metrics VALUES (18, 'PAYMENT', 7680, 101076198.74, 13160.96, 0, 0.00, 0.0000, 141614, -94.58, 115940.57, 2027397);
INSERT INTO public.deploy_fact_daily_metrics VALUES (19, 'PAYMENT', 4302, 46224507.75, 10744.89, 0, 0.00, 0.0000, 7680, -43.98, 98871.14, 2031699);
INSERT INTO public.deploy_fact_daily_metrics VALUES (20, 'PAYMENT', 7081, 81603483.98, 11524.29, 0, 0.00, 0.0000, 4302, 64.60, 79674.14, 2038780);
INSERT INTO public.deploy_fact_daily_metrics VALUES (21, 'PAYMENT', 8739, 119200369.07, 13640.05, 0, 0.00, 0.0000, 7081, 23.41, 61612.14, 2047519);
INSERT INTO public.deploy_fact_daily_metrics VALUES (22, 'PAYMENT', 19381, 283788030.54, 14642.59, 0, 0.00, 0.0000, 8739, 121.78, 45177.43, 2066900);
INSERT INTO public.deploy_fact_daily_metrics VALUES (23, 'PAYMENT', 18261, 240197705.53, 13153.59, 0, 0.00, 0.0000, 19381, -5.78, 29579.71, 2085161);
INSERT INTO public.deploy_fact_daily_metrics VALUES (24, 'PAYMENT', 11322, 121904195.90, 10767.02, 0, 0.00, 0.0000, 18261, -38.00, 10966.57, 2096483);
INSERT INTO public.deploy_fact_daily_metrics VALUES (25, 'PAYMENT', 19871, 212364772.03, 10687.17, 0, 0.00, 0.0000, 11322, 75.51, 12708.14, 2116354);
INSERT INTO public.deploy_fact_daily_metrics VALUES (26, 'PAYMENT', 5028, 51560574.25, 10254.69, 0, 0.00, 0.0000, 19871, -74.70, 12811.86, 2121382);
INSERT INTO public.deploy_fact_daily_metrics VALUES (27, 'PAYMENT', 2733, 35865484.78, 13123.12, 0, 0.00, 0.0000, 5028, -45.64, 12190.71, 2124115);
INSERT INTO public.deploy_fact_daily_metrics VALUES (28, 'PAYMENT', 5265, 49402738.16, 9383.24, 0, 0.00, 0.0000, 2733, 92.65, 11694.43, 2129380);
INSERT INTO public.deploy_fact_daily_metrics VALUES (29, 'PAYMENT', 18433, 225535105.32, 12235.40, 0, 0.00, 0.0000, 5265, 250.10, 11559.00, 2147813);
INSERT INTO public.deploy_fact_daily_metrics VALUES (30, 'PAYMENT', 3682, 47394388.14, 12871.91, 0, 0.00, 0.0000, 18433, -80.02, 9476.29, 2151495);
INSERT INTO public.deploy_fact_daily_metrics VALUES (1, 'TRANSFER', 46686, 31178878559.60, 667842.15, 130, 106111543.46, 0.2785, NULL, NULL, 46686.00, 46686);
INSERT INTO public.deploy_fact_daily_metrics VALUES (2, 'TRANSFER', 38269, 22574782086.19, 589897.36, 153, 189697472.44, 0.3998, 46686, -18.03, 42477.50, 84955);
INSERT INTO public.deploy_fact_daily_metrics VALUES (3, 'TRANSFER', 189, 210011250.02, 1111170.64, 155, 197254430.30, 82.0106, 38269, -99.51, 28381.33, 85144);
INSERT INTO public.deploy_fact_daily_metrics VALUES (4, 'TRANSFER', 2514, 1651877310.36, 657071.32, 131, 219123408.01, 5.2108, 189, 1230.16, 21914.50, 87658);
INSERT INTO public.deploy_fact_daily_metrics VALUES (5, 'TRANSFER', 906, 610592604.87, 673943.27, 126, 122490289.06, 13.9073, 2514, -63.96, 17712.80, 88564);
INSERT INTO public.deploy_fact_daily_metrics VALUES (6, 'TRANSFER', 36314, 24033728825.41, 661830.94, 114, 183616791.20, 0.3139, 906, 3908.17, 20813.00, 124878);
INSERT INTO public.deploy_fact_daily_metrics VALUES (7, 'TRANSFER', 34721, 22074097461.50, 635756.39, 136, 200895064.40, 0.3917, 36314, -4.39, 22799.86, 159599);
INSERT INTO public.deploy_fact_daily_metrics VALUES (8, 'TRANSFER', 37674, 23768050464.85, 630887.36, 138, 175715688.95, 0.3663, 34721, 8.50, 21512.43, 197273);
INSERT INTO public.deploy_fact_daily_metrics VALUES (9, 'TRANSFER', 33995, 18469103069.75, 543288.81, 127, 194616814.00, 0.3736, 37674, -9.77, 20901.86, 231268);
INSERT INTO public.deploy_fact_daily_metrics VALUES (10, 'TRANSFER', 32717, 23525827932.73, 719070.45, 140, 186462857.27, 0.4279, 33995, -3.76, 25548.71, 263985);
INSERT INTO public.deploy_fact_daily_metrics VALUES (11, 'TRANSFER', 34088, 19144798796.23, 561628.69, 131, 210899943.41, 0.3843, 32717, 4.19, 30059.29, 298073);
INSERT INTO public.deploy_fact_daily_metrics VALUES (12, 'TRANSFER', 27836, 27118394432.71, 974220.23, 149, 214259884.40, 0.5353, 34088, -18.34, 33906.43, 325909);
INSERT INTO public.deploy_fact_daily_metrics VALUES (13, 'TRANSFER', 36773, 91840093137.63, 2497487.10, 121, 212075245.21, 0.3290, 27836, 32.11, 33972.00, 362682);
INSERT INTO public.deploy_fact_daily_metrics VALUES (14, 'TRANSFER', 33898, 57625423333.21, 1699965.29, 123, 136935916.96, 0.3629, 36773, -7.82, 33854.43, 396580);
INSERT INTO public.deploy_fact_daily_metrics VALUES (15, 'TRANSFER', 33776, 35882860058.84, 1062377.43, 125, 194995405.36, 0.3701, 33898, -0.36, 33297.57, 430356);
INSERT INTO public.deploy_fact_daily_metrics VALUES (16, 'TRANSFER', 31556, 29249666860.59, 926913.01, 126, 167799567.40, 0.3993, 33776, -6.57, 32949.14, 461912);
INSERT INTO public.deploy_fact_daily_metrics VALUES (17, 'TRANSFER', 35618, 29536703239.48, 829263.38, 160, 320910321.62, 0.4492, 31556, 12.87, 33363.57, 497530);
INSERT INTO public.deploy_fact_daily_metrics VALUES (18, 'TRANSFER', 1867, 1507038056.80, 807197.67, 134, 282125524.87, 7.1773, 35618, -94.76, 28760.57, 499397);
INSERT INTO public.deploy_fact_daily_metrics VALUES (19, 'TRANSFER', 993, 781852933.67, 787364.49, 128, 230364091.94, 12.8902, 1867, -46.81, 24925.86, 500390);
INSERT INTO public.deploy_fact_daily_metrics VALUES (20, 'TRANSFER', 1951, 1577265705.48, 808439.62, 118, 138341664.35, 6.0482, 993, 96.48, 19951.29, 502341);
INSERT INTO public.deploy_fact_daily_metrics VALUES (21, 'TRANSFER', 2541, 2324646363.74, 914854.92, 136, 194611309.31, 5.3522, 1951, 30.24, 15471.71, 504882);
INSERT INTO public.deploy_fact_daily_metrics VALUES (22, 'TRANSFER', 4797, 4326018141.68, 901817.42, 128, 204409321.07, 2.6683, 2541, 88.78, 11331.86, 509679);
INSERT INTO public.deploy_fact_daily_metrics VALUES (23, 'TRANSFER', 4658, 3258732064.77, 699598.98, 108, 109694686.00, 2.3186, 4797, -2.90, 7489.29, 514337);
INSERT INTO public.deploy_fact_daily_metrics VALUES (24, 'TRANSFER', 3098, 1844461256.54, 595371.61, 140, 169033769.42, 4.5190, 4658, -33.49, 2843.57, 517435);
INSERT INTO public.deploy_fact_daily_metrics VALUES (25, 'TRANSFER', 5349, 3615779625.53, 675973.01, 120, 154279679.89, 2.2434, 3098, 72.66, 3341.00, 522784);
INSERT INTO public.deploy_fact_daily_metrics VALUES (26, 'TRANSFER', 1244, 841565164.23, 676499.33, 136, 199239829.43, 10.9325, 5349, -76.74, 3376.86, 524028);
INSERT INTO public.deploy_fact_daily_metrics VALUES (27, 'TRANSFER', 888, 669837463.99, 754321.47, 140, 223997416.60, 15.7658, 1244, -28.62, 3225.00, 524916);
INSERT INTO public.deploy_fact_daily_metrics VALUES (28, 'TRANSFER', 1495, 1404506496.02, 939469.23, 124, 190656533.91, 8.2943, 888, 68.36, 3075.57, 526411);
INSERT INTO public.deploy_fact_daily_metrics VALUES (29, 'TRANSFER', 5348, 3765881812.46, 704166.38, 130, 250973387.33, 2.4308, 1495, 257.73, 3154.29, 531759);
INSERT INTO public.deploy_fact_daily_metrics VALUES (30, 'TRANSFER', 1014, 643974235.40, 635083.07, 134, 250086807.55, 13.2150, 5348, -81.04, 2633.71, 532773);
INSERT INTO public.deploy_fact_daily_metrics VALUES (31, 'TRANSFER', 136, 235538518.89, 1731900.87, 136, 235538518.89, 100.0000, 1014, -86.59, 2210.57, 532909);


--
-- Data for Name: deploy_fraud_by_type; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.deploy_fraud_by_type VALUES ('CASH_OUT', 1985384, 4099);
INSERT INTO public.deploy_fraud_by_type VALUES ('TRANSFER', 511462, 3954);


--
-- Data for Name: deploy_risk_summary; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.deploy_risk_summary VALUES (1, 6409, 6218, 97.02);
INSERT INTO public.deploy_risk_summary VALUES (2, 2467610, 1835, 0.07);
INSERT INTO public.deploy_risk_summary VALUES (3, 22827, 0, 0.00);


--
-- Data for Name: deploy_suspicious; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C1715283297', 'C439737079', 92445516.64, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C2127282686', 'C753026640', 73823490.36, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C2044643633', 'C84111522', 71172480.42, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C1425667947', 'C167875008', 69886731.30, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C1584456031', 'C1472140329', 69337316.27, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C811810230', 'C1757599079', 67500761.29, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C420748282', 'C1073241084', 66761272.21, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C1139847449', 'C65111466', 64234448.19, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C300140823', 'C514940761', 63847992.58, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C372535854', 'C1871605747', 63294839.63, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C1539737626', 'C1774146551', 62785416.91, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C915403211', 'C744189981', 61733761.65, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C453740720', 'C1676302617', 60965275.64, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C68968235', 'C167875008', 60642003.00, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C31593462', 'C172409641', 60154456.05, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C1273768806', 'C294810721', 59579503.33, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C24299338', 'C1320946922', 58944752.64, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C1423766399', 'C1406193485', 58318373.20, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C208486812', 'C1087955840', 57787800.93, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C1139460122', 'C310383504', 57436619.46, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C1621759239', 'C266573701', 57229615.71, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C256698564', 'C439737079', 56951424.46, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C1845534968', 'C1192919794', 56808983.21, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C2043083172', 'C1066295040', 56654831.14, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C50811564', 'C510521991', 56254995.44, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C1293276010', 'C1687607266', 55607114.09, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C1680772125', 'C2105830770', 55129569.83, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C173148914', 'C20253152', 54561579.68, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C1440084225', 'C439737079', 53957543.97, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C140591783', 'C268913927', 53920358.88, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C1960608501', 'C1511142890', 53851053.08, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C1937630471', 'C294810721', 53735587.33, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C1408116717', 'C926435744', 53670510.99, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C1163102205', 'C734202350', 53653616.57, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C2120801782', 'C172409641', 53612432.52, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C1223028177', 'C707403537', 52042803.47, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C2144929087', 'C1044689969', 51990860.85, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C6333741', 'C2106908510', 51729490.03, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C515250662', 'C935324559', 51683728.91, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C2094706712', 'C1791724427', 51496952.25, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C893113779', 'C936857833', 51391814.47, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C962484785', 'C325534370', 51324118.36, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C1483754162', 'C531111973', 51141938.17, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C988219650', 'C1847853864', 51103331.91, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C1942982352', 'C1413422241', 50723281.59, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C1043576460', 'C1184860705', 50556773.92, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C1092148827', 'C936857833', 50284915.57, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C1260344462', 'C907499666', 49866234.71, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C821543017', 'C98452956', 49580968.52, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C1585432592', 'C1687607266', 49522819.36, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C253892701', 'C1083888305', 49507088.19, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C1753244211', 'C41481250', 49500156.98, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C1301835320', 'C327052591', 49380263.91, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C1983948243', 'C60911281', 49316443.77, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C831435828', 'C1676302617', 49203983.59, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C152536544', 'C1406499569', 49142625.14, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C1774402263', 'C1640920899', 48932770.05, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C155474398', 'C510521991', 48724097.09, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C689906292', 'C161550987', 48672213.16, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C1275690114', 'C707403537', 48464778.69, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C1692196711', 'C663979939', 48391417.10, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C865139105', 'C648140651', 48035924.46, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C123249678', 'C955958643', 47980266.33, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C1084869780', 'C20253152', 47952846.94, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C1049185843', 'C828577595', 47825067.55, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C1852022720', 'C1720463306', 47579634.65, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C298757438', 'C2021595908', 47542583.98, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C539714486', 'C190688669', 47504216.38, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C744401564', 'C907499666', 47463371.62, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C503937936', 'C310383504', 47288336.09, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C1622870367', 'C744189981', 47107862.46, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C1944832737', 'C44870833', 47009785.39, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C1335021824', 'C2105830770', 46874551.96, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C184899407', 'C2130064541', 46837065.98, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C866532689', 'C471948321', 46751398.17, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C661511930', 'C268913927', 46714620.46, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C69207480', 'C532980658', 46714461.77, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C891821473', 'C1287433675', 46698160.51, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C256397271', 'C439737079', 46211920.92, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C1177251642', 'C1858456879', 45940069.72, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C812016560', 'C1251838000', 45753877.29, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C604492107', 'C1497180663', 45744606.08, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C240100497', 'C1789550256', 45372634.63, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C646554535', 'C243325822', 45083035.09, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C748391366', 'C1847853864', 44964012.64, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C543086845', 'C20253152', 44757554.09, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C1475793899', 'C112931567', 44528076.23, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C1861117738', 'C907499666', 44125125.22, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C1697395210', 'C1799942601', 43886668.10, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C626152842', 'C1087955840', 43746302.68, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C1701964888', 'C310383504', 43638406.64, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C812415403', 'C471948321', 43458810.55, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C1943142760', 'C1220292898', 43143717.48, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C114509514', 'C1636786811', 42684988.59, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C1269201229', 'C863811613', 42242482.73, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C1835360608', 'C8271807', 42183808.56, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C55478598', 'C60911281', 41988600.77, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (12, 'TRANSFER', 'C1237771660', 'C947086614', 41963708.15, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C1011191693', 'C880754345', 41818052.20, 3, 0);
INSERT INTO public.deploy_suspicious VALUES (13, 'TRANSFER', 'C1327783656', 'C735186749', 41781250.27, 3, 0);


--
-- Data for Name: deploy_tier_summary; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.deploy_tier_summary VALUES (1, 1730875, 1094025.90, 3.07, 12150, 1893622078239.52);
INSERT INTO public.deploy_tier_summary VALUES (2, 1730875, 161523.16, 1.03, 2061, 279576400456.19);
INSERT INTO public.deploy_tier_summary VALUES (3, 1730875, 43865.23, 1.01, 1688, 75925224535.52);
INSERT INTO public.deploy_tier_summary VALUES (4, 1730874, 6683.80, 1.00, 483, 11568815149.94);


--
-- Data for Name: deploy_top_customers; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.deploy_top_customers VALUES ('C439737079', 18, 0, 357440831.44, 357440831.44, 1, 0);
INSERT INTO public.deploy_top_customers VALUES ('C707403537', 17, 0, 299374418.42, 299374418.42, 1, 0);
INSERT INTO public.deploy_top_customers VALUES ('C167875008', 28, 0, 274736432.80, 274736432.80, 1, 0);
INSERT INTO public.deploy_top_customers VALUES ('C20253152', 20, 0, 270116188.69, 270116188.69, 1, 0);
INSERT INTO public.deploy_top_customers VALUES ('C172409641', 57, 0, 255310174.25, 255310174.25, 1, 0);
INSERT INTO public.deploy_top_customers VALUES ('C268913927', 35, 0, 253484588.10, 253484588.10, 1, 0);
INSERT INTO public.deploy_top_customers VALUES ('C936857833', 46, 0, 227780012.02, 227780012.02, 1, 0);
INSERT INTO public.deploy_top_customers VALUES ('C65111466', 22, 0, 227443845.85, 227443845.85, 1, 1);
INSERT INTO public.deploy_top_customers VALUES ('C744189981', 26, 0, 225173861.73, 225173861.73, 1, 0);
INSERT INTO public.deploy_top_customers VALUES ('C1406193485', 46, 0, 224778961.83, 224778961.83, 1, 0);
INSERT INTO public.deploy_top_customers VALUES ('C310383504', 17, 0, 223503958.90, 223503958.90, 1, 0);
INSERT INTO public.deploy_top_customers VALUES ('C1774146551', 53, 0, 213473723.06, 213473723.06, 1, 0);
INSERT INTO public.deploy_top_customers VALUES ('C325534370', 30, 0, 208595978.94, 208595978.94, 1, 0);
INSERT INTO public.deploy_top_customers VALUES ('C1320946922', 16, 0, 206026465.36, 206026465.36, 1, 0);
INSERT INTO public.deploy_top_customers VALUES ('C2120613885', 11, 0, 200164990.78, 200164990.78, 1, 0);
INSERT INTO public.deploy_top_customers VALUES ('C60911281', 11, 0, 178642347.28, 178642347.28, 1, 0);
INSERT INTO public.deploy_top_customers VALUES ('C1789550256', 99, 0, 177885264.60, 177885264.60, 1, 0);
INSERT INTO public.deploy_top_customers VALUES ('C1087955840', 21, 0, 177282997.54, 177282997.54, 1, 0);
INSERT INTO public.deploy_top_customers VALUES ('C907499666', 14, 0, 176571590.45, 176571590.45, 1, 0);
INSERT INTO public.deploy_top_customers VALUES ('C294810721', 17, 0, 175972189.41, 175972189.41, 1, 0);


--
-- PostgreSQL database dump complete
--

\unrestrict enAtxbETxpAFScve1KAaZyCYOePUyBTIedUefHMajH7oFEgHfok5azNaF6zRYNw

