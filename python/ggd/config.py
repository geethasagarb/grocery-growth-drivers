"""Shared settings: where files live, where the data comes from, and what row counts to expect."""
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RAW_DIR = ROOT / "data" / "raw"
SNOWFLAKE_SQL_DIR = ROOT / "snowflake"

# The completejourney R package keeps the small tables as .rda files and the two
# large ones as .rds files in its GitHub repo. pyreadr reads both formats.
SOURCE_BASE_URL = "https://github.com/bradleyboehmke/completejourney/raw/master/data"

SOURCE_FILES = {
    "campaign_descriptions": "campaign_descriptions.rda",
    "campaigns": "campaigns.rda",
    "coupon_redemptions": "coupon_redemptions.rda",
    "coupons": "coupons.rda",
    "demographics": "demographics.rda",
    "products": "products.rda",
    "promotions": "promotions.rds",
    "transactions": "transactions.rds",
}

# Row counts checked against the published data (see CLAUDE.md, "Data facts").
# The loader compares every RAW table with these after COPY INTO.
EXPECTED_ROWS = {
    "campaign_descriptions": 27,
    "campaigns": 6_589,
    "coupon_redemptions": 2_102,
    "coupons": 116_204,
    "demographics": 801,
    "products": 92_331,
    "promotions": 20_940_529,
    "transactions": 1_469_307,
}

# Snowflake object names. Override with environment variables if the account
# already uses these names for something else.
SNOWFLAKE_CONNECTION = os.environ.get("GGD_SNOWFLAKE_CONNECTION", "grocery")
SNOWFLAKE_DATABASE = os.environ.get("GGD_DATABASE", "GROCERY_GROWTH")
SNOWFLAKE_WAREHOUSE = os.environ.get("GGD_WAREHOUSE", "GGD_WH")
SNOWFLAKE_ROLE = os.environ.get("GGD_ROLE", "GGD_ROLE")
RAW_SCHEMA = "RAW"
RAW_STAGE = "RAW_FILES"
