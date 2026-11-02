-- One row per item line a household bought. IDs read as text so they always join.
-- Timestamps in the file are UTC. The source weeks follow U.S. Eastern local time
-- (weeks flip Monday 00:00 Eastern), so local time is used for dates.
select
    household_id,
    store_id,
    basket_id,
    product_id,
    quantity,
    sales_value,
    retail_disc,
    coupon_disc,
    coupon_match_disc,
    week,
    cast(transaction_timestamp as timestamp)                                                        as transaction_ts_utc,
    timezone('America/New_York', cast(transaction_timestamp as timestamp) at time zone 'UTC')        as transaction_ts,
    cast(timezone('America/New_York', cast(transaction_timestamp as timestamp) at time zone 'UTC') as date) as transaction_date
from read_csv('{{ var("raw_path") }}/transactions.csv', header = true, auto_detect = true,
    types = {'household_id': 'VARCHAR', 'store_id': 'VARCHAR', 'basket_id': 'VARCHAR', 'product_id': 'VARCHAR'})
