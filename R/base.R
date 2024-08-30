##' Return base URL for the API calls.
##'
##' Defaults to use beta URL. Not exported.
##' @title base URL
##' @return string for the URL
##' @param dev Should be the beta version of the API be used?
##' @author Francois Michonneau
idig_url <- function(dev = FALSE) {
  if (dev) {
    "https://beta-search.idigbio.org"
  } else {
    "https://search.idigbio.org"
  }
}

##' Return the version number to use for the API calls.
##'
##' The current default is "v2". Not exported.
##' @title API version
##' @param version optional argument giving the version of the API to use
##' @return string for the version to use
##' @author Francois Michonneau
idig_version <- function(version = "v2") {
  stopifnot(identical(typeof(version), "character"))
  version
}

##' Parses output of successful query to return a list.
##'
##' Not exported.
##' @title parse successfully returned request
##' @param req the returned request
##' @return a list
##' @author Francois Michonneau
idig_parse <- function(req) {
  txt <- httr::content(req, as = "text")
  if (identical(txt, "")) stop("No output to parse", call. = FALSE)
  jsonlite::fromJSON(txt, simplifyVector = FALSE)
}

##' Checks for HTTP error codes and JSON errors.
##'
##' Part 1 of the error checking process. This part handles HTTP error codes and
##' then calls part 2 which handles JSON errors in the responses. Not exported.
##' @title check HTTP code
##' @param req the returned request
##' @return nothing. Stops if HTTP code is >= 400
##' @author Francois Michonneau
idig_check <- function(req) {
  tryCatch(
    {
      if (req$status_code >= 400) {
        msg <- substr(req, 1, 200)
        stop("HTTP failure: ", req$status_code, "\n",
          "Error message from API server: ", msg,
          call. = FALSE
        )
      }
      idig_check_error(req)
    },
    error = function(e) {
      warning("Error during API request: ", e$message)
      msg <- substr(req, 1, 200)
      stop("HTTP failure: ", req$status_code, "\n",
        "Error message from API server: ", msg,
        call. = FALSE
      )
      idig_check_error(req)
    }
  )
}

##' Checks for error messages that can be returned by the API in JSON.
##'
##' Part 2 of the error checking process. Checks the JSON response for error
##' messages and stops if any are found. Not exported.
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

##' Internal function for GET requests.
##'
##' Generates a GET request and performs the checks on what is returned. Not
##' exported.
##' @title internal GET request
##' @param path endpoint
##' @param ... additional arguments to be passed to httr::GET
##' @return the request (as a list)
##' @author Francois Michonneau
idig_GET <- function(path, ...) {
  req <- httr::GET(idig_url(), path = paste(idig_version(), path, sep = "/"), ...)
  idig_check(req)
  req
}

##' Internal function for POST requests.
##'
##' Generates a POST request and performs the checks on what is returned. Not
##' exported.
##' @title internal POST request
##' @param path endpoint
##' @param body a list of parameters for the endpoint
##' @param ... additional arguments to be passed to httr::POST
##' @return the request (as a list)
##' @author Francois Michonneau
##'
idig_POST <- function(path, body, ...) {
  stopifnot(inherits(body, "list"))

  # Manually encode so we can use auto_unbox=TRUE, see ticket
  # https://github.com/iDigBio/ridigbio/issues/3
  json <- jsonlite::toJSON(body, auto_unbox = TRUE)
  req <- httr::POST(idig_url(),
    path = paste("v2", path, sep = "/"),
    body = json, httr::accept_json(),
    httr::content_type_json(), ...
  )
  idig_check(req)
  req
}

##' Stub function for validating parameters.
##'
##' Takes list of inputs named by validation rule eg:
##' `number:[2, 3]` and returns
##' a vector of strings with any validation errors. If the vector is 0 length,
##' everything is valid. Not exported.
##' @title validate fields
##' @param inputs list of inputs to validate
##' @return boolean
##' @author Matthew Collins
##'
idig_validate <- function(inputs) {
}

##' Stub function for passing import checks
#| eval: false
ignore_unused_imports <- function() {
  leaflet::`%>%`()
  kableExtra::kable()
  tidyverse::tidyverse_logo()
  cowplot::theme_minimal_grid()
}
