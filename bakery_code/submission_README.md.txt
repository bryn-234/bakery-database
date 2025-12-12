Bakery Database System — ECE 401 Final Project
Authors: Bryn Neal, Joseph Corella, Miguel Sena
Semester: Fall 2025

------------------------------------------------------------
Project Overview
------------------------------------------------------------
This project implements a relational database system modeling the 
operations of a local bakery. The system tracks:

- Sales transactions
- Products and pricing
- Customer purchasing behavior
- Employee work hours and scheduling
- Inventory quantities (partial/synthetic)

The project also includes performance evaluation through 
indexing benchmarks, normalization, and query optimization, 
comparing SQLite vs. PostgreSQL (Neon).

This code folder contains all SQL files needed to reconstruct, 
query, and evaluate the database.

------------------------------------------------------------
Folder Contents
------------------------------------------------------------

1. create_tables.sql
   Contains the full schema definition for the PostgreSQL database.
   Includes all bakery tables:
   sales, sales_item, product_info, customer, employee,
   schedule, inventory.
   Exported using pg_dump --schema-only.

2. analysis_queries.sql
   Contains all analytical and feature queries used in the project.
   Includes queries for:
   - Top-selling products
   - Customer purchasing patterns
   - Daily and weekly revenue
   - Basket value per sale
   - Product pairs analysis
   - Items never purchased
   - Inventory visibility
   - Time-of-day sales patterns
   - 7-day revenue moving average

   These correspond to the "Features & Queries" section of the report.

3. index_test.sql
   Contains indexing benchmark experiments used in the Error Analysis.
   Includes:
   - Non-indexed table versions (*_noindex)
   - EXPLAIN ANALYZE tests for:
       * Employee total hours query
       * Frequent product-pair query
   - Indexed vs. non-indexed comparisons

   Instructions for how to recreate *_noindex tables are included 
   as comments at the top of the file.

------------------------------------------------------------
How to Reproduce the Database
------------------------------------------------------------

1. Create the schema:
   \i create_tables.sql;

2. Load all CSV data or insert rows manually.

3. Run all feature queries:
   \i analysis_queries.sql;

4. Create *_noindex tables for benchmarking:
   CREATE TABLE schedule_noindex AS TABLE schedule;
   CREATE TABLE employee_noindex AS TABLE employee;
   CREATE TABLE sales_item_noindex AS TABLE sales_item;
   CREATE TABLE product_info_noindex AS TABLE product_info;

5. Run indexing benchmarks:
   \i index_test.sql;

------------------------------------------------------------
Dataset Source
------------------------------------------------------------
Sales transaction data comes from Kaggle:
https://www.kaggle.com/datasets/elarabi/bakery-transactions

Additional customer, employee, product, and schedule data 
was synthetically generated for project requirements.

------------------------------------------------------------
Notes
------------------------------------------------------------
- Dataset files are not included (per project instructions).
- The PostgreSQL database was built and tested on Neon.
- Query performance results may vary depending on server load 
  or dataset variations.

------------------------------------------------------------
Submission Packaging
------------------------------------------------------------
This folder should be zipped as:

code.zip

containing:
- create_tables.sql
- analysis_queries.sql
- index_test.sql
- README.txt
