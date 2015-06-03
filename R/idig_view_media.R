idig_view_media <- function(uuid){
  view_results <- idig_GET(paste0("view/media/", uuid), ...)
  fmt_view_txt_to_list(view_results)
}

fmt_view_txt_to_list <- function(txt){
  httr::content(txt)
}
