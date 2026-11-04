-- RAW layer: one table per source file, typed but otherwise as delivered.
-- IDs are text so they always join (the same choice the DuckDB staging models make).
-- The loader runs this before every load; `create or replace` makes reloads repeatable.

create or replace file format RAW.CSV_FILE
    type = csv
    skip_header = 1
    field_optionally_enclosed_by = '"'
    empty_field_as_null = true
    null_if = ('', 'NA');

create stage if not exists RAW.RAW_FILES
    file_format = RAW.CSV_FILE;

create or replace table RAW.CAMPAIGN_DESCRIPTIONS (
    campaign_id     varchar,
    campaign_type   varchar,
    start_date      date,
    end_date        date
);

create or replace table RAW.CAMPAIGNS (
    campaign_id     varchar,
    household_id    varchar
);

create or replace table RAW.COUPON_REDEMPTIONS (
    household_id    varchar,
    coupon_upc      varchar,
    campaign_id     varchar,
    redemption_date date
);

create or replace table RAW.COUPONS (
    coupon_upc      varchar,
    product_id      varchar,
    campaign_id     varchar
);

create or replace table RAW.DEMOGRAPHICS (
    household_id    varchar,
    age             varchar,
    income          varchar,
    home_ownership  varchar,
    marital_status  varchar,
    household_size  varchar,
    household_comp  varchar,
    kids_count      varchar
);

create or replace table RAW.PRODUCTS (
    product_id        varchar,
    manufacturer_id   varchar,
    department        varchar,
    brand             varchar,
    product_category  varchar,
    product_type      varchar,
    package_size      varchar
);

create or replace table RAW.PROMOTIONS (
    product_id        varchar,
    store_id          varchar,
    display_location  varchar,
    mailer_location   varchar,
    week              integer
);

-- Timestamps stay in UTC here, exactly as in the file. Staging converts to U.S. Eastern.
-- Money columns are float because the source has 28 floating-point leftovers such as
-- 2.220446e-16 (zero in practice). RAW keeps them as delivered; staging rounds to cents.
create or replace table RAW.TRANSACTIONS (
    household_id           varchar,
    store_id               varchar,
    basket_id              varchar,
    product_id             varchar,
    quantity               integer,
    sales_value            float,
    retail_disc            float,
    coupon_disc            float,
    coupon_match_disc      float,
    week                   integer,
    transaction_timestamp  timestamp_ntz
);
