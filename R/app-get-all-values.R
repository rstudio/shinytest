# Note: This queries the server
sd_getAllValues <- function(self, private, input, output, export) {
  self$logEvent("Getting all values")
  "!DEBUG sd_getAllValues"

  url <- private$getTestSnapshotUrl(input, output, export, format = "rds")
  req <- httr_get(url)

  tmpfile <- tempfile()
  on.exit(unlink(tmpfile))
  writeBin(req$content, tmpfile)
  readRDS(tmpfile)
}
