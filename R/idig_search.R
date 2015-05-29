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

idig_search <- function(type="records", mq=FALSE, rq=FALSE, fields=FALSE, max_items=100000, 
                        limit=0, offset=0, sort=FALSE) {
  
  # Construct body of request to API
  # Force sorting by UUID so that paging will be reliable ie the 25,000th item 
  # is always the 25,000th item even when requesting the 6th page.
  query <- list(offset=offset, sort=c("uuid"))
  
  if (!inherits(rq, "logical")) {
    query$rq=rq 
  }
  
  if (!inherits(mq, "logical")) {
    query$mq=mq 
  }
  
  # Adjust fields to request from the API
  field_lists <- build_field_lists(fields, type)
  fields <- field_lists$fields
  query <- append(query, field_lists$query)
  
#  if (!is.null(field_lists$rq_fields)) { 
#    query$fields <- field_lists$rq_fields
#  }
#  if (!is.null(field_lists$rq_fields_exclude)) { 
#    query$fields <- field_lists$rq_fields_exclude
#  }
  
  if (limit > 0){
    query$limit <- limit
  }else{
    query$limit <- max_items # effectivly use iDigBio's max page size
  }
  
  # Default sort by UUID so paging and offset give reproducable results. This
  # has been benchmarked and appears make things ~20% slower on a gigabit 
  # connection: 66s for 100,000 limit
  if (inherits(sort, "character") && length(sort) > 0 ) {
    query$sort <- c(sort, "uuid")
  } else {
    query$sort <- c("uuid")
  }
  
  # tricks to get inside loop first time
  dat <- data.frame()
  item_count <- 1
  
  # loop until we either have all results or all results the user wants
  while (nrow(dat) < item_count && (limit == 0 || nrow(dat) < limit)){
    search_results <- idig_POST(paste0("search/", type), body=query)
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
  
  field_indexes <- idig_field_indexes(fields)
  colnames(dat) <- names(field_indexes)
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
  
  # Translate list of fields into a list of indexes, see doc on this method.
  field_indexes <- idig_field_indexes(fields)
  l_field_indexes <- length(field_indexes)
  
  m <- matrix(nrow=length(search_items), ncol=length(field_indexes))
  i <- 1
  while(i <= length(search_items)){
    flat <- list("indexTerms"=unlist(search_items[[i]][["indexTerms"]]),
                 "data"=unlist(search_items[[i]][["data"]]))
    for(f in 1:l_field_indexes){
      # Silently ignore the case when the returned data has a field unset
      try(m[i, f] <- flat[[field_indexes[[f]]]], silent=TRUE)
    }
    i <- i + 1
  }
  
  data.frame(m, stringsAsFactors=FALSE)
  
}


##' Build fields and fields_exclude for queries.
##'
##' Given the desired fields to be returned, intelligently add an exclusion for
##' the data array if warranted and handle the "all" keyword. Function not 
##' exported.
##' @param fields character vector of fields user wants returned
##' @param type type of records to get fields for
##' @return list list with fields key for df fields and query key for parameters
##' to be merged with the query sent
build_field_lists <- function(fields, type) {
  ret <- list()
  ret$query = list()
  # Here Alex says to eat "all" rather than pass it through to the API
  if (inherits(fields, "character") && fields != "all" && length(fields) > 0 ){
    ret$fields <- fields
    ret$query$fields <- fields
  } else {
    # When a field parameter is passed then the un-requested raw data is 
    # already dropped because it's not a requested field. When no field 
    # parameter is passed then drop it manually since by default we will not 
    # return data fields and this saves significant transfer.
    ret$query$fields_exclude <- "data"
    # Load up all fields possible
    ret$fields <- names(idig_meta_fields(type=type, subset="indexed"))
  }
  ret
}