select
    product_id,
    manufacturer_id,
    department,
    brand,
    product_category,
    product_type,
    package_size
from read_csv('{{ var("raw_path") }}/products.csv', header = true, auto_detect = true,
    types = {'product_id': 'VARCHAR', 'manufacturer_id': 'VARCHAR'})
