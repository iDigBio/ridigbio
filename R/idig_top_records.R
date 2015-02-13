idig_toprecords <- function(idig_query=FALSE, fields=FALSE, count=0){
  
  # This passes through an empty list to get around idig_POST's requirement that rq be present
  # For full API compatability, the post should be completely empty if the user doesn't specify
  # anything
  query <- list()
  
  if (idig_query){
    query$rq <- idig_query
  }
  
  if (length(fields) > 1 && inherits(fields, "character")){
    query$fields <- fields
  }

  if (count > 0){
    query$count <- count
  }
  
  view_results <- idig_POST("summary/top/basic", body=query)
  fmt_topbasic_txt_to_list(view_results)
}

fmt_topbasic_txt_to_list <- function(txt){
  httr::content(txt)
}