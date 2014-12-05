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

idig_search <- function(idig_query, fields=c("dwc:catalogNumber", "dwc:genus",
                                        "dwc:specificEpithet", "dwc:decimalLatitude",
                                        "dwc:decimalLongitude"), 
                        max_items=100000, limit=0, offset=0, ...) {
  
    stopifnot(inherits(idig_query, "list") && length(idig_query) > 0)
    
    query <- list(rq=idig_query, offset=offset)
    if (limit > 0){
      query$limit <- limit
    }else{
      query$limit <- max_items # effectivly use iDigBio's max page size
    }
   
    dat <- data.frame()
    item_count <- 1 # trick to get inside loop first time

    # loop until we either have all results or all results the user wants
    while (nrow(dat) < item_count && (limit == 0 || nrow(dat) < limit)){
      search_results <- idig_POST("search", body=query)
      
      # Slight possibility of the number of items changing as we go due to inserts/
      # deletes at iDigBio, put this inside the loop to keep it current
      item_count <- fmt_search_txt_to_itemCount(search_results)
      if (item_count > max_items){
        stop(paste0("Search would return more than ", max_items, 
                    " results. See max_items argument."))
      }
      
      if (nrow(dat) == 0){
        dat <- fmt_search_txt_to_df(search_results)
      } else {
        dat <- plyr::rbind.fill(dat, fmt_search_txt_to_df(search_results))
        #dat <- do.call(rbind, list(dat, fmt_search_txt_to_df(search_results, fields)))
      }
      
      query$offset <- nrow(dat)
      if (limit > 0){
        query$limit <- limit - nrow(dat)
      }
    }
    
    dat
}

fmt_search_txt_to_itemCount <- function(txt){
  httr::content(txt)$itemCount
}

fmt_search_txt_to_df <- function(txt) {
  # What to do if the number of fields in results doesn't match? rbind isn't going to work.
  # Would like to leave behavior controlled by the API rather than having to pull lists and 
  # match them up here on the client side. But with paging, the cols returned may vary through
  # the pages of records, can't know the full width of the df by inspecting returned results,
  # will have to pre-calculate the width. Is there an R way of appending rows that will
  # do so based on column name and insert cols of NA if a new one is inserted? Plyr 
  # rbind.fill() does what we want.

  search_items <- httr::content(txt)$items  
  
  # Add all indexTerms to df if indexTerms exists
  lst_index_terms_full <- lapply(search_items, function(x) x$indexTerms)
  dats <- lapply(lst_index_terms_full, function(x) {
    # Dataframes can not contain lists and these are returned as lists,
    # this must be manually maintained in alignment with what the API returns.
    # The effect of not doing this is a bunch of columns with the contents of
    # lists as the names. (This behavior is handy for the geopoint field BTW.)
    x$flags <- NULL
    x$recordids <- NULL
    x$mediarecords <- NULL
    data.frame(x, stringsAsFactors=FALSE) # not doing factors here is a 2x speedup
    })
  
  # This is pretty fast but the lapply above is pretty slow (2-3 secs below
  # vs 17-19 sec above for 5000 records)
  dat <- plyr::rbind.fill(dats)
  
  # We didn't type columns, looks like the JSON reader did that for us which is probably
  # ok since the API returns typed JSON. Everything dwc: is quoted as char
  
  # Add factors - on second thought, factors are not great unless there's a lot of 
  # repetition in the data and perhaps we should let people factor their own columns
  
  
  # Then add any data terms if data exists
  
  #lst_data_full <- lapply(search_items, function(x) x$data)
  #lst_data <- lapply(lst_data_full, function(x, keep=fields) {
  #  unlist(x[keep])[keep]
  #})
  #dat <- data.frame(do.call("rbind", lst_data))
  #names(dat) <- fields
  
  dat  

}

