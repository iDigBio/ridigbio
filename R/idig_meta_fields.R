idig_meta_fields <- function(type="records"){
  
  # This passes through an empty list to get around idig_POST's requirement that rq be present
  # For full API compatability, the post should be completely empty if the user doesn't specify
  # anything
  query <- list()
  
  view_results <- idig_GET(paste0("meta/fields/", type))
  fmt_metafields_txt_to_list(view_results)
}

fmt_metafields_txt_to_list <- function(txt){
  httr::content(txt)
}