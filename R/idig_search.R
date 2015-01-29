##' Function to query the iDigBio API
##'
##' Currently the query needs to be specified as a list. All matching results are
##' returned up to the max_items cap (default 100,000). If more results are 
##' wanted, the max_items can be passed as an option. Limit and offset are
##' availible if manual paging of results is needed though the max_items cap
##' still applies as the item count comes from the results header not the 
##' count of actual records in the limit/offset window.
##' @title Basic searching of the iDigBio API
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
##' idig_search(query=list(genus="acer"))
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


idig_search <- function(idig_query, fields=DEFAULT_FIELDS, max_items=100000, limit=0, 
                        offset=0, ...) {
  # Validate inputs
  if (!(inherits(idig_query, "list"))) { stop("idig_query is not a list") }
      
  if (!(length(idig_query) > 0)) { stop("idig_query must not be 0 length") }
  
  if (!(fields == "all" ) && !(inherits(fields, "character"))) {
    stop("Invalid value for fields")
  }

  
    # Construct body of request to API
    query <- list(rq=idig_query, offset=offset)
    
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
        dat <- plyr::rbind.fill(dat, fmt_search_txt_to_df(search_results, fields))
      }
      # Need to add a safety here to make sure the parsing adds rows to the df
      # maybe a stop or return false from the parser if no rows found?
      
      query$offset <- nrow(dat)
      if (limit > 0){
        query$limit <- limit - nrow(dat)
      }
    }
    
    colnames(dat) <- fields
    dat
}

fmt_search_txt_to_itemCount <- function(txt){
  httr::content(txt)$itemCount
}

fmt_search_txt_to_df <- function(txt, fields) {
  # What to do if the number of fields in results doesn't match? rbind isn't going to work.
  # Would like to leave behavior controlled by the API rather than having to pull lists and 
  # match them up here on the client side. But with paging, the cols returned may vary through
  # the pages of records, can't know the full width of the df by inspecting returned results,
  # will have to pre-calculate the width. Is there an R way of appending rows that will
  # do so based on column name and insert cols of NA if a new one is inserted? Plyr 
  # rbind.fill() does what we want.

  # Check returned results for common errors
  if (!exists("items", httr::content(txt))){
    stop("Returned results do not contain any content")
  }
  
  #Before continuing to add error handling, let's settle on a pattern.
  
  search_items <- httr::content(txt)$items  
  
  
  # pre-allocate matrix
  m <- matrix(nrow=length(search_items), ncol=length(fields))
  
  for(i in 1:length(search_items)){
    for(ff in 1:length(fields)){
      if (! is.null(search_items[[i]]$indexTerms[[fields[[ff]]]])){
        #print(paste0("indexes ", i , " ", ff))
        m[i, ff] <- search_items[[i]]$indexTerms[[fields[[ff]]]]
      }
    }
  }
  data.frame(m, stringsAsFactors=FALSE)  

#  # Add all indexTerms to df if indexTerms exists
#  lst_index_terms_full <- lapply(search_items, function(x) x$indexTerms)
#  
#  dats <- lapply(lst_index_terms_full, function(x) {
#    # Dataframes can not contain lists and these are returned as lists,
#    # this must be manually maintained in alignment with what the API returns.
#    # The effect of not doing this is a bunch of columns with the contents of
#    # lists as the names. (This behavior is handy for the geopoint field BTW.)
#    x$flags <- NULL
#    x$recordids <- NULL
#    x$mediarecords <- NULL
#    data.frame(x, stringsAsFactors=FALSE) # not doing factors here is a 2x speedup
#    })
#  
#  # This is pretty fast but the lapply above is pretty slow (2-3 secs below
#  # vs 17-19 sec above for 5000 records)
#  dat <- plyr::rbind.fill(dats)


# lapply(search_items, function(x){x$indexTerms[fields]})


  # We didn't type columns, looks like the JSON reader did that for us which is probably
  # ok since the API returns typed JSON. Everything dwc: is quoted as char
  
  # Add factors - on second thought, factors are not great unless there's a lot of 
  # repetition in the data and perhaps we should let people factor their own columns
  
  
  # Then add any data terms if data exists - After discussion w/ Alex, don't
  # work with raw data, only indexed terms and make effort to make what's indexed
  # complete and useful.
  

}

