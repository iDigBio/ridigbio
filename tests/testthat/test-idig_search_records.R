context("test idig_search_records")

genus <- "acer"
rq <-list("genus"=genus)
fields <- c('uuid', 'genus', 'scientificname')


# Basic search, full results
df <- idig_search_records(rq=rq, limit=6000)
expect_that(df, is_a("data.frame"))
expect_that(nrow(df) > 5000, is_true())
expect_that(which(df$uuid == "d4f6974f-a7d6-4bfb-b70c-4c815b516a0b") > 0, is_true())
expect_that(min(df$genus) == genus && max(df$genus) == genus, is_true())

# Limited results, custom fields
df <- idig_search_records(rq=rq, fields=fields, limit=10)
expect_that(nrow(df) == 10, is_true())
expect_that(ncol(df) == length(fields), is_true())
# Save some UUIDs for later
second_uuid <- df[["uuid"]][[2]]

# Dataframe is formatted properly
for (i in 1:length(fields)){
  expect_that(df[[fields[[i]]]][[1]], is_a("character"))
}

# Offset
df <- idig_search_records(rq=rq, limit=1, offset=1)
expect_that(nrow(df) == 1, is_true())
expect_that(df[["uuid"]][[1]] == second_uuid, is_true())

# Max items
expect_that(df <- idig_search_records(rq=list("country"="united states")), throws_error("max_items"))


