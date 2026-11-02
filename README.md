# Grocery growth drivers

Where does a grocer's sales growth come from, and did its marketing campaigns actually cause any of it?

I'm answering that with real household-level grocery data from 84.51° (Kroger's data science company):
2,469 households, a full year of purchases (2017), coupons, campaigns and demographics.

**Status:** data pipeline in place. Analysis, Power BI dashboard and findings memo are in progress.

## Questions
1. Is weekly sales change driven by more households, more trips per household, or bigger baskets?
2. Which household segments are growing or shrinking?
3. Did the 27 campaigns cause extra spending? (difference-in-differences against similar households that weren't targeted)
4. Who actually gets value from coupons?
5. Where should the next promotion dollar go?

## How to run
```
Rscript data/get_data.R        # downloads the data to data/raw/ (not committed)
python python/build.py         # loads DuckDB and builds every table and output
```

Data: [84.51° The Complete Journey](https://cran.r-project.org/web/packages/completejourney/index.html), CC0. Independent project; not affiliated with Kroger or 84.51°.
