context("test idig_build_attrib")

test_that("attribution dataframe built from results dataframe and item counts match", {
  testthat::skip_on_cran()

  testQuery <- idig_search_records(rq=list(family="holothuriidae"))
  df <- idig_build_attrib(testQuery)
  expect_that(df, is_a("data.frame"))
  expect_true(sum(df$itemCount) == attributes(testQuery)$itemCount)
  
})

test_that("limited results, attribution counts match limit and result counts", {
  testthat::skip_on_cran()

  df <- idig_search_records(rq=list(genus="acer"), limit=10)
  tt <- idig_build_attrib(df)
  expect_true(nrow(df) == 10)
  expect_true(sum(tt$itemCount) == 10)
})
