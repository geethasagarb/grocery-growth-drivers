# Data

**Source:** [84.51° The Complete Journey](https://cran.r-project.org/web/packages/completejourney/index.html) via the R package `completejourney` (files hosted at [bradleyboehmke/completejourney](https://github.com/bradleyboehmke/completejourney/tree/master/data)). License: CC0.

`Rscript data/get_data.R` writes these CSVs to `data/raw/` (gitignored, about 680 MB):

| Table | Rows | What it is |
|---|---|---|
| transactions | 1,469,307 | Every item each household bought in 2017: store, basket, product, quantity, sales and discounts |
| promotions | 20,940,529 | Weekly in-store display and mailer placement by product and store |
| products | 92,331 | Department, category, type, brand (national or private) and size |
| demographics | 801 | Age, income, household size and composition, for some households |
| campaigns | 6,589 | Which households received which campaign |
| campaign_descriptions | 27 | Campaign type (A, B, C) and start and end dates |
| coupons | 116,204 | Which products each campaign's coupons covered |
| coupon_redemptions | 2,102 | Coupons redeemed, by household and date |

**Checked on load:** 2,469 households, 155,848 baskets, 457 stores. Timestamps in the file are UTC; converted to U.S. Eastern time (which the source weeks follow), purchases cover calendar 2017 exactly. Week 1 is a single day (Sunday, Jan 1); weeks 2–53 run Monday to Sunday (no purchases on Dec 25, so week 53 is Dec 26–31). `retail_disc` and `coupon_disc` are stored as positive amounts.

**Known gap:** 4,836 transaction lines (17 product IDs, about $173 of $4.6M in sales) have no match in `products`. They're kept and labeled "Unknown" department.
