-- One row per product. Products that appear in transactions but not in the products file
-- (17 IDs, about $173 of sales) are kept as UNKNOWN so every sale has a product row.
with known as (
    select * from {{ ref('stg_products') }}
),

missing as (
    select distinct t.product_id
    from {{ ref('stg_transactions') }} t
    anti join known k using (product_id)
),

all_products as (
    select product_id, manufacturer_id, department, brand, product_category, product_type, package_size
    from known
    union all
    select product_id, null, 'UNKNOWN', null, null, null, null
    from missing
)

select
    product_id,
    manufacturer_id,
    department,
    brand,
    product_category,
    product_type,
    package_size,
    brand = 'Private' as is_private_label,
    case
        when department in ('PRODUCE', 'MEAT', 'MEAT-PCKGD', 'SEAFOOD', 'SEAFOOD-PCKGD', 'DELI', 'PASTRY', 'SALAD BAR')
            then 'fresh'
        when department in ('GROCERY', 'FROZEN GROCERY', 'NUTRITION')
            then 'center_store'
        when department = 'FUEL'
            then 'fuel'
        when department in ('DRUG GM', 'COSMETICS')
            then 'drug_gm'
        else 'other'
    end as dept_group
from all_products
