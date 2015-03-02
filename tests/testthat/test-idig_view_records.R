context("test idig_view_records")

rec_uuid = "d4f6974f-a7d6-4bfb-b70c-4c815b516a0b"

rec <- idig_view_records(rec_uuid)

# JSON returned is technically an object but R maps it to a list
expect_that(rec, is_a("list"))
expect_that(rec$uuid, equals(rec_uuid))
expect_that(rec$data, is_a("list"))
expect_that(length(rec$data$id) > 0, is_true())
expect_that(rec$indexTerms, is_a("list"))
expect_that(rec$indexTerms$uuid, equals(rec_uuid))
expect_that(rec$attribution, is_a("list"))
expect_that(length(rec$attribution$data_rights) > 0, is_true())
