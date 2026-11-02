-- Sales (ex fuel) by 4-week retail period, and how much of each change came from
-- households, trips per household and spend per trip.
-- Uses log changes so the three parts add up exactly to the total change:
--   ln(S1/S0) = ln(H1/H0) + ln(F1/F0) + ln(B1/B0)
with trips as (
    select b.*, d.period_4wk
    from {{ ref('fct_basket') }} b
    join {{ ref('dim_date') }} d on d.date_day = b.basket_date
    where b.sales_ex_fuel > 0
      and d.period_4wk is not null
),

periods as (
    select
        period_4wk,
        min(basket_date)                                  as period_start,
        max(basket_date)                                  as period_end,
        count(distinct household_id)                      as active_households,
        count(*)                                          as trips,
        sum(sales_ex_fuel)                                as sales_ex_fuel
    from trips
    group by 1
),

metrics as (
    select
        *,
        trips * 1.0 / active_households                   as trips_per_household,
        sales_ex_fuel / trips                             as spend_per_trip
    from periods
),

changes as (
    select
        *,
        ln(sales_ex_fuel / lag(sales_ex_fuel) over w)                 as total_log_change,
        ln(active_households * 1.0 / lag(active_households) over w)   as households_effect,
        ln(trips_per_household / lag(trips_per_household) over w)     as frequency_effect,
        ln(spend_per_trip / lag(spend_per_trip) over w)               as basket_effect,
        ln(sales_ex_fuel / first_value(sales_ex_fuel) over w)                 as total_vs_p1,
        ln(active_households * 1.0 / first_value(active_households) over w)   as households_vs_p1,
        ln(trips_per_household / first_value(trips_per_household) over w)     as frequency_vs_p1,
        ln(spend_per_trip / first_value(spend_per_trip) over w)               as basket_vs_p1
    from metrics
    window w as (order by period_4wk)
)

select
    *,
    exp(total_log_change) - 1                             as sales_change_pct
from changes
order by period_4wk
