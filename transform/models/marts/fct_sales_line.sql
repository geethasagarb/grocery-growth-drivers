-- One row per item line. Grain: basket x product (a product can repeat in a basket).
select
    row_number() over (order by t.transaction_ts, t.basket_id, t.product_id) as sales_line_id,
    t.household_id,
    t.store_id,
    t.basket_id,
    t.product_id,
    t.transaction_date,
    t.transaction_ts,
    t.week,
    t.quantity,
    t.sales_value,
    t.retail_disc,
    t.coupon_disc,
    t.coupon_match_disc
from {{ ref('stg_transactions') }} t
