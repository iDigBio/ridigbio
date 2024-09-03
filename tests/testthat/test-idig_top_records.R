context("test idig_top_records")

field <- "country"
most <- "united states"
count <- 11
genus <- "acer"
scientificname <- "acer macrophyllum"

test_that("default list of top 10 scientific names returns", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  top <- idig_top_records()

  expect_that(top, is_a("list"))
  expect_that(length(top$scientificname), equals(10))
  expect_true(top$itemCount > 20 * 1000 * 1000)

  # Save the number of records in all iDigBio for later tests
  # all_count <- top$itemCount
})

test_that("field and number of tops work", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  top <- idig_top_records(top_fields = c(field), count = count)

  expect_that(top, is_a("list"))
  expect_that(length(top[[field]]), equals(count))
  expect_true(top[[field]][[most]][["itemCount"]] > 1000 * 1000)

})

test_that("record searches work", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  top <- idig_top_records(
    rq = list("genus" = genus), top_fields = c(field),
    count = count
  )

  expect_that(top, is_a("list"))
  expect_true(top$itemCount < 200 * 1000)

  # Save the number of genus records for later tests
  # genus_count <- top$itemCount
})

test_that("multiple fields return nested results", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()
  
  top <- idig_top_records(rq = list("genus" = genus), top_fields = c(
    field,
    "scientificname"
  ), count = count)

  expect_that(top, is_a("list"))
  expect_true(top[[field]][[most]][["scientificname"]][[scientificname]][["itemCount"]]
              > 1000)
})