
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
