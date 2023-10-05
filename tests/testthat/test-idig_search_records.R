context("test idig_search_records")

genus <- "acer"
rq <- list("genus" = genus)
fields <- c("uuid", "genus", "specificepithet", "data.dwc:occurrenceID")

test_that("basic search, full results works", {
  testthat::skip_on_cran()
  df <- idig_search_records(rq = rq, limit = 6000)

  expect_that(df, is_a("data.frame"))
  expect_true(nrow(df) > 5000)
  expect_true(attributes(df)[["itemCount"]] > 5000)
  expect_true(length(attributes(df)[["attribution"]]) > 2)
  expect_true(which(df$uuid == "00041678-5df1-4a23-ba78-8c12f60af369") > 0)
  expect_true(all(df$genus == genus))
})

test_that("limited results, custom fields works", {
  testthat::skip_on_cran()
  df <- idig_search_records(rq = rq, fields = fields, limit = 10)

  expect_true(nrow(df) == 10)
  expect_true(ncol(df) == length(fields))
  expect_true(!is.null(df[1, "uuid"]) && df[1, "uuid"] != "NA")
  expect_true(!is.null(df[1, "data.dwc:occurrenceID"]) &&
    df[1, "data.dwc:occurrenceID"] != "NA")
})

test_that("offset works", {
  testthat::skip_on_cran()

  df <- idig_search_records(rq = rq, fields = fields, limit = 2, offset = 0)
  second_uuid <- df[["uuid"]][[2]]

  df <- idig_search_records(rq = rq, fields = fields, limit = 1, offset = 1)
  expect_true(nrow(df) == 1)
  expect_true(df[["uuid"]][[1]] == second_uuid)
})

test_that("sorting works", {
  testthat::skip_on_cran()
  df <- idig_search_records(rq = rq, fields = fields, limit = 1)

  expect_true(substr(df[["uuid"]], 1, 2) == "00")
  # coincidence of the data at the moment
  expect_true(substr(df[["specificepithet"]], 1, 1) > "m")

  df <- idig_search_records(
    rq = rq, fields = fields, limit = 1,
    sort = "specificepithet"
  )
  expect_false(substr(df[["uuid"]], 1, 2) == "00")
  expect_true(substr(df[["specificepithet"]], 1, 1) < "m")
})

test_that("max items disabled is thrown for large queries", {
  testthat::skip_on_cran()

  expect_that(
    df <- idig_search_records(rq = list("country" = "united states")),
    throws_error("disabled")
  )
})

test_that("max items disabled is thrown for windows past 100k", {
  testthat::skip_on_cran()

  expect_that(
    df <- idig_search_records(
      rq = list("country" = "united states"),
      offset = 99000, limit = 2000
    ),
    throws_error("disabled")
  )
})

test_that("can get the 100000th result", {
  testthat::skip_on_cran()

  df <- idig_search_records(
    rq = list("country" = "united states"),
    limit = 1, offset = 99999
  )
  expect_true(nrow(df) == 1)
})

test_that("all fields returns a lot of fields", {
  testthat::skip_on_cran()
  df <- idig_search_records(rq = rq, fields = "all", limit = 10)

  expect_true(ncol(df) > 50)
})

test_that("empty results return empty df with correct columns", {
  testthat::skip_on_cran()
  df <- idig_search_records(rq = list("uuid" = "nobodyhome"), fields = fields)

  expect_true(nrow(df) == 0)
  expect_true(ncol(df) == length(fields))
})

test_that("geopoint and special fields are expanded or excluded as appropriate", {
  testthat::skip_on_cran()
  fields_special <- c("uuid", "geopoint", "mediarecords", "flags", "recordids")
  df <- idig_search_records(
    rq = list("uuid" = "f84faea8-82ac-4f71-b256-6b2be5d1b59d"),
    fields = fields_special, limit = 10
  )

  expect_true(ncol(df) == length(fields_special) + 1)
  expect_true(inherits(df[1, "geopoint.lon"], "numeric"))
  expect_true(inherits(df[1, "geopoint.lat"], "numeric"))
  expect_true(inherits(df[1, "flags"], "list"))
  expect_true(inherits(df[1, "mediarecords"], "list"))
  expect_true(inherits(df[1, "recordids"], "list"))
})
