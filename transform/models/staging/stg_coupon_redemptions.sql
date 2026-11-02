select household_id, coupon_upc, campaign_id, redemption_date
from read_csv('{{ var("raw_path") }}/coupon_redemptions.csv', header = true, auto_detect = true,
    types = {'household_id': 'VARCHAR', 'coupon_upc': 'VARCHAR', 'campaign_id': 'VARCHAR', 'redemption_date': 'DATE'})
