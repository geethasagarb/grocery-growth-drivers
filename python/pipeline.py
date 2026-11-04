"""Command-line entry point for extracting and loading the data.

Usage (from repo root, with the .venv active):
    python python/pipeline.py extract   # download source files, write data/raw/*.csv
    python python/pipeline.py setup     # one-time Snowflake setup (runs as ACCOUNTADMIN)
    python python/pipeline.py load      # PUT + COPY INTO RAW, then row-count checks
    python python/pipeline.py all       # extract, then load
"""
import argparse
import sys
from pathlib import Path

# Make the ggd package importable when this file is run as a script.
sys.path.insert(0, str(Path(__file__).resolve().parent))

from ggd import extract, load  # noqa: E402


def parse_args() -> argparse.Namespace:
    """Read the one positional argument: which step to run."""
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("step", choices=["extract", "setup", "load", "all"])
    return parser.parse_args()


def run_load() -> None:
    """Load into Snowflake and exit non-zero if any row count is off."""
    print("Loading into Snowflake RAW")
    if not load.load():
        sys.exit("Row counts don't match the expected values; see above.")


def main() -> None:
    """Run the requested step."""
    args = parse_args()

    if args.step in ("extract", "all"):
        print("Extracting source files to data/raw/")
        extract.extract_all()

    if args.step == "setup":
        load.setup()

    if args.step in ("load", "all"):
        run_load()


if __name__ == "__main__":
    main()
