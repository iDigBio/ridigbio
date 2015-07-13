context("test idig_search_records")

genus <- "acer"
rq <-list("genus"=genus)
fields <- c('uuid', 'genus', 'specificepithet', 'data.dwc:occurrenceID')


# Basic search, full results
df <- idig_search_records(rq=rq, limit=6000)
expect_that(df, is_a("data.frame"))
expect_that(nrow(df) > 5000, is_true())
expect_that(attributes(df)[["itemCount"]] > 5000, is_true())
expect_that(length(attributes(df)[["attribution"]]) > 2 , is_true())
expect_that(which(df$uuid == "00041678-5df1-4a23-ba78-8c12f60af369") > 0,
            is_true())
expect_true(all(df$genus == genus))

# Limited results, custom fields
df <- idig_search_records(rq=rq, fields=fields, limit=10)
expect_that(nrow(df) == 10, is_true())
expect_that(ncol(df) == length(fields), is_true())
expect_that(!is.null(df[1, "uuid"]) && df[1, "uuid"] != "NA", is_true())
expect_that(!is.null(df[1, "data.dwc:occurrenceID"]) && 
              df[1, "data.dwc:occurrenceID"] != "NA", is_true())
# Save a UUID for offset
second_uuid <- df[["uuid"]][[2]]

# Offset
df <- idig_search_records(rq=rq, fields=fields, limit=1, offset=1)
expect_that(nrow(df) == 1, is_true())
expect_that(df[["uuid"]][[1]] == second_uuid, is_true())

# Sorting
df <- idig_search_records(rq=rq, fields=fields, limit=1)
expect_that(substr(df[["uuid"]], 1, 2) == "00", is_true())
# coincidence of the data at the moment
expect_that(substr(df[["specificepithet"]], 1, 1) > "m", is_true())
df <- idig_search_records(rq=rq, fields=fields, limit=1,
                          sort="specificepithet")
expect_that(substr(df[["uuid"]], 1, 2) == "00", is_false())
expect_that(substr(df[["specificepithet"]], 1, 1) < "m", is_true())

# Max items
expect_that(df <- idig_search_records(rq=list("country"="united states")),
            throws_error("max_items"))

# All fields
df <- idig_search_records(rq=rq, fields="all", limit=10)
expect_that(ncol(df) > 50, is_true())

# Dataframe w/default fields is formatted properly including NA's as chr 
# columns instead of log. - Decided not to bother cooercing NA to chr so leaving
# this commented out awaiting more sophisticated type checking.
#df <- idig_search_records(rq=rq, limit=1)
#for (i in 1:ncol(df)){
#  expect_that(df[[i]], is_a("character"))
#}

# Empty results
df <- idig_search_records(rq=list("uuid"="nobodyhome"), fields=fields)
expect_that(nrow(df) == 0, is_true())
expect_that(ncol(df) == length(fields), is_true())

# Geopoint and special fields
fields_special <- c("uuid", "geopoint", "mediarecords", "flags", "recordids")
df <- idig_search_records(rq=list("uuid"="f84faea8-82ac-4f71-b256-6b2be5d1b59d"),
                          fields=fields_special, limit=10)
expect_that(ncol(df) == length(fields_special) + 1, is_true())
expect_that(inherits(df[1, "geopoint.lon"], "numeric"), is_true())
expect_that(inherits(df[1, "geopoint.lat"], "numeric"), is_true())
expect_that(inherits(df[1, "flags"], "list"), is_true())
expect_that(inherits(df[1, "mediarecords"], "list"), is_true())
expect_that(inherits(df[1, "recordids"], "list"), is_true())
