##' Function to query the iDigBio API for specimen records
##'
##' Currently the query needs to be specified as a list. All matching results 
##' are returned up to the max_items cap (default 100,000). If more results are
##' wanted, the max_items can be passed as an option. Limit and offset are
##' availible if manual paging of results is needed though the max_items cap
##' still applies as the item count comes from the results header not the
##' count of actual records in the limit/offset window.
##'
##' Return is a data.frame containing the requested fields (or the default
##' fields). The columns in the data frame are types however no factors are 
##' built. Attribution and other metadata is attached to the dataframe in the
##' data.frame's attributes. (I.e. attributes(df)) Not exported.
##' @title Basic searching of iDigBio records
##' @param rq iDigBio record query in nested list format
##' @param fields vector of fields that will be contained in the data.frame, 
##' limited set returned by default, use "all" to get all indexed fields
##' @param max_items maximum number of results allowed to be retrieved (fail
##' -safe)
##' @param limit maximum number of results returned
##' @param offset number of results to skip before returning results
##' @param sort vector of fields to use for sorting, if paging always include 
##' UUID to get reliable record order
##' @param ... additional parameters
##' @return a data frame
##' @author Matthew Collins
##' @examples
##' \dontrun{
##' idig_search(rq=list(genus="acer"), limit=10)
##' }
##' @export
##'

idig_search_records <- function(rq, fields=FALSE, max_items=100000, limit=0,
                        offset=0, sort=FALSE, ...) {

  DEFAULT_FIELDS = c('uuid',
                     'occurrenceid',
                     'catalognumber',
                     'family',
                     'genus',
                     'scientificname',
                     'country',
                     'stateprovince',
                     'geopoint',
                     'datecollected',
                     'collector')

  # Validate inputs
  if (!(inherits(rq, "list"))) { stop("rq is not a list") }

  if (!(length(rq) > 0)) { stop("rq must not be 0 length") }

  if (inherits(fields, "logical") && fields == FALSE) {
    fields <- DEFAULT_FIELDS
  }

  if (!(fields == "all" ) && !(inherits(fields, "character"))) {
    stop("Invalid value for fields")
  }

  idig_search(rq=rq, fields=fields, max_items=max_items, limit=limit,
              offset=offset, sort=sort, ...)

}
