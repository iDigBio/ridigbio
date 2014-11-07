##' Function to query the iDigBio API
##'
##' Currently query needs to be specified as a list
##' @title Basic searching of the iDigBio API
##' @param query a list containing the information to be searched in iDigBio
##' @param limit maximum number of records to return
##' @param offset where to search the search
##' @param fields list of fields that will be contained in the data.frame
##' @param ... additional parameters (currently not in use)
##' @return a data frame
##' @author Francois Michonneau
##' @examples
##' \dontrun{
##' idig_search(query=list(genus="acer"), limit=10)
##' }
##' @export
idig_search <- function(query, limit=100, offset=0, fields=c("dwc:catalogNumber", "dwc:genus",
                                   "dwc:specificEpithet", "dwc:decimalLatitude",
                                   "dwc:decimalLongitude"), ...) {
    stopifnot(inherits(query, "list"))
    query <- list(limit=limit, offset=offset, rq=query)

    max_items <- 7
    
    items <- -1
    item_count <- 0
    dat <- FALSE    
    
    while (items < item_count && items < max_items){
      search_results <- idig_POST("search", body=query)
      
      # Slight possibility of the number of items changing as we go due to inserts/
      # deletes at iDigBio, keep it current
      item_count <- fmt_search_txt_to_itemCount(search_results)
      
      if (inherits(dat, "logical")){
        dat <- fmt_search_txt_to_df(search_results, fields)
#      } else {
#        dat <- do.call(rbind, list(df, fmt_search_txt_to_df(search_results, fields)))
      }
      items <- items + nrow(dat)
      query$offset <- items
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

