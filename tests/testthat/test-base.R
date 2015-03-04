
## for GET
context("test GET")
getReq <- list(rq=jsonlite::toJSON(list(family="holothuriidae")))
r <- idig_GET("search", query=getReq)

expect_true(all(names(httr::content(r)) %in% c("itemCount", "items", "attribution")))
expect_true(httr::content(r)$itemCount > 4000 && httr::content(r)$itemCount < 1000000)

## for POST
context("test POST")
fm <- list(rq=list(family="holothuriidae"))
r <- idig_POST("search", body=fm)

expect_true(all(names(httr::content(r)) %in% c("itemCount", "items", "attribution")))
expect_true(httr::content(r)$itemCount > 4000 && httr::content(r)$itemCount < 1000000)

## for idig_field_indexes
context("test idig_field_indexes")
v <- c("a", "b")
l <- idig_field_indexes(v)
expect_that(l$a == "a", is_true())
expect_that(l$b == "b", is_true())
v <- c("a", "geopoint", "flags", "recordids", "mediarecords")
l <- idig_field_indexes(v)
expect_that(l$geopoint.lat, is_equivalent_to(c("geopoint", "lat")))
expect_that(l$geopoint.lon, is_equivalent_to(c("geopoint", "lon")))
expect_that(is.null(l$flags), is_true())
expect_that(is.null(l$recordids), is_true())
expect_that(is.null(l$mediarecords), is_true())