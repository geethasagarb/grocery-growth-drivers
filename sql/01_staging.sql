-- Load raw CSVs (data/raw/) into DuckDB staging tables.
CREATE OR REPLACE TABLE stg_transactions AS
SELECT
    CAST(household_id AS VARCHAR)         AS household_id,
    CAST(store_id AS VARCHAR)             AS store_id,
    CAST(basket_id AS VARCHAR)            AS basket_id,
    CAST(product_id AS VARCHAR)           AS product_id,
    quantity,
    sales_value,
    retail_disc,
    coupon_disc,
    coupon_match_disc,
    week,
    CAST(transaction_timestamp AS TIMESTAMP) AS transaction_ts
FROM read_csv_auto('data/raw/transactions.csv');

CREATE OR REPLACE TABLE stg_products           AS SELECT * REPLACE (CAST(product_id AS VARCHAR) AS product_id) FROM read_csv_auto('data/raw/products.csv');
CREATE OR REPLACE TABLE stg_demographics       AS SELECT * REPLACE (CAST(household_id AS VARCHAR) AS household_id) FROM read_csv_auto('data/raw/demographics.csv');
CREATE OR REPLACE TABLE stg_campaigns          AS SELECT * REPLACE (CAST(household_id AS VARCHAR) AS household_id, CAST(campaign_id AS VARCHAR) AS campaign_id) FROM read_csv_auto('data/raw/campaigns.csv');
CREATE OR REPLACE TABLE stg_campaign_descriptions AS SELECT * REPLACE (CAST(campaign_id AS VARCHAR) AS campaign_id) FROM read_csv_auto('data/raw/campaign_descriptions.csv');
CREATE OR REPLACE TABLE stg_coupons            AS SELECT * REPLACE (CAST(product_id AS VARCHAR) AS product_id, CAST(campaign_id AS VARCHAR) AS campaign_id, CAST(coupon_upc AS VARCHAR) AS coupon_upc) FROM read_csv_auto('data/raw/coupons.csv');
CREATE OR REPLACE TABLE stg_coupon_redemptions AS SELECT * REPLACE (CAST(household_id AS VARCHAR) AS household_id, CAST(campaign_id AS VARCHAR) AS campaign_id, CAST(coupon_upc AS VARCHAR) AS coupon_upc) FROM read_csv_auto('data/raw/coupon_redemptions.csv');
