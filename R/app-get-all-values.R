sd_getAllValues <- function(self, private, input, output, export) {
  "!DEBUG sd_getAllValues"
  url <- private$getTestSnapshotUrl(input, output, export, format = "rds")

  self$logEvent("Getting all values")
  tmpfile <- tempfile("shinytest_values", fileext = ".rds")
  req <- httr::GET(url)
  writeBin(req$content, tmpfile)
  on.exit(unlink(tmpfile))

  readRDS(tmpfile)
}
