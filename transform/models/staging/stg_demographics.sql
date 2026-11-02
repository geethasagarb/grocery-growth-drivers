select *
from read_csv('{{ var("raw_path") }}/demographics.csv', header = true, auto_detect = true,
    types = {'household_id': 'VARCHAR', 'household_size': 'VARCHAR', 'kids_count': 'VARCHAR'})
