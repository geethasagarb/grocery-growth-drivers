-- One-time account setup for the grocery growth project.
-- Run as ACCOUNTADMIN (the default role on a trial account). The loader runs this
-- with `python python/pipeline.py setup`; it can also be pasted into a worksheet.
-- {{database}}, {{warehouse}}, {{role}} and {{user}} are filled in by the loader.

-- A dedicated role keeps the project's objects separate from the trial's defaults
-- and is what dbt and Power BI will connect with later.
create role if not exists {{role}};
grant role {{role}} to user "{{user}}";
grant role {{role}} to role sysadmin;

-- XSMALL with a 60-second auto-suspend is plenty for 1.5M rows and protects trial credits.
create warehouse if not exists {{warehouse}}
    warehouse_size = 'XSMALL'
    auto_suspend = 60
    auto_resume = true
    initially_suspended = true;
grant usage, operate on warehouse {{warehouse}} to role {{role}};

-- One database, one schema per layer. RAW holds the files as loaded;
-- dbt builds STAGING, MARTS and REPORTING on top.
create database if not exists {{database}};
grant ownership on database {{database}} to role {{role}} copy current grants;

use role {{role}};
use database {{database}};
create schema if not exists RAW;
create schema if not exists STAGING;
create schema if not exists MARTS;
create schema if not exists REPORTING;
