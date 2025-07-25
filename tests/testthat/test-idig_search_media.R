##' These tests are more media-specific, for fuller searching tests, see
##' test-idig_search_records.R
##'
context("test idig_search_media")

genus <- "cortinarius"
rq <- list("genus" = genus)
mq <- list("dqs" = list("type" = "range", "gte" = 0.2, "lte" = 0.8))
fields <- c("uuid", "dqs", "hasSpecimen", "data.ac:accessURI")
u <- "00d96710-77dd-492c-9d5c-095a8cf9ee5a"

test_that("full results for rq searches return", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  df <- idig_search_media(rq = rq, limit = 6000)

  expect_that(df, is_a("data.frame"))
  expect_true(nrow(df) > 5000)
  expect_true(which(df$uuid == u) > 0)
})

test_that("full results for rq & mq queries together return", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  df <- idig_search_media(rq = rq, mq = mq, limit = 6000)

  expect_that(df, is_a("data.frame"))
  expect_true(nrow(df) > 5000)
  expect_true(which(df$uuid == u) > 0)
})

test_that("full results for mq queries return", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  df <- idig_search_media(mq = mq, limit = 6000)
  u <- "00001244-7d13-4bc0-beff-f7f271632c98"
  
  expect_that(df, is_a("data.frame"))
  expect_true(nrow(df) > 5000)
  expect_true(which(df$uuid == u) > 0)
  expect_true(attributes(df)[["itemCount"]] > 5000)
  expect_true(length(attributes(df)[["attribution"]]) > 2)
})

test_that("limits and custom fields return", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()
  
  df <- idig_search_media(mq = mq, fields = fields, limit = 10)

  expect_true(nrow(df) == 10)
  expect_true(ncol(df) == length(fields))
  expect_true(any(!is.null(df[["uuid"]])) &&
                any(df[["uuid"]] != "NA"))
  expect_true(any(!is.null(df[["data.ac:accessURI"]])) &&
                any(df[["data.ac:accessURI"]] != "NA"))
})
