-- One row per calendar day in the data. Week numbers come from the source data;
-- 4-week retail periods start at the first full week (week 2).
with days as (
    select transaction_date as date_day, min(week) as week
    from {{ ref('stg_transactions') }}
    group by 1
)

select
    date_day,
    week,
    week >= {{ var('first_full_week') }}                                   as is_full_week,
    case when week >= {{ var('first_full_week') }}
         then cast(floor((week - {{ var('first_full_week') }}) / 4) + 1 as integer) end as period_4wk,
    extract(month from date_day)                                           as month_num,
    strftime(date_day, '%Y-%m')                                            as year_month,
    dayname(date_day)                                                      as day_name
from days
