--
-- PostgreSQL database dump
--

\restrict MV8FezRWc6EOItxGK7xAxB4sN08e0il8H4zW1pScMiykP83mcNGc8H8faFo16g5

-- Dumped from database version 17.7 (178558d)
-- Dumped by pg_dump version 18.0

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

--
-- Name: pg_session_jwt; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_session_jwt WITH SCHEMA public;


--
-- Name: EXTENSION pg_session_jwt; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_session_jwt IS 'pg_session_jwt: manage authentication sessions using JWTs';


--
-- Name: neon_auth; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA neon_auth;


--
-- Name: pgrst; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA pgrst;


--
-- Name: pre_config(); Type: FUNCTION; Schema: pgrst; Owner: -
--

CREATE FUNCTION pgrst.pre_config() RETURNS void
    LANGUAGE sql
    AS $$
  SELECT
      set_config('pgrst.db_schemas', 'public', true)
    , set_config('pgrst.db_aggregates_enabled', 'true', true)
    , set_config('pgrst.db_anon_role', 'anonymous', true)
    , set_config('pgrst.jwt_role_claim_key', '.role', true)
$$;


--
-- Name: auto_calculate_total(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.auto_calculate_total() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE 
    prod_price NUMERIC;
BEGIN
    SELECT price INTO prod_price
    FROM product
    WHERE product_id = NEW.product_id;

    IF prod_price IS NULL THEN
        RAISE EXCEPTION 'Invalid product_id %', NEW.product_id;
    END IF;

    NEW.total_cost := NEW.quantity * prod_price;
    RETURN NEW;
END;
$$;


--
-- Name: check_positive_quantity(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_positive_quantity() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.quantity <= 0 THEN
        RAISE EXCEPTION 'Quantity must be greater than zero';
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: validate_hours(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validate_hours() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.hours_worked < 0 THEN
        RAISE EXCEPTION 'Hours worked must be non-negative';
    END IF;
    RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: users_sync; Type: TABLE; Schema: neon_auth; Owner: -
--

CREATE TABLE neon_auth.users_sync (
    raw_json jsonb NOT NULL,
    id text GENERATED ALWAYS AS ((raw_json ->> 'id'::text)) STORED NOT NULL,
    name text GENERATED ALWAYS AS ((raw_json ->> 'display_name'::text)) STORED,
    email text GENERATED ALWAYS AS ((raw_json ->> 'primary_email'::text)) STORED,
    created_at timestamp with time zone GENERATED ALWAYS AS (to_timestamp((trunc((((raw_json ->> 'signed_up_at_millis'::text))::bigint)::double precision) / (1000)::double precision))) STORED,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone
);


--
-- Name: customer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer (
    customer_id integer NOT NULL,
    name text,
    phone_number text,
    email text
);


--
-- Name: customer_customer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.customer_customer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: employee_employee_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.employee_employee_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: employee; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.employee (
    employee_id integer DEFAULT nextval('public.employee_employee_id_seq'::regclass) NOT NULL,
    name text,
    title text,
    salary numeric(10,2),
    date_of_birth date,
    address text,
    phone_number text
);


--
-- Name: employee_noindex; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.employee_noindex (
    employee_id integer,
    name text,
    title text,
    salary numeric(10,2),
    date_of_birth date,
    address text,
    phone_number text
);


--
-- Name: inventory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventory (
    product_id integer NOT NULL,
    quantity_in_stock integer
);


--
-- Name: inventory_product_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.inventory ALTER COLUMN product_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.inventory_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: product_product_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_product_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_info; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_info (
    product_id integer DEFAULT nextval('public.product_product_id_seq'::regclass) NOT NULL,
    name text,
    description text,
    nutrition_facts text,
    price numeric(10,2)
);


--
-- Name: product_info_noindex; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_info_noindex (
    product_id integer,
    name text,
    description text,
    nutrition_facts text,
    price numeric(10,2)
);


--
-- Name: products_product_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.products_product_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sales_sale_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sales_sale_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sales; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sales (
    sale_id integer DEFAULT nextval('public.sales_sale_id_seq'::regclass) NOT NULL,
    sale_date date,
    customer_id integer,
    sale_time time without time zone
);


--
-- Name: sales_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sales_item (
    sale_id integer NOT NULL,
    product_id integer NOT NULL
);


--
-- Name: sales_item_noindex; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sales_item_noindex (
    sale_id integer,
    product_id integer
);


--
-- Name: sales_item_sale_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.sales_item ALTER COLUMN sale_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sales_item_sale_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: schedule_schedule_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.schedule_schedule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: schedule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schedule (
    schedule_id integer DEFAULT nextval('public.schedule_schedule_id_seq'::regclass) NOT NULL,
    date date,
    employee_id integer,
    shift_start time without time zone,
    shift_end time without time zone
);


--
-- Name: schedule_noindex; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schedule_noindex (
    schedule_id integer,
    date date,
    employee_id integer,
    shift_start time without time zone,
    shift_end time without time zone
);


--
-- Name: worked_on_work_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.worked_on_work_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: worked_on; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.worked_on (
    sale_id integer DEFAULT nextval('public.worked_on_work_id_seq'::regclass) NOT NULL,
    employee_id integer
);


--
-- Name: users_sync users_sync_pkey; Type: CONSTRAINT; Schema: neon_auth; Owner: -
--

ALTER TABLE ONLY neon_auth.users_sync
    ADD CONSTRAINT users_sync_pkey PRIMARY KEY (id);


--
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (customer_id);


--
-- Name: employee employee_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (employee_id);


--
-- Name: inventory inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT inventory_pkey PRIMARY KEY (product_id);


--
-- Name: product_info product_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_info
    ADD CONSTRAINT product_pkey PRIMARY KEY (product_id);


--
-- Name: sales sales_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_pkey PRIMARY KEY (sale_id);


--
-- Name: schedule schedule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedule
    ADD CONSTRAINT schedule_pkey PRIMARY KEY (schedule_id);


--
-- Name: users_sync_deleted_at_idx; Type: INDEX; Schema: neon_auth; Owner: -
--

CREATE INDEX users_sync_deleted_at_idx ON neon_auth.users_sync USING btree (deleted_at);


--
-- Name: sales calculate_total_cost; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER calculate_total_cost BEFORE INSERT ON public.sales FOR EACH ROW EXECUTE FUNCTION public.auto_calculate_total();

ALTER TABLE public.sales DISABLE TRIGGER calculate_total_cost;


--
-- Name: sales sales_positive_quantity; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER sales_positive_quantity BEFORE INSERT OR UPDATE ON public.sales FOR EACH ROW EXECUTE FUNCTION public.check_positive_quantity();

ALTER TABLE public.sales DISABLE TRIGGER sales_positive_quantity;


--
-- Name: worked_on worked_on_hours_check; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER worked_on_hours_check BEFORE INSERT OR UPDATE ON public.worked_on FOR EACH ROW EXECUTE FUNCTION public.validate_hours();


--
-- Name: worked_on employee_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worked_on
    ADD CONSTRAINT employee_id FOREIGN KEY (employee_id) REFERENCES public.employee(employee_id);


--
-- Name: inventory product_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT product_id FOREIGN KEY (product_id) REFERENCES public.product_info(product_id);


--
-- Name: sales_item product_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_item
    ADD CONSTRAINT product_id FOREIGN KEY (product_id) REFERENCES public.product_info(product_id);


--
-- Name: sales_item sale_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_item
    ADD CONSTRAINT sale_id FOREIGN KEY (sale_id) REFERENCES public.sales(sale_id);


--
-- Name: worked_on sale_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worked_on
    ADD CONSTRAINT sale_id FOREIGN KEY (sale_id) REFERENCES public.sales(sale_id);


--
-- Name: sales sales_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customer(customer_id);


--
-- Name: schedule schedule_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schedule
    ADD CONSTRAINT schedule_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employee(employee_id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: -
--

GRANT USAGE ON SCHEMA public TO authenticated;


--
-- Name: SCHEMA pgrst; Type: ACL; Schema: -; Owner: -
--

GRANT USAGE ON SCHEMA pgrst TO authenticator;


--
-- Name: FUNCTION pre_config(); Type: ACL; Schema: pgrst; Owner: -
--

GRANT ALL ON FUNCTION pgrst.pre_config() TO authenticator;


--
-- Name: FUNCTION auto_calculate_total(); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.auto_calculate_total() TO authenticated;


--
-- Name: FUNCTION check_positive_quantity(); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.check_positive_quantity() TO authenticated;


--
-- Name: FUNCTION validate_hours(); Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON FUNCTION public.validate_hours() TO authenticated;


--
-- Name: TABLE customer; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.customer TO team;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.customer TO authenticated;


--
-- Name: SEQUENCE customer_customer_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.customer_customer_id_seq TO team;
GRANT USAGE ON SEQUENCE public.customer_customer_id_seq TO authenticated;


--
-- Name: SEQUENCE employee_employee_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.employee_employee_id_seq TO team;
GRANT USAGE ON SEQUENCE public.employee_employee_id_seq TO authenticated;


--
-- Name: TABLE employee; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.employee TO team;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.employee TO authenticated;


--
-- Name: TABLE employee_noindex; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.employee_noindex TO team;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.employee_noindex TO authenticated;


--
-- Name: TABLE inventory; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.inventory TO team;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.inventory TO authenticated;


--
-- Name: SEQUENCE inventory_product_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.inventory_product_id_seq TO team;
GRANT USAGE ON SEQUENCE public.inventory_product_id_seq TO authenticated;


--
-- Name: SEQUENCE product_product_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.product_product_id_seq TO team;
GRANT USAGE ON SEQUENCE public.product_product_id_seq TO authenticated;


--
-- Name: TABLE product_info; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.product_info TO team;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.product_info TO authenticated;


--
-- Name: TABLE product_info_noindex; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.product_info_noindex TO team;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.product_info_noindex TO authenticated;


--
-- Name: SEQUENCE products_product_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.products_product_id_seq TO team;
GRANT USAGE ON SEQUENCE public.products_product_id_seq TO authenticated;


--
-- Name: SEQUENCE sales_sale_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.sales_sale_id_seq TO team;
GRANT USAGE ON SEQUENCE public.sales_sale_id_seq TO authenticated;


--
-- Name: TABLE sales; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.sales TO team;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.sales TO authenticated;


--
-- Name: TABLE sales_item; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.sales_item TO team;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.sales_item TO authenticated;


--
-- Name: TABLE sales_item_noindex; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.sales_item_noindex TO team;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.sales_item_noindex TO authenticated;


--
-- Name: SEQUENCE sales_item_sale_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.sales_item_sale_id_seq TO team;
GRANT USAGE ON SEQUENCE public.sales_item_sale_id_seq TO authenticated;


--
-- Name: SEQUENCE schedule_schedule_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.schedule_schedule_id_seq TO team;
GRANT USAGE ON SEQUENCE public.schedule_schedule_id_seq TO authenticated;


--
-- Name: TABLE schedule; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.schedule TO team;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.schedule TO authenticated;


--
-- Name: TABLE schedule_noindex; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.schedule_noindex TO team;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.schedule_noindex TO authenticated;


--
-- Name: SEQUENCE worked_on_work_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.worked_on_work_id_seq TO team;
GRANT USAGE ON SEQUENCE public.worked_on_work_id_seq TO authenticated;


--
-- Name: TABLE worked_on; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.worked_on TO team;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.worked_on TO authenticated;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE cloud_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO neon_superuser WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE neondb_owner IN SCHEMA public GRANT ALL ON SEQUENCES TO team;
ALTER DEFAULT PRIVILEGES FOR ROLE neondb_owner IN SCHEMA public GRANT USAGE ON SEQUENCES TO authenticated;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE neondb_owner IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE cloud_admin IN SCHEMA public GRANT ALL ON TABLES TO neon_superuser WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE neondb_owner IN SCHEMA public GRANT ALL ON TABLES TO team;
ALTER DEFAULT PRIVILEGES FOR ROLE neondb_owner IN SCHEMA public GRANT SELECT,INSERT,DELETE,UPDATE ON TABLES TO authenticated;


--
-- PostgreSQL database dump complete
--

\unrestrict MV8FezRWc6EOItxGK7xAxB4sN08e0il8H4zW1pScMiykP83mcNGc8H8faFo16g5

