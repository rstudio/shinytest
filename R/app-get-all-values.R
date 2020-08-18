# Note: This queries the server

sd_getAllValues <- function(self, private, input, output, export,
                            stop_on_error=TRUE) {
  self$logEvent("Getting all values")
  "!DEBUG sd_getAllValues"

  url <- private$getTestSnapshotUrl(input, output, export, format = "rds")
  req <- httr_get(url, stop_on_error)

  tmpfile <- tempfile()
  on.exit(unlink(tmpfile))
  writeBin(req$content, tmpfile)
  readRDS(tmpfile)
}
