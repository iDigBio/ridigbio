##' Function to query the iDigBio API for specimen records
##'
##' Currently the query needs to be specified as a list. All matching results are
##' returned up to the max_items cap (default 100,000). If more results are 
##' wanted, the max_items can be passed as an option. Limit and offset are
##' availible if manual paging of results is needed though the max_items cap
##' still applies as the item count comes from the results header not the 
##' count of actual records in the limit/offset window.
##' 
##' Return is a data.frame containing the requested fields (or the dfault fields).
##' Only fields from the Elasticsearch index are currently availible, no raw
##' fields. As such, the columns in the data frame are types however no factors
##' are built. Attribution and other metadata is attached to the dataframe in the
##' data.frame's attributes. (I.e. attributes(df))
##' @title Basic searching of iDigBio records
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

DEFAULT_FIELDS = c('uuid',
                  'occurrenceid',
                  'catalognumber',
                  'family',
                  'genus',
                  'scientificname',
                  'geopoint',
                  'country',
                  'stateprovince',
                  'datecollected',
                  'collector')


idig_search_records <- function(rq, fields=DEFAULT_FIELDS, max_items=100000, limit=0, 
                        offset=0, ...) {
  #print(paste0(Sys.time(), " started"))
  # Validate inputs
  if (!(inherits(rq, "list"))) { stop("rq is not a list") }
      
  if (!(length(rq) > 0)) { stop("rq must not be 0 length") }
  
  if (!(fields == "all" ) && !(inherits(fields, "character"))) {
    stop("Invalid value for fields")
  }

  
    # Construct body of request to API
    query <- list(rq=rq, offset=offset)
    
    if (length(fields) > 1 && inherits(fields, "character")){
      query$fields <- fields
    }
    
    if (limit > 0){
      query$limit <- limit
    }else{
      query$limit <- max_items # effectivly use iDigBio's max page size
    }
    
    # tricks to get inside loop first time
    dat <- data.frame()
    item_count <- 1

    # loop until we either have all results or all results the user wants
    while (nrow(dat) < item_count && (limit == 0 || nrow(dat) < limit)){
      search_results <- idig_POST("search", body=query)
      #print(paste0(Sys.time(), " completed query"))
      # Slight possibility of the number of items changing as we go due to inserts/
      # deletes at iDigBio, put this inside the loop to keep it current
      item_count <- fmt_search_txt_to_itemCount(search_results)
      if ((limit == 0 || limit > max_items) && item_count > max_items){
        stop(paste0("Search would return more than ", max_items, 
                    " results. See max_items argument."))
      }
      
      if (nrow(dat) == 0){
        dat <- fmt_search_txt_to_df(search_results, fields)
      } else {
        #dat <- plyr::rbind.fill(dat, fmt_search_txt_to_df(search_results, fields))
        dat <- rbind(dat, fmt_search_txt_to_df(search_results, fields))
        #print(paste0(Sys.time(), " completed append"))
      }
      # Need to add a safety here to make sure the parsing adds rows to the df
      # maybe a stop or return false from the parser if no rows found?
      
      query$offset <- nrow(dat)
      if (limit > 0){
        query$limit <- limit - nrow(dat)
      }
    }
    
    colnames(dat) <- fields
    #print(paste0(Sys.time(), " completed"))
    dat
}

fmt_search_txt_to_itemCount <- function(txt){
  httr::content(txt)$itemCount
}

fmt_search_txt_to_df <- function(txt, fields) {
  # Check returned results for common errors
  if (!exists("items", httr::content(txt))){
    stop("Returned results do not contain any content")
  }
  
  #Before continuing to add error handling, let's settle on a pattern.
  
  search_items <- httr::content(txt)$items  
  
  
  # pre-allocated matrix method
  # This method is on the order of 2-3 seconds/5k records which is about how long
  # it takes the HTTP response to happen on a 100Mb/s link when asking for 10 fields
  # optimizing this further will quickly make HTTP the rate limiter. The is.null()
  # check allows for records that do not have the requested field filled in.
  m <- matrix(nrow=length(search_items), ncol=length(fields))
  
  for(i in 1:length(search_items)){
    for(ff in 1:length(fields)){
      if (! is.null(search_items[[i]]$indexTerms[[fields[[ff]]]])){
        #print(paste0("indexes ", i , " ", ff))
        m[i, ff] <- search_items[[i]]$indexTerms[[fields[[ff]]]]
      }
    }
  }
  #print(paste0(Sys.time(), " completed matrix"))
  data.frame(m, stringsAsFactors=FALSE)

  # typing columns here? or higher? Return to debating typing columns from search results
  # because doing this matrix method loses the data types from the json library. Perhaps
  # we should try doing a pre-allocated data frame so we can keep types?

}
