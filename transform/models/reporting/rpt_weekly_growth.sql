-- Weekly sales (ex fuel) split into: active households x trips per household x spend per trip.
-- A trip counts if the basket had at least one non-fuel item. Full weeks only (2-53).
with trips as (
    select b.*
    from {{ ref('fct_basket') }} b
    where b.sales_ex_fuel > 0
      and b.week between {{ var('first_full_week') }} and {{ var('last_week') }}
)

select
    week,
    min(basket_date)                                        as week_start,
    count(distinct household_id)                            as active_households,
    count(*)                                                as trips,
    sum(sales_ex_fuel)                                      as sales_ex_fuel,
    count(*) * 1.0 / count(distinct household_id)           as trips_per_household,
    sum(sales_ex_fuel) / count(*)                           as spend_per_trip,
    sum(units) * 1.0 / count(*)                             as units_per_trip,
    sum(fresh_sales) / sum(sales_ex_fuel)                   as fresh_share,
    sum(private_label_sales) / sum(sales_ex_fuel)           as private_label_share,
    sum(retail_disc + coupon_disc) / sum(sales_ex_fuel + retail_disc + coupon_disc) as discount_rate
from trips
group by week
order by week
