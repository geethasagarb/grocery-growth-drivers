# Snowflake setup

The pipeline loads the raw files into a Snowflake database, `GROCERY_GROWTH`. Its schemas are RAW, STAGING, MARTS and REPORTING. It runs on an XSMALL warehouse that suspends after 60 seconds. Credentials stay on my machine, never in the repo.

## 1. Connection (one time)
I use key-pair auth, so no password sits in a file.

```
mkdir -p ~/.snowflake && cd ~/.snowflake
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out rsa_key.p8 -nocrypt
openssl rsa -in rsa_key.p8 -pubout -out rsa_key.pub
chmod 600 rsa_key.p8
```

In a Snowflake worksheet, paste the public key body (without the BEGIN/END lines):
```sql
alter user <MY_USER> set rsa_public_key = '<contents of rsa_key.pub>';
```

Then create `~/.snowflake/connections.toml`:
```toml
[grocery]
account = "<org>-<account>"        # from Snowsight: account menu > Connect a tool
user = "<MY_USER>"
authenticator = "SNOWFLAKE_JWT"
private_key_file = "/Users/<me>/.snowflake/rsa_key.p8"
```
Then lock the file down with `chmod 600 ~/.snowflake/connections.toml`. The connector warns if other users can read it.

## 2. Create objects, then load
```
.venv/bin/python python/pipeline.py extract   # source files to data/raw/*.csv
.venv/bin/python python/pipeline.py setup     # role, warehouse, database, schemas (ACCOUNTADMIN)
.venv/bin/python python/pipeline.py load      # PUT to stage, COPY INTO RAW, row-count checks
```

`setup.sql` is safe to re-run. `raw_tables.sql` recreates the RAW tables on every load, so a reload always starts clean. COPY uses `on_error = abort_statement`, so one bad row fails the load instead of being skipped. The loader exits non-zero if any table's row count differs from the published counts.

## Files
| File | What it does |
|---|---|
| `setup.sql` | Role `GGD_ROLE`, warehouse `GGD_WH`, database and schemas |
| `raw_tables.sql` | CSV file format, internal stage, one RAW table per source file |

Object names can be changed with the environment variables `GGD_DATABASE`, `GGD_WAREHOUSE`, `GGD_ROLE` and `GGD_SNOWFLAKE_CONNECTION`.
