-- Load raw CSVs (data/raw/) into DuckDB staging tables.
-- ID columns are read as text so they always join (auto-detection can read them as decimals).
CREATE OR REPLACE TABLE stg_transactions AS
SELECT
    household_id, store_id, basket_id, product_id,
    quantity, sales_value, retail_disc, coupon_disc, coupon_match_disc, week,
    CAST(transaction_timestamp AS TIMESTAMP) AS transaction_ts
FROM read_csv('data/raw/transactions.csv', header = true, auto_detect = true,
    types = {'household_id': 'VARCHAR', 'store_id': 'VARCHAR', 'basket_id': 'VARCHAR', 'product_id': 'VARCHAR'});

CREATE OR REPLACE TABLE stg_products AS
SELECT * FROM read_csv('data/raw/products.csv', header = true, auto_detect = true,
    types = {'product_id': 'VARCHAR', 'manufacturer_id': 'VARCHAR'});

CREATE OR REPLACE TABLE stg_demographics AS
SELECT * FROM read_csv('data/raw/demographics.csv', header = true, auto_detect = true,
    types = {'household_id': 'VARCHAR', 'household_size': 'VARCHAR', 'kids_count': 'VARCHAR'});

CREATE OR REPLACE TABLE stg_campaigns AS
SELECT * FROM read_csv('data/raw/campaigns.csv', header = true, auto_detect = true,
    types = {'campaign_id': 'VARCHAR', 'household_id': 'VARCHAR'});

CREATE OR REPLACE TABLE stg_campaign_descriptions AS
SELECT * FROM read_csv('data/raw/campaign_descriptions.csv', header = true, auto_detect = true,
    types = {'campaign_id': 'VARCHAR', 'start_date': 'DATE', 'end_date': 'DATE'});

CREATE OR REPLACE TABLE stg_coupons AS
SELECT * FROM read_csv('data/raw/coupons.csv', header = true, auto_detect = true,
    types = {'coupon_upc': 'VARCHAR', 'product_id': 'VARCHAR', 'campaign_id': 'VARCHAR'});

CREATE OR REPLACE TABLE stg_coupon_redemptions AS
SELECT * FROM read_csv('data/raw/coupon_redemptions.csv', header = true, auto_detect = true,
    types = {'household_id': 'VARCHAR', 'coupon_upc': 'VARCHAR', 'campaign_id': 'VARCHAR', 'redemption_date': 'DATE'});
