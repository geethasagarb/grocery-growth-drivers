"""Download the Complete Journey source files and write each table to data/raw/ as CSV.

This replaces data/get_data.R. The CSV layout matches what the R script wrote,
so the existing DuckDB dbt models keep working until the Snowflake path is done.
"""
import tempfile
from pathlib import Path

import pandas as pd
import pyreadr
import requests

from ggd import config


def download(url: str, destination: Path) -> None:
    """Stream a file to disk so the 25 MB promotions file never sits in memory twice."""
    with requests.get(url, stream=True, timeout=120) as response:
        response.raise_for_status()
        with open(destination, "wb") as handle:
            for chunk in response.iter_content(chunk_size=1 << 20):
                handle.write(chunk)


def read_r_file(path: Path) -> pd.DataFrame:
    """Read an .rda or .rds file. Each file in this repo holds exactly one data frame."""
    result = pyreadr.read_r(str(path))
    frames = list(result.values())
    if len(frames) != 1:
        raise ValueError(f"{path.name}: expected one data frame, found {len(frames)}")
    return frames[0]


def format_timestamps(frame: pd.DataFrame) -> pd.DataFrame:
    """Write timestamps as UTC 'YYYY-MM-DD HH:MM:SS', the same text the R script produced.

    The staging model converts UTC to U.S. Eastern time, so the file must stay in UTC.
    """
    for column in frame.columns:
        if pd.api.types.is_datetime64_any_dtype(frame[column]):
            values = frame[column]
            if values.dt.tz is None:
                values = values.dt.tz_localize("UTC")
            else:
                values = values.dt.tz_convert("UTC")
            frame[column] = values.dt.strftime("%Y-%m-%d %H:%M:%S")
    return frame


def restore_whole_numbers(frame: pd.DataFrame) -> pd.DataFrame:
    """Turn float columns that only hold whole numbers back into integers.

    R stores counts like quantity and week as doubles. pyreadr reads them as floats,
    which would write "1.0" instead of "1" and change the types the loaders infer.
    """
    for column in frame.columns:
        values = frame[column]
        if not pd.api.types.is_float_dtype(values):
            continue

        non_missing = values.dropna()
        if (non_missing == non_missing.round()).all():
            frame[column] = values.astype("Int64")
    return frame


def extract_table(table: str, filename: str, work_dir: Path) -> int:
    """Download one source file, convert it to CSV in data/raw/, and return its row count."""
    local_file = work_dir / filename
    download(f"{config.SOURCE_BASE_URL}/{filename}", local_file)

    frame = read_r_file(local_file)
    frame = format_timestamps(frame)
    frame = restore_whole_numbers(frame)

    output = config.RAW_DIR / f"{table}.csv"
    frame.to_csv(output, index=False)
    return len(frame)


def extract_all() -> dict[str, int]:
    """Extract every table and print its row count next to the expected count."""
    config.RAW_DIR.mkdir(parents=True, exist_ok=True)
    counts = {}

    with tempfile.TemporaryDirectory() as tmp:
        work_dir = Path(tmp)
        for table, filename in config.SOURCE_FILES.items():
            rows = extract_table(table, filename, work_dir)
            counts[table] = rows

            expected = config.EXPECTED_ROWS[table]
            status = "ok" if rows == expected else f"EXPECTED {expected:,}"
            print(f"  {table:<22} {rows:>12,}  {status}")

    return counts
