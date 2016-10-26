context("test idig_build_attrib")

test_that("attribution dataframe built from results dataframe and item counts match", {
  testthat::skip_on_cran()

  testQuery <- idig_search_records(rq=list(family="holothuriidae"))
  df <- idig_build_attrib(testQuery)
  expect_that(df, is_a("data.frame"))
  expect_that(sum(df$itemCount) == attributes(testQuery)$itemCount, is_true())
  
})

test_that("limited results, attribution counts match limit and result counts", {
  testthat::skip_on_cran()

  df <- idig_search_records(rq=list(genus="acer"), limit=10)
  tt <- idig_build_attrib(df)
  expect_that(nrow(df) == 10, is_true())
  expect_that(sum(tt$itemCount) == 10, is_true())
})
