context("test idig_view_records")

rec_uuid <- "d4f6974f-a7d6-4bfb-b70c-4c815b516a0b"

test_that("viewing a record returns right information", {
  testthat::skip_on_cran()
  rec <- idig_view_records(rec_uuid)

  expect_that(rec, is_a("list"))
  expect_that(rec$uuid, equals(rec_uuid))
  expect_that(rec$data, is_a("list"))
  expect_true(length(rec$data$id) > 0)
  expect_that(rec$indexTerms, is_a("list"))
  expect_that(rec$indexTerms$uuid, equals(rec_uuid))
  expect_that(rec$attribution, is_a("list"))
  expect_true(length(rec$attribution$data_rights) > 0)
})
