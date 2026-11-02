"""Rebuild everything from data/raw/: run dbt (models + tests), then export reporting tables.

Usage (from repo root, after `Rscript data/get_data.R`):
    python python/build.py
"""
import shutil
import subprocess
import sys
from pathlib import Path

import duckdb

ROOT = Path(__file__).resolve().parents[1]
DB = ROOT / "data" / "cj.duckdb"
TRANSFORM = ROOT / "transform"
OUTPUTS = ROOT / "outputs"

# Reporting tables exported for Power BI and the write-up.
EXPORTS = ["rpt_weekly_growth", "rpt_period_decomposition"]

CHECKS = {
    "transactions": "SELECT COUNT(*) FROM stg_transactions",
    "households": "SELECT COUNT(DISTINCT household_id) FROM stg_transactions",
    "baskets": "SELECT COUNT(*) FROM fct_basket",
    "first_purchase_local": "SELECT MIN(transaction_ts) FROM stg_transactions",
    "last_purchase_local": "SELECT MAX(transaction_ts) FROM stg_transactions",
    "full_weeks_in_report": "SELECT COUNT(*) FROM rpt_weekly_growth",
}
EXPECTED = {"transactions": 1_469_307, "households": 2_469, "baskets": 155_848, "full_weeks_in_report": 52}


def run_dbt() -> None:
    dbt = shutil.which("dbt", path=str(Path(sys.executable).parent)) or "dbt"
    result = subprocess.run([dbt, "build", "--profiles-dir", "."], cwd=TRANSFORM)
    if result.returncode != 0:
        sys.exit("dbt build failed; see the output above")


def main() -> None:
    run_dbt()
    con = duckdb.connect(str(DB), read_only=True)

    print("\nData checks")
    for name, query in CHECKS.items():
        value = con.execute(query).fetchone()[0]
        flag = ""
        if name in EXPECTED:
            flag = "ok" if value == EXPECTED[name] else f"EXPECTED {EXPECTED[name]}"
        print(f"  {name:<24} {value!s:<22} {flag}")

    OUTPUTS.mkdir(exist_ok=True)
    print("\nExports")
    for table in EXPORTS:
        path = OUTPUTS / f"{table}.csv"
        con.execute(f"COPY {table} TO '{path}' (HEADER, DELIMITER ',')")
        print(f"  {path.relative_to(ROOT)}")
    con.close()


if __name__ == "__main__":
    main()
