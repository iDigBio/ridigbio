context("test idig_meta_fields")

# Records
f <- idig_meta_fields()
expect_that(f, is_a("list"))
expect_that(f[["data"]], is_a("list"))
expect_that(f[["uuid"]][["type"]] == "string", is_true())

f <- idig_meta_fields(subset="indexed")
expect_that(f[["data"]], is_null())
expect_that(f[["uuid"]][["type"]] == "string", is_true())

f <- idig_meta_fields(subset="raw")
expect_that(f[["uuid"]], is_null())
expect_that(f[["dwc:occurrenceID"]][["type"]] == "string", is_true())

# Media
f <- idig_meta_fields(type="media")
expect_that(f, is_a("list"))
expect_that(f[["data"]], is_a("list"))
expect_that(f[["uuid"]][["type"]] == "string", is_true())

f <- idig_meta_fields(type="media", subset="indexed")
expect_that(f[["data"]], is_null())
expect_that(f[["uuid"]][["type"]] == "string", is_true())

f <- idig_meta_fields(type="media", subset="raw")
expect_that(f[["uuid"]], is_null())
expect_that(f[["ac:accessURI"]][["type"]] == "string", is_true())
