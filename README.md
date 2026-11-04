# Grocery growth drivers

Where does a grocer's sales growth come from, and did its marketing campaigns actually cause any of it?

I'm answering that with real household-level grocery data from 84.51° (Kroger's data science company):
2,469 households, a full year of purchases (2017), coupons, campaigns and demographics.

**Status:** data pipeline and dbt models in place, with the first result below. Segments, campaign lift, the Power BI dashboard and the findings memo are in progress.

**First result:** across 2017, sales without fuel grew about 10% from the first 4-week period to the last. Almost all of it came from bigger baskets (+9.1 points). Slightly more households were active (+2.9), and they shopped a little less often (−2.0). These are log-point contributions that add up exactly.

## Questions
1. Is weekly sales change driven by more households, more trips per household, or bigger baskets?
2. Which household segments are growing or shrinking?
3. Did the 27 campaigns cause extra spending? (difference-in-differences against similar households that weren't targeted)
4. Who actually gets value from coupons?
5. Where should the next promotion dollar go?

## How it's built
- **dbt + DuckDB** (`transform/`): staging, then a star schema (dim_date, dim_product, dim_household, dim_campaign, fct_sales_line, fct_basket), then reporting models. 43 tests, including checks that households × trips × spend adds back to sales exactly.
- **Python** (`python/`): extracts the source files, loads them into Snowflake RAW with row-count checks, runs dbt and exports reporting tables to `outputs/` for Power BI.
- **Snowflake** (`snowflake/`): setup and RAW table scripts. I'm moving the dbt models from DuckDB to Snowflake next.
- **Power BI** (`powerbi/`): dashboard, in progress.

## How to run
```
python -m venv .venv && .venv/bin/pip install -r requirements.txt
.venv/bin/python python/pipeline.py extract   # downloads the data to data/raw/ (not committed)
.venv/bin/python python/build.py              # dbt build on DuckDB (models + tests), then exports to outputs/
.venv/bin/python python/pipeline.py setup     # Snowflake: one-time objects (see snowflake/README.md)
.venv/bin/python python/pipeline.py load      # Snowflake: PUT + COPY INTO RAW, row-count checks
```

Data: [84.51° The Complete Journey](https://cran.r-project.org/web/packages/completejourney/index.html), CC0. Independent project; not affiliated with Kroger or 84.51°.
