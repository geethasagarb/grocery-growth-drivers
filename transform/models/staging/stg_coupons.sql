select coupon_upc, product_id, campaign_id
from read_csv('{{ var("raw_path") }}/coupons.csv', header = true, auto_detect = true,
    types = {'coupon_upc': 'VARCHAR', 'product_id': 'VARCHAR', 'campaign_id': 'VARCHAR'})
