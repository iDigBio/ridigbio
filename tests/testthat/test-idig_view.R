context("test idig_view")

rec_uuid = "d4f6974f-a7d6-4bfb-b70c-4c815b516a0b"
med_uuid = "e2d288dc-319e-4a13-b759-527021122bbc"

rec <- idig_view(rec_uuid)

# JSON returned is technically an object but R maps it to a list
expect_that(rec, is_a("list"))
expect_that(rec$uuid, equals(rec_uuid))
expect_that(rec$data, is_a("list"))
expect_that(length(rec$data$id) > 0, is_true())
expect_that(rec$indexTerms, is_a("list"))
expect_that(rec$indexTerms$uuid, equals(rec_uuid))
expect_that(rec$attribution, is_a("list"))
expect_that(length(rec$attribution$data_rights) > 0, is_true())

med <- idig_view(med_uuid, type="mediarecords")
expect_that(med, is_a("list"))
expect_that(med$uuid, equals(med_uuid))
expect_that(med$data, is_a("list"))
expect_that(length(med$data$coreid) > 0, is_true())
expect_that(med$indexTerms, is_a("list"))
expect_that(med$indexTerms$uuid, equals(med_uuid))
expect_that(med$attribution, is_a("list"))
expect_that(length(med$attribution$description) > 0, is_true())