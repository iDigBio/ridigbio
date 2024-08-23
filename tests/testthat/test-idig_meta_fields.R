context("test idig_meta_fields")

test_that("records field list returns", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  f <- idig_meta_fields()

  expect_that(f, is_a("list"))
  expect_that(f[["data"]], is_a("list"))
  expect_that(f[["indexData"]], is_a("list"))
  expect_true(f[["uuid"]][["type"]] == "string")
})

test_that("records indexed subset returns", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  f <- idig_meta_fields(subset = "indexed")

  expect_null(f[["data"]])
  expect_null(f[["indexData"]])
  expect_true(f[["uuid"]][["type"]] == "string")
})

test_that("records raw subset returns", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  f <- idig_meta_fields(subset = "raw")

  expect_null(f[["uuid"]])
  expect_true(f[["dwc:occurrenceID"]][["type"]] == "string")
})

test_that("media list returns", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  f <- idig_meta_fields(type = "media")

  expect_that(f, is_a("list"))
  expect_that(f[["data"]], is_a("list"))
  expect_that(f[["indexData"]], is_a("list"))
  expect_true(f[["uuid"]][["type"]] == "string")
})

test_that("media indexed subset returns", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  f <- idig_meta_fields(type = "media", subset = "indexed")

  expect_null(f[["data"]])
  expect_null(f[["indexData"]])
  expect_true(f[["uuid"]][["type"]] == "string")
})

test_that("media raw subset returns", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()
  
  f <- idig_meta_fields(type = "media", subset = "raw")

  expect_null(f[["uuid"]])
  expect_true(f[["ac:accessURI"]][["type"]] == "string")
})
