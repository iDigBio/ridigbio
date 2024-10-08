context("test idig_count_media")

recordset <- "7450a9e3-ef95-4f9e-8260-09b498d2c5e6"
dqs <- 0

test_that("all media records is a large number", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  num <- idig_count_media()

  expect_that(num, is_a("integer"))
  expect_true((num - num) == 0)
  expect_true(num > 4 * 1000 * 1000)
})

test_that("rq searches on the endpoint is a small number", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  num <- idig_count_media(rq = list("recordset" = recordset))

  expect_that(num, is_a("integer"))
  expect_true(num > 10 * 1000)
})

test_that("mq searches on the endpoint is a small number", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()
  
  num <- idig_count_media(mq = list("dqs" = dqs))

  expect_that(num, is_a("integer"))
  expect_true(num > 1000)
})
