select
    d.campaign_id,
    d.campaign_type,
    d.start_date,
    d.end_date,
    d.end_date - d.start_date + 1                                        as duration_days,
    (select count(*) from {{ ref('stg_campaigns') }} c where c.campaign_id = d.campaign_id)  as households_targeted,
    (select count(*) from {{ ref('stg_coupons') }} k where k.campaign_id = d.campaign_id)    as coupon_product_links
from {{ ref('stg_campaign_descriptions') }} d
