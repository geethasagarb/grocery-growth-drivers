-- One row per shopping trip (basket), with sales split by department group.
select
    s.basket_id,
    any_value(s.household_id)                                             as household_id,
    any_value(s.store_id)                                                 as store_id,
    min(s.transaction_date)                                               as basket_date,
    min(s.week)                                                           as week,
    count(*)                                                              as lines,
    sum(s.quantity)                                                       as units,
    sum(s.sales_value)                                                    as sales,
    sum(s.sales_value) filter (where p.dept_group <> 'fuel')              as sales_ex_fuel,
    sum(s.sales_value) filter (where p.dept_group = 'fresh')              as fresh_sales,
    sum(s.sales_value) filter (where p.dept_group = 'center_store')       as center_store_sales,
    sum(s.sales_value) filter (where p.dept_group = 'fuel')               as fuel_sales,
    sum(s.sales_value) filter (where p.is_private_label)                  as private_label_sales,
    sum(s.retail_disc)                                                    as retail_disc,
    sum(s.coupon_disc)                                                    as coupon_disc
from {{ ref('fct_sales_line') }} s
join {{ ref('dim_product') }} p using (product_id)
group by s.basket_id
