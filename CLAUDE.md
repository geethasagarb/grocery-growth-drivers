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

## Direction (decided 2026-11-02): Snowflake end to end
The repo should read as an industry-standard warehouse project:
source files, then Snowflake RAW, then dbt transformations in Snowflake, then Power BI connected to Snowflake, plus Snowflake Cortex answering the business questions.
- Source: the completejourney files published by Brad Boehmke on GitHub (what data/get_data.R uses today). Extraction moves to Python.
- Load: Python loader creates the database, schemas (RAW, then dbt schemas for staging, marts, reporting), warehouse and role; PUTs files to an internal stage; COPY INTO RAW tables; checks row counts against the data facts above.
- Transform: same dbt project, switched to dbt-snowflake.
- AI: Cortex Analyst semantic model over the marts, and a Cortex Agent on top. Keep a committed set of test questions with expected answers so agent accuracy is checked, not assumed.
- Power BI: Snowflake connector in Import mode, so the .pbix still opens after the trial ends.
- Snowflake only. Fall back to DuckDB only for a piece Snowflake cannot do on the trial (for example Cortex not available in the account's region). Keep the current DuckDB code until the Snowflake path works end to end, then remove it.
- The account is a free trial (about 30 days, about $400 credits). Use an XSMALL warehouse with auto-suspend at 60 seconds. Capture screenshots and sample agent answers while it is live, for the README.
- Credentials never go in the repo. They live in the Snowflake CLI connection config (~/.snowflake/connections.toml) or environment variables; profiles.yml reads them with env_var(). Prefer key-pair auth.

## Stack and layout
- Current (DuckDB, to be replaced): dbt-duckdb project in transform/ (staging tables, then marts: dim_date, dim_product, dim_household, dim_campaign, fct_sales_line, fct_basket, then reporting: rpt_*). Tests in transform/models/schema.yml and transform/tests/. profiles.yml lives in transform/ (path ../data/cj.duckdb).
- python/build.py runs `dbt build` and exports the rpt_* tables to outputs/. Python deps in requirements.txt (use a .venv). R only for data download (data/get_data.R) until extraction moves to Python.
- Target Python layout: python/build.py as a thin entry point, with a package under python/ (config, Snowflake connection, extract, load, export, and analysis/ with segments, campaign_lift, coupon_funnel).
- outputs/: small aggregated CSVs (committed). powerbi/: .pbix + screenshots. docs/memo.md: findings.

## Code style (Python)
- Comments in plain developer language that explain why a step exists, so another analyst can follow. Docstrings on every module and function.
- No cramming logic into one line. Break long chains and dense comprehensions into named steps.
- Modular: small single-purpose functions, shared helpers in their own modules, a thin main() behind `if __name__ == "__main__":`.
- Keep the directory organized to match. When touching an old flat script, refactor it toward this layout in the same topic PR and say so in the PR.

## Plan and status
Steps are named, not numbered by PR, because GitHub PR numbers don't line up with the plan.
- [x] Data pipeline: scaffold, download, DuckDB staging (GitHub #1)
- [x] dbt project, star schema, weekly / 4-week growth decomposition (GitHub #2, which merged into data-pipeline; #3 brought it into main). First finding: P13 vs P1 sales ex fuel +10.0 log pts = households +2.9, trips per household −2.0, spend per trip +9.1
- [ ] Snowflake setup and load: Python extract, stage, COPY INTO RAW, row-count checks
- [ ] dbt on Snowflake: dbt-snowflake target, fix DuckDB-only SQL, all tests pass; then remove the DuckDB path
- [ ] Analysis: segments + coupon funnel as dbt models; campaign lift (diff-in-diff, pre-trend, bootstrap CIs, placebo) in Python reading from Snowflake
- [ ] Cortex: semantic model, Cortex Agent, test question set
- [ ] Power BI dashboard, 3 pages (Growth drivers, Segments, Campaigns & coupons), connected to Snowflake in Import mode (Windows)
- [ ] Memo + README findings, in the owner's own voice; "My take" written from the owner's answers, never invented

## Working rules
- Stacked PRs: if a PR's base is another feature branch, it does not reach main when merged. Base PRs on main, or follow up with a PR into main.
- One commit per change set, one PR per topic. The owner reviews and merges before the next topic. Check `gh pr list --state all` first; the owner sometimes opens or merges PRs themselves.
- Commit as "Geetha Sagar Bonthu" <bgeethasagar@gmail.com>. No Co-Authored-By or "Generated with Claude Code" lines in commits or PRs.
- Plain, first-person writing. Little bold, no emojis, no arrows as sentence glue. Label estimates and simulated numbers.
- Never commit raw data. Only aggregated outputs.
