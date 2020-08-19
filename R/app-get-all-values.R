# Note: This queries the server

sd_getAllValues <- function(self, private, input, output, export,
                            exclude=NULL, stop_on_error=TRUE) {
  self$logEvent("Getting all values")
  "!DEBUG sd_getAllValues"

  url <- private$getTestSnapshotUrl(input, output, export, format = "rds")
  req <- httr_get(url, stop_on_error)

  tmpfile <- tempfile()
  on.exit(unlink(tmpfile))
  writeBin(req$content, tmpfile)
  rObj <- readRDS(tmpfile)

  # Remove any items specified in ignore
  if(length(exclude)>0)
  {
    dropItems <- function(l, i) l[! names(l) %in% i]

    rObj$input <- dropItems(rObj$input, exclude)
    rObj$output <- dropItems(rObj$output, exclude)
    rObj$export <- dropItems(rObj$export, exclude)
  }

  rObj
}
