-- Households x trips per household x spend per trip must equal weekly sales (ex fuel).
select week
from {{ ref('rpt_weekly_growth') }}
where abs(active_households * trips_per_household * spend_per_trip - sales_ex_fuel) > 0.01
