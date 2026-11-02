# Project context for Claude Code

## Who and why
- Owner: Geetha Sagar Bonthu (GitHub: geethasagarb). Data analyst with 4+ years, job-hunting across the US in retail & CPG, market research and manufacturing. Based in Cincinnati.
- This repo is portfolio project **R1**: real household grocery data, used to show SQL, statistics and Power BI on a business question. It is the real-data version of the Kroger cases in github.com/geethasagarb/claude-skills (examples/kroger, parts 16, 17, 21).

## Business questions
1. Weekly growth decomposition: active households × trips per household × spend per trip.
2. Household segments (RFM plus "split shoppers": high fresh share, low center-store share). Which grow or shrink?
3. Campaign lift: targeted vs. similar non-targeted households, before vs. during (difference-in-differences), with a pre-trend check, bootstrap CIs and a placebo test.
4. Coupon funnel: coupons issued vs. redeemed, by department and segment.
5. Recommendation memo: where the next promotion dollar should go.

## Data facts (checked)
- 84.51° The Complete Journey (CC0). 2,469 households, 1,469,307 transaction rows, 155,848 baskets, 457 stores.
- Timestamps in the file are UTC; source weeks follow U.S. Eastern time. In Eastern time the data is exactly calendar 2017. Week 1 is one day (Jan 1); weeks 2–53 are full weeks (Dec 25 has no purchases). Analysis uses weeks 2–53 = 13 four-week periods.
- 27 campaigns (types A, B, C). Demographics for 801 households. 17 product IDs (about $173) are missing from products; kept as UNKNOWN.
- `retail_disc`, `coupon_disc` are positive amounts. Raw CSVs live in data/raw/ (gitignored). DuckDB file is data/cj.duckdb (gitignored).

## Stack and layout
- dbt-duckdb project in transform/ (staging tables, then marts: dim_date, dim_product, dim_household, dim_campaign, fct_sales_line, fct_basket, then reporting: rpt_*). Tests in transform/models/schema.yml and transform/tests/. profiles.yml lives in transform/ (path ../data/cj.duckdb).
- python/build.py runs `dbt build` and exports the rpt_* tables to outputs/. Python deps in requirements.txt (use a .venv). R only for data download (data/get_data.R).
- outputs/: small aggregated CSVs for Power BI (committed). powerbi/: .pbix + screenshots. docs/memo.md: findings.

## Plan and status
- [x] PR 1: scaffold + data pipeline (Mac)
- [x] PR 2: dbt project, star schema + weekly / 4-week growth decomposition (Mac). First finding: P13 vs P1 sales ex fuel +10.0 log pts = households +2.9, trips per household −2.0, spend per trip +9.1
- [ ] PR 3: segments + campaign lift + coupon funnel, export outputs/ (Mac)
- [ ] PR 4: Power BI dashboard, 3 pages (Growth drivers, Segments, Campaigns & coupons) from outputs/*.csv (Windows)
- [ ] PR 5: memo + README findings, in the owner's own voice; "My take" written from the owner's answers, never invented

## Working rules
- One commit per change set, one PR per topic. The owner reviews and merges before the next topic. Check `gh pr list --state all` first; the owner sometimes opens or merges PRs themselves.
- Commit as "Geetha Sagar Bonthu" <bgeethasagar@gmail.com>. No Co-Authored-By or "Generated with Claude Code" lines in commits or PRs.
- Plain, first-person writing. Little bold, no emojis, no arrows as sentence glue. Label estimates and simulated numbers.
- Never commit raw data. Only aggregated outputs.
