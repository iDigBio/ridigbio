idig_view <- function(uuid, type="records"){
  view_results <- idig_GET(paste("view", type, uuid, sep="/"))
  fmt_view_txt_to_list(view_results)
}

fmt_view_txt_to_list <- function(txt){
  httr::content(txt)
}