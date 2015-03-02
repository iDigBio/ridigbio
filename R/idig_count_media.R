idig_count_media <- function(rq=FALSE, mq=FALSE){
  
  # This passes through an empty list to get around idig_POST's requirement that rq be present
  # For full API compatability, the post should be completely empty if the user doesn't specify
  # anything
  query <- list()
  
  if (inherits(rq, "list") && length(rq) > 0){
    query$rq <- rq
  }
  
  if (inherits(mq, "list") && length(mq) > 0){
    query$mq <- mq
  }
  
  view_results <- idig_POST("summary/count/media", body=query)
  fmt_topmedia_txt_to_num(view_results)
}

fmt_topmedia_txt_to_num <- function(txt){
  httr::content(txt)[["itemCount"]]
}