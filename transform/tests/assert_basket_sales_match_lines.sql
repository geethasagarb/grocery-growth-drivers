-- No sales lost between line level and basket level.
select 1
from (select sum(sales_value) s from {{ ref('fct_sales_line') }}) l,
     (select sum(sales) s from {{ ref('fct_basket') }}) b
where abs(l.s - b.s) > 0.01
