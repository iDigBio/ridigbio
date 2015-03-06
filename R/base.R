##' base URL for the API
##'
##' Not exported
##' @title base URL
##' @return string for the URL
##' @author Francois Michonneau
##' @param dev Should be the beta version of the API be used?
idig_url <- function(dev=TRUE) {
    if (dev) {
        "http://beta-search.idigbio.org"
    } else {
        "http://search.idigbio.org"
    }
}

##' version number to use for the API
##'
##' current default is "v2". Function not exported.
##' @title API version
##' @param version optional argument giving the version of the API to use
##' @return string for the version to use
##' @author Francois Michonneau
idig_version <- function(version="v2") {
    stopifnot(identical(typeof(version), "character"))
    version
}

##' parses output of successful query to return a list
##'
##' not exported
##' @title parse successfully returned request
##' @param req the returned request
##' @return a list
##' @author Francois Michonneau
idig_parse <- function(req) {
    txt <- httr::content(req, as="text")
    if (identical(txt, "")) stop("No output to parse", call. = FALSE)
    jsonlite::fromJSON(txt, simplifyVector=FALSE)
}

##' checks for HTTP codes
##'
##' Part 1 of the error checking process. not exported.
##' @title check HTTP code
##' @param req the returned request
##' @return nothing. Stops if HTTP code is < 400
##' @author Francois Michonneau
idig_check <- function(req) {
    if (!req$status_code < 400) {
    	    msg <- idig_parse(req)$message
        stop("HTTP failure: ", req$status_code, "\n", msg, call. = FALSE)
    }
    idig_check_error(req)
}

##' checks for error messages that can be returned by the API
##'
##' Part 2 of the error checking process. not exported.
##' @title Check is the request returned an error.
##' @param req the returned request
##' @return nothing. Stops if request contains an error.
##' @author Francois Michonneau
idig_check_error <- function(req) {
    cont <- httr::content(req)
    if (is.list(cont) && exists("error", cont)) {
        stop(paste("Error: ", cont$error, "\n", sep = ""))
    }
}

##' internal function for GET requests
##'
##' Generates a GET request and performs the checks on what is
##' returned.
##' @title internal GET request
##' @param path endpoint
##' @param ... additional arguments to be passed to httr::GET
##' @return the request (as a list)
##' @author Francois Michonneau
idig_GET <- function(path, ...) {
    req <- httr::GET(idig_url(), path=paste(idig_version(), path, sep="/"), ...)
    idig_check(req)
    req
}


##' internal function for POST requests
##'
##' Generates a POST request and performs the checks on what is
##' returned
##' @title internal POST request
##' @param path endpoint
##' @param body a named list inside a list named "rq"
##' @param encode the API wants "json"
##' @param ... additional arguments to be passed to httr::POST
##' @return the request (as a list)
##' @author Francois Michonneau
idig_POST <- function(path, body, encode="json", ...) {

    stopifnot(inherits(body, "list"))
    #stopifnot(exists("rq", body))

    req <- httr::POST(idig_url(), path=paste(idig_version(), path, sep="/"),
                      body=body, encode=encode, ...)
    idig_check(req)

    req
}


# Takes list of inputs named by validation rule eg "number":[2, 3] and returns
# a vector of strings with any validation errors. If the vector is 0 length, 
# everything is valid.
idig_validate <- function(inputs){
  
  
}

# Some fields returned by the API contain lists or dicts. This function uses
# a hard coded list of those fields (they are stored in ES with these types
# so they are known for indexTerms) to generate a list pretty names and indexes
# to the returned data OR to drop the fields if formating to a fixed number of 
# columns is not possible. R syntax note:
# l[["a"]][["b"]] == l$a$b == l[[c("a", "b")]]
# Note: indexes assume that the returned JSON is unlisted() first.
idig_field_indexes <- function(fields){
  # looping is old school but keeps the order of fields similar to user input
  l = list()
  for (i in fields) {
    if (i == "flags" ||
        i == "recordids" ||
        i == "mediarecords") {
      next
    } else if (i == "geopoint") {
      l[[paste0(i, ".lat")]] <- "geopoint.lat"
      l[[paste0(i, ".lon")]] <- "geopoint.lon"
    } else {
      l[[i]] <- i
    }
  }
  l
}