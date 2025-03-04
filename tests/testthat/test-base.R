## for GET
context("test GET")

test_that("list of all top-level fields returned in JSON", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()
  getReq <- list(rq = jsonlite::toJSON(list(family = "holothuriidae")))
  r <- idig_GET("search/records", query = getReq)

  expect_true(all(names(httr::content(r)) %in% c("itemCount", "lastModified", "items", "attribution", "aggs")))
  expect_true(httr::content(r)$itemCount > 4000 && httr::content(r)$itemCount < 1000000)
})


## for POST
context("test POST")

test_that("list of all top-level fields returned in JSON", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()
  fm <- list(rq = list(family = "holothuriidae"))
  r <- idig_POST("search/records", body = fm)

  expect_true(all(names(httr::content(r)) %in% c("itemCount", "lastModified", "items", "attribution", "aggs")))
  expect_true(httr::content(r)$itemCount > 4000 && httr::content(r)$itemCount < 1000000)
})

test_that("400 errors print messages", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  expect_error(
    idig_search_records(rq = list("asdf" = "asdf")),
    "HTTP failure: 400"
  )
})