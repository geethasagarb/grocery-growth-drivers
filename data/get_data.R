# Download 84.51° The Complete Journey (CC0) and write every table to data/raw/ as CSV.
# Usage (from repo root): Rscript data/get_data.R
if (!requireNamespace("completejourney", quietly = TRUE)) {
  install.packages("completejourney", repos = "https://cloud.r-project.org")
}
library(completejourney)

out <- file.path("data", "raw")
dir.create(out, showWarnings = FALSE, recursive = TRUE)

small <- c("campaigns", "campaign_descriptions", "coupons",
           "coupon_redemptions", "demographics", "products")
for (nm in small) {
  df <- get(nm, envir = asNamespace("completejourney"))
  write.csv(df, file.path(out, paste0(nm, ".csv")), row.names = FALSE)
  message(nm, ": ", nrow(df), " rows")
}

tx <- get_transactions(verbose = FALSE)
tx$transaction_timestamp <- format(tx$transaction_timestamp, "%Y-%m-%d %H:%M:%S", tz = "UTC")
write.csv(tx, file.path(out, "transactions.csv"), row.names = FALSE)
message("transactions: ", nrow(tx), " rows")

promo <- get_promotions(verbose = FALSE)
write.csv(promo, file.path(out, "promotions.csv"), row.names = FALSE)
message("promotions: ", nrow(promo), " rows")
