-- One row per household: demographics (801 of 2,469 have them) plus lifetime activity.
with activity as (
    select
        household_id,
        min(transaction_date)        as first_purchase_date,
        max(transaction_date)        as last_purchase_date,
        count(distinct basket_id)    as baskets,
        sum(sales_value)             as total_sales
    from {{ ref('stg_transactions') }}
    group by 1
),

campaigns as (
    select household_id, count(*) as campaigns_received
    from {{ ref('stg_campaigns') }}
    group by 1
)

select
    a.household_id,
    d.household_id is not null              as has_demographics,
    d.age,
    d.income,
    d.home_ownership,
    d.marital_status,
    d.household_size,
    d.household_comp,
    d.kids_count,
    a.first_purchase_date,
    a.last_purchase_date,
    a.baskets,
    a.total_sales,
    coalesce(c.campaigns_received, 0)       as campaigns_received
from activity a
left join {{ ref('stg_demographics') }} d using (household_id)
left join campaigns c using (household_id)
