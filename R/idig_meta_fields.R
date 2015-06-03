##' @export
idig_meta_fields <- function(type="records", subset=FALSE, ...){
  # This passes through an empty list to get around idig_POST's requirement that rq be present
  # For full API compatability, the post should be completely empty if the user doesn't specify
  # anything
  query <- list()

  view_results <- idig_GET(paste0("meta/fields/", type), ...)

  if (subset == "indexed"){
    fmt_metafields_txt_to_indexed(view_results)
  }else if (subset == "raw"){
    fmt_metafields_txt_to_raw(view_results)
  }else{
    fmt_metafields_txt_to_list(view_results)
  }

}

fmt_metafields_txt_to_indexed <- function(txt){
  f <- httr::content(txt)
  f[-match("data", names(f))]
}

fmt_metafields_txt_to_raw <- function(txt){
  httr::content(txt)[["data"]]
}

fmt_metafields_txt_to_list <- function(txt){
  httr::content(txt)
}
