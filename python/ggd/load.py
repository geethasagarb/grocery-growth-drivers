"""Create the Snowflake objects, load data/raw/*.csv into RAW, and check row counts.

Steps:
    setup()  one-time: role, warehouse, database and schemas (snowflake/setup.sql)
    load()   every run: RAW tables and stage, PUT files, COPY INTO, row-count checks
"""
from ggd import config
from ggd.snowflake_conn import connect, run_script


def render_sql(filename: str, values: dict[str, str]) -> str:
    """Read a SQL file from snowflake/ and fill in its {{placeholders}}."""
    sql = (config.SNOWFLAKE_SQL_DIR / filename).read_text()
    for key, value in values.items():
        sql = sql.replace("{{" + key + "}}", value)
    return sql


def setup() -> None:
    """Create the role, warehouse, database and schemas. Safe to run more than once."""
    connection = connect(role="ACCOUNTADMIN")
    try:
        # The role is granted to whoever is running setup, so later runs can use it.
        user = connection.cursor().execute("select current_user()").fetchone()[0]

        values = {
            "database": config.SNOWFLAKE_DATABASE,
            "warehouse": config.SNOWFLAKE_WAREHOUSE,
            "role": config.SNOWFLAKE_ROLE,
            "user": user,
        }
        run_script(connection, render_sql("setup.sql", values))
        print(f"Setup done: {config.SNOWFLAKE_DATABASE} owned by {config.SNOWFLAKE_ROLE}, "
              f"warehouse {config.SNOWFLAKE_WAREHOUSE} (XSMALL, auto-suspend 60s)")
    finally:
        connection.close()


def use_project_context(cursor) -> None:
    """Point the session at the project's warehouse, database and RAW schema."""
    cursor.execute(f"use warehouse {config.SNOWFLAKE_WAREHOUSE}")
    cursor.execute(f"use database {config.SNOWFLAKE_DATABASE}")
    cursor.execute(f"use schema {config.RAW_SCHEMA}")


def check_raw_files_exist() -> None:
    """Stop early with a clear message if the extract step hasn't been run."""
    missing = []
    for table in config.SOURCE_FILES:
        if not (config.RAW_DIR / f"{table}.csv").exists():
            missing.append(table)

    if missing:
        raise SystemExit(f"Missing CSVs in data/raw/: {', '.join(missing)}. "
                         "Run `python python/pipeline.py extract` first.")


def put_file(cursor, table: str) -> None:
    """Upload one CSV to the internal stage. PUT gzips it on the way up."""
    local_path = (config.RAW_DIR / f"{table}.csv").as_posix()
    cursor.execute(
        f"put 'file://{local_path}' @{config.RAW_STAGE}/{table}/ "
        "auto_compress = true overwrite = true parallel = 8"
    )


def copy_into(cursor, table: str) -> int:
    """COPY the staged file into its RAW table and return the rows loaded.

    on_error = abort_statement means a single bad row fails the load loudly,
    instead of silently skipping data.
    """
    cursor.execute(
        f"copy into {table.upper()} from @{config.RAW_STAGE}/{table}/ "
        "file_format = (format_name = 'CSV_FILE') "
        "on_error = abort_statement purge = true"
    )

    # COPY returns one row per file with a rows_loaded column. When there is nothing
    # to load it returns a single status row without that column, so look it up by name.
    column_names = [column[0].lower() for column in cursor.description]
    if "rows_loaded" not in column_names:
        return 0

    position = column_names.index("rows_loaded")
    loaded = 0
    for result_row in cursor.fetchall():
        loaded += result_row[position]
    return loaded


def count_rows(cursor, table: str) -> int:
    """Count rows in a RAW table."""
    return cursor.execute(f"select count(*) from {table.upper()}").fetchone()[0]


def load() -> bool:
    """Load every table and compare row counts with the expected values. Returns True if all match."""
    check_raw_files_exist()

    connection = connect(role=config.SNOWFLAKE_ROLE)
    all_ok = True
    try:
        cursor = connection.cursor()
        use_project_context(cursor)

        # Recreate RAW tables, the file format and the stage, so a reload starts clean.
        run_script(connection, (config.SNOWFLAKE_SQL_DIR / "raw_tables.sql").read_text())

        print(f"  {'table':<22} {'loaded':>12} {'in table':>12}  check")
        for table in config.SOURCE_FILES:
            put_file(cursor, table)
            loaded = copy_into(cursor, table)
            in_table = count_rows(cursor, table)

            expected = config.EXPECTED_ROWS[table]
            matches = in_table == expected
            all_ok = all_ok and matches

            status = "ok" if matches else f"EXPECTED {expected:,}"
            print(f"  {table:<22} {loaded:>12,} {in_table:>12,}  {status}")
    finally:
        connection.close()

    return all_ok
