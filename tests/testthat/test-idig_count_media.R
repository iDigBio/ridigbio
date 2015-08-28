context("test idig_count_media")

recordset <- "7450a9e3-ef95-4f9e-8260-09b498d2c5e6"
dqs <- 0

# All media
num <- idig_count_media()
expect_that(num, is_a("integer"))
expect_that((num - num) == 0, is_true())
expect_that(num > 4 * 1000 * 1000, is_true())

# Searches
num <- idig_count_media(rq=list("recordset"=recordset))
expect_that(num, is_a("integer"))
expect_that(num > 10 * 1000, is_true())

num <- idig_count_media(mq=list("dqs"=dqs))
expect_that(num, is_a("integer"))
expect_that(num > 1000, is_true())
