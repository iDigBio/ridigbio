context("test idig_view_media")

med_uuid <- "fbd213eb-8b87-4064-a487-f429dd1810d2"

test_that("viewing a media record returns right information", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()
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