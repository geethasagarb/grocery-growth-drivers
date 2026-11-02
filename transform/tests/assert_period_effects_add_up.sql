-- The three log effects must add up to the total log change in every period.
select period_4wk
from {{ ref('rpt_period_decomposition') }}
where total_log_change is not null
  and abs(households_effect + frequency_effect + basket_effect - total_log_change) > 1e-9
