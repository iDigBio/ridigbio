context("test idig_top_records")

field <- "country"
most <- "united states"
count <- 11
genus <- "acer"
scientificname <- "acer macrophyllum"

# Default list of top 10 scientific names
top <- idig_top_records()
expect_that(top, is_a("list"))
expect_that(length(top$scientificname), equals(10))
expect_that(top$itemCount > 20 * 1000 * 1000, is_true())
# Save the number of records in all iDigBio for later tests
all_count <- top$itemCount

# Field and number of tops
top <- idig_top_records(top_fields=c(field), count=count)
expect_that(top, is_a("list"))
expect_that(length(top[[field]]), equals(count))
expect_that(top[[field]][[most]][["itemCount"]] > 1000 * 1000, is_true())
# Still looking at all of iDigBio, assume things are not changing too fast
expect_that(abs(top$itemCount - all_count) < 1000, is_true())

# Searches
top <- idig_top_records(rq=list("genus"=genus), top_fields=c(field),
                       count=count)
expect_that(top, is_a("list"))
expect_that(top$itemCount < 200 * 1000, is_true())
# Save the number of genus records for later tests
genus_count <- top$itemCount

# Multiple fields
top <- idig_top_records(rq=list("genus"=genus), top_fields=c(field, 
                       "scientificname"), count=count)
expect_that(top, is_a("list"))
expect_that(abs(top$itemCount - genus_count) < 100, is_true())
expect_that(top[[field]][[most]][["scientificname"]][[scientificname]][["itemCount"]]
            > 1000, is_true())