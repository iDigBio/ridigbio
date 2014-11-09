##' Function to query the iDigBio API
##'
##' Currently query needs to be specified as a list. All matching results are
##' returned up to the max_items cap (default 100,000). If more results are 
##' wanted, the max_items can be passed as an option. Limit and offset are
##' availible if manual paging of results is needed though the max_items cap
##' still applies as the item count comes from the results header not the 
##' count of actual records in the limit/offset window.
##' @title Basic searching of the iDigBio API
##' @param query a list containing the information to be searched in iDigBio
##' @param fields list of fields that will be contained in the data.frame
##' @param max_items maximum number of items to attempt to retrieve
##' @param limit maximum number of records to request
##' @param offset where to start the search
##' @param ... additional parameters (currently not in use)
##' @return a data frame
##' @author Francois Michonneau
##' @examples
##' \dontrun{
##' idig_search(query=list(genus="acer"))
##' }
##' @export
idig_search <- function(idig_query, fields=c("dwc:catalogNumber", "dwc:genus",
                                        "dwc:specificEpithet", "dwc:decimalLatitude",
                                        "dwc:decimalLongitude"), 
                        max_items=100000, limit=0, offset=0, ...) {
  
    stopifnot(inherits(idig_query, "list") && length(idig_query) > 0)
    query <- list(rq=idig_query, offset=offset)
    if (limit > 0){
      query$limit <- limit
    }else{
      query$limit <- 5000 # as of 11/9/14 this is max records allowed at once
    }
   
    dat <- data.frame()
    item_count <- 1 # trick to get inside loop first time
    
    # loop until we either have all results or all results the user wants
    while (nrow(dat) < item_count){# && (limit == 0 || nrow(dat) > limit)){
      search_results <- idig_POST("search", body=query)
      
      # Slight possibility of the number of items changing as we go due to inserts/
      # deletes at iDigBio, put this inside the loop to keep it current
      item_count <- fmt_search_txt_to_itemCount(search_results)
      if (item_count > max_items){
        stop(paste0("Search would return more than ", max_items, 
                    " results. See max_items argument."))
      }
      
      if (nrow(dat) == 0){
        dat <- fmt_search_txt_to_df(search_results, fields)
      } else {
        dat <- do.call(rbind, list(dat, fmt_search_txt_to_df(search_results, fields)))
      }
      
      query$offset <- nrow(dat)
      #if (limit > 0){
      #  query$limit <- nrow(dat) %% limit
      #}
    }
    
    dat
}

fmt_search_txt_to_itemCount <- function(txt){
  httr::content(txt)$itemCount
}

fmt_search_txt_to_df <- function(txt, fields) {
  search_items <- httr::content(txt)$items
  lst_data_full <- lapply(search_items, function(x) x$data)
  lst_data <- lapply(lst_data_full, function(x, keep=fields) {
    unlist(x[keep])[keep]
  })
  dat <- data.frame(do.call("rbind", lst_data))
  names(dat) <- fields
  dat
}

