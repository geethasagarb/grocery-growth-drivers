"""Build everything from data/raw/: run the SQL files in order, then print data checks.

Usage (from repo root): python python/build.py
"""
from pathlib import Path

import duckdb

ROOT = Path(__file__).resolve().parents[1]
DB = ROOT / "data" / "cj.duckdb"
SQL_DIR = ROOT / "sql"

CHECKS = {
    "transactions": "SELECT COUNT(*) FROM stg_transactions",
    "households": "SELECT COUNT(DISTINCT household_id) FROM stg_transactions",
    "baskets": "SELECT COUNT(DISTINCT basket_id) FROM stg_transactions",
    "stores": "SELECT COUNT(DISTINCT store_id) FROM stg_transactions",
    "first_purchase": "SELECT MIN(transaction_ts) FROM stg_transactions",
    "last_purchase": "SELECT MAX(transaction_ts) FROM stg_transactions",
    "households_with_demographics": "SELECT COUNT(*) FROM stg_demographics",
    "campaigns": "SELECT COUNT(*) FROM stg_campaign_descriptions",
    "negative_retail_disc_rows": "SELECT COUNT(*) FROM stg_transactions WHERE retail_disc < 0",
}
EXPECTED = {"transactions": 1_469_307, "households": 2_469}


def main() -> None:
    con = duckdb.connect(str(DB))
    con.execute(f"SET file_search_path = '{ROOT}'")
    for sql_file in sorted(SQL_DIR.glob("*.sql")):
        print(f"running {sql_file.name}")
        con.execute(sql_file.read_text())

    print("\nData checks")
    for name, query in CHECKS.items():
        value = con.execute(query).fetchone()[0]
        flag = ""
        if name in EXPECTED:
            flag = "ok" if value == EXPECTED[name] else f"EXPECTED {EXPECTED[name]}"
        print(f"  {name:<30} {value!s:<22} {flag}")
    con.close()


if __name__ == "__main__":
    main()
