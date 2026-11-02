-- Which households received which campaign.
select campaign_id, household_id
from read_csv('{{ var("raw_path") }}/campaigns.csv', header = true, auto_detect = true,
    types = {'campaign_id': 'VARCHAR', 'household_id': 'VARCHAR'})
