context("test idig_view_media")

med_uuid = "e2d288dc-319e-4a13-b759-527021122bbc"

test_that("viewing a media record returns right information", {
  testthat::skip_on_cran()
  med <- idig_view_media(med_uuid)
  
  expect_that(med, is_a("list"))
  expect_that(med$uuid, equals(med_uuid))
  expect_that(med$data, is_a("list"))
  expect_true(length(med$data$coreid) > 0)
  expect_that(med$indexTerms, is_a("list"))
  expect_that(med$indexTerms$uuid, equals(med_uuid))
  expect_that(med$attribution, is_a("list"))
  expect_true(length(med$attribution$description) > 0)
})