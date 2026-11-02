select campaign_id, campaign_type, start_date, end_date
from read_csv('{{ var("raw_path") }}/campaign_descriptions.csv', header = true, auto_detect = true,
    types = {'campaign_id': 'VARCHAR', 'start_date': 'DATE', 'end_date': 'DATE'})
