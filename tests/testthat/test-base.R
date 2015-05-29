
## for GET
context("test GET")
getReq <- list(rq=jsonlite::toJSON(list(family="holothuriidae")))
r <- idig_GET("search/records", query=getReq)

# Complete list of all top-level fields returned in JSON
expect_true(all(names(httr::content(r)) %in% c("itemCount", "lastModified", "items", "attribution")))
expect_true(httr::content(r)$itemCount > 4000 && httr::content(r)$itemCount < 1000000)

## for POST
context("test POST")
fm <- list(rq=list(family="holothuriidae"))
r <- idig_POST("search/records", body=fm)

# Complete list of all top-level fields returned in JSON
expect_true(all(names(httr::content(r)) %in% c("itemCount", "lastModified", "items", "attribution")))
expect_true(httr::content(r)$itemCount > 4000 && httr::content(r)$itemCount < 1000000)

## 400 errors print messages
expect_error(idig_search_records(rq=list("asdf"="asdf")), 
             "HTTP failure: 400")

## for idig_field_indexes
context("test idig_field_indexes")
v <- c("a", "data.b")
l <- idig_field_indexes(v)
expect_that(l[["a"]], is_equivalent_to(c("indexTerms", "a")))
expect_that(l[["data.b"]], is_equivalent_to(c("data", "b")))
v <- c("a", "geopoint", "flags", "recordids", "mediarecords")
l <- idig_field_indexes(v)
expect_that(l[["geopoint.lat"]], is_equivalent_to(c("indexTerms", "geopoint.lat")))
expect_that(l[["geopoint.lon"]], is_equivalent_to(c("indexTerms", "geopoint.lon")))
expect_that(is.null(l[["flags"]]), is_true())
expect_that(is.null(l[["recordids"]]), is_true())
expect_that(is.null(l[["mediarecords"]]), is_true())