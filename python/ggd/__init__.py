"""Grocery growth drivers: extract, load and check the 84.51° Complete Journey data.

Modules:
    config          paths, source files, expected row counts
    extract         download the source files and write CSVs to data/raw/
    snowflake_conn  open a Snowflake connection from the local CLI config
    load            create objects, stage files, COPY INTO RAW, check row counts
"""
