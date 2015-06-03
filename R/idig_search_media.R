##' Function to query the iDigBio API for specimen media
##'
##' Currently the query needs to be specified as a list. All matching results are
##' returned up to the max_items cap (default 100,000). If more results are
##' wanted, the max_items can be passed as an option. Limit and offset are
##' availible if manual paging of results is needed though the max_items cap
##' still applies as the item count comes from the results header not the
##' count of actual media in the limit/offset window.
##'
##' Return is a data.frame containing the requested fields (or the dfault fields).
##' Only fields from the Elasticsearch index are currently availible, no raw
##' fields. As such, the columns in the data frame are types however no factors
##' are built. Attribution and other metadata is attached to the dataframe in the
##' data.frame's attributes. (I.e. attributes(df))
##' @title Basic searching of iDigBio media
##' @param query a list containing the information to be searched in iDigBio
##' @param fields list of fields that will be contained in the data.frame
##' @param max_items maximum number of results allowed to be retrieved
##' @param limit maximum number of results returned
##' @param offset number of results to skip before returning results
##' @param ... additional parameters (currently not in use)
##' @return a data frame
##' @author Francois Michonneau
##' @examples
##' \dontrun{
##' idig_search(rq=list(genus="acer"), limit=10)
##' }
##' @export
##'

idig_search_media <- function(mq=FALSE, rq=FALSE, fields=FALSE, max_items=100000, limit=0,
                        offset=0, sort=FALSE, ...) {

  DEFAULT_FIELDS = "all"

  # Validate inputs
  #if (!(inherits(rq, "list"))) { stop("rq is not a list") }

  if (!(length(rq) > 0) && !(length(rq) > 0)) { stop("mq or rq must not be 0 length") }

  if (inherits(fields, "logical") && fields == FALSE) {
    fields <- DEFAULT_FIELDS
  }

  if (!(fields == "all" ) && !(inherits(fields, "character"))) {
    stop("Invalid value for fields")
  }

  idig_search(type="media", mq=mq, rq=rq, fields=fields, max_items=max_items, limit=limit,
              offset=offset, sort=sort, ...)

}
