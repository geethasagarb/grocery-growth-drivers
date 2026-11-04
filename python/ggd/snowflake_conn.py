"""Open a Snowflake connection from the local Snowflake CLI config.

Credentials never live in this repo. The connector reads ~/.snowflake/connections.toml
and picks the named connection (default "grocery", override with GGD_SNOWFLAKE_CONNECTION).
"""
import snowflake.connector

from ggd import config


def connect(role: str | None = None) -> snowflake.connector.SnowflakeConnection:
    """Connect with the named connection, optionally switching to a given role.

    Setup runs as ACCOUNTADMIN; everything after that runs as the project role.
    """
    connection = snowflake.connector.connect(connection_name=config.SNOWFLAKE_CONNECTION)
    if role:
        connection.cursor().execute(f"use role {role}")
    return connection


def run_script(connection: snowflake.connector.SnowflakeConnection, sql: str) -> None:
    """Run a multi-statement SQL script, one statement at a time.

    execute_string splits on semicolons and handles comments, so the .sql files
    in snowflake/ can be written the same way you would paste them into a worksheet.
    """
    connection.execute_string(sql, remove_comments=True)
