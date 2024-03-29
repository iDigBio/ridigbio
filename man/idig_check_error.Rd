% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/base.R
\name{idig_check_error}
\alias{idig_check_error}
\title{Check is the request returned an error.}
\usage{
idig_check_error(req)
}
\arguments{
\item{req}{the returned request}
}
\value{
nothing. Stops if request contains an error.
}
\description{
Checks for error messages that can be returned by the API in JSON.
}
\details{
Part 2 of the error checking process. Checks the JSON response for error
messages and stops if any are found. Not exported.
}
\author{
Francois Michonneau
}
