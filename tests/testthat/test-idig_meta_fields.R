context("test idig_meta_fields")

# Records
f <- idig_meta_fields()
expect_that(f, is_a("list"))
expect_that(f[["data"]], is_a("list"))
expect_that(f[["uuid"]][["type"]] == "string", is_true())

# Media
f <- idig_meta_fields(type="media")
expect_that(f, is_a("list"))
expect_that(f[["data"]], is_a("list"))
expect_that(f[["uuid"]][["type"]] == "string", is_true())
