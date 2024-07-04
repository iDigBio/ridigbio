##' Function to query the iDigBio API for media records
##'
##' Also see \code{\link{idig_search_records}} for the full examples of all the
##' parameters related to searching iDigBio.
##'
##' Wraps \code{\link{idig_search}} to provide defaults specific to searching
##' media records. Using this function instead of \code{\link{idig_search}}
##' directly is recommened. Record queries and media queries objects are allowed
##' (rq and mq parameters) and media records returned will match the
##' requirements of both.
##'
##' This function defaults to returning all indexed media record fields.
##' @title Searching of iDigBio media records
##' @param mq iDigBio media query in nested list format
##' @param rq iDigBio record query in nested list format
##' @param fields vector of fields that will be contained in the data.frame,
##' defaults to "all" which is all indexed fields
##' @param max_items maximum number of results allowed to be retrieved (fail
##' -safe)
##' @param limit maximum number of results returned
##' @param offset number of results to skip before returning results
##' @param sort vector of fields to use for sorting, UUID is always appended to
##' make paging safe
##' @param ... additional parameters
##' @return A data frame with fields requested or the following default fields: 
##' \itemize{  
##' \item{[accessuri](https://ac.tdwg.org/termlist/#ac_accessURI) }  
##' \item{datemodified: Date last modified, which is assigned by iDigBio.}   
##' \item{dqs: Data quality score assigned by iDigBio.}   
##' \item{etag: Tag assigned by iDigBio.}         
##' \item{flags: Data quality flag assigned by iDigBio.}          
##' \item{[format](http://purl.org/dc/terms/format) }          
##' \item{hasSpecimen: TRUE or FALSE, indicates if there is an associated record for this media.}          
##' \item{[licenselogourl](https://ac.tdwg.org/termlist/#ac_licenseLogoURL)}          
##' \item{mediatype: Media object type.}          
##' \item{[modified](http://purl.org/dc/terms/modified)}          
##' \item{recordids: List of UUID for associated records.}          
##' \item{records: UUID for the associated record.}          
##' \item{recordset: Record set ID assigned by iDigBio.}          
##' \item{[rights](http://purl.org/dc/terms/rights)}          
##' \item{[tag](http://rs.tdwg.org/ac/terms/tag)}           
##' \item{[type](http://purl.org/dc/terms/type)}          
##' \item{uuid: Unique identifier assigned by iDigBio.}          
##' \item{version: Media record version assigned by iDigBio.}          
##' \item{[webstatement](https://developer.adobe.com/xmp/docs/XMPNamespaces/xmpRights/)}          
##' \item{xpixels: As defined by EXIF, x dimension in pixel.}          
##' \item{ypixels: As defined by EXIF,y dimension in pixels.}        
##' }
##' 
##' @author Matthew Collins
##' @examples
##' \dontrun{
##' # Searching for media using a query on related specimen information - first
##' # 10 media records with image URIs related to a specimen in the genus Acer:
##' df <- idig_search_media(rq=list(genus="acer"),
##'                         mq=list("data.ac:accessURI"=list("type"="exists")),
##'                         fields=c("uuid","data.ac:accessURI"), limit=10)
##' }
##' @export
##'
idig_search_media <- function(mq = FALSE, rq = FALSE, fields = FALSE,
                              max_items = 100000, limit = 0, offset = 0, sort = FALSE,
                              ...) {
  DEFAULT_FIELDS <- "all"

  if (!(length(rq) > 0) && !(length(rq) > 0)) {
    stop("mq or rq must not be 0 length")
  }

  if (inherits(fields, "logical") && fields == FALSE) {
    fields <- DEFAULT_FIELDS
  }

  fields_eq_all <- (length(fields) == 1 && fields == "all")
  fields_are_char <- inherits(fields, "character")
  if (!fields_eq_all && !fields_are_char) {
    stop("Invalid value for fields")
  }

  idig_search(
    type = "media", mq = mq, rq = rq, fields = fields, max_items = max_items,
    limit = limit, offset = offset, sort = sort, ...
  )
}
