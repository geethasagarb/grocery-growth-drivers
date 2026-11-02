-- Each calendar day should belong to exactly one source week.
select transaction_date
from {{ ref('stg_transactions') }}
group by 1
having count(distinct week) > 1
