# Note: This queries the server
sd_getAllValues <- function(self, private, input, output, export) {
  "!DEBUG sd_getAllValues"
  url <- private$getTestSnapshotUrl(input, output, export, format = "rds")

  self$logEvent("Getting all values")
  tmpfile <- tempfile("shinytest_values", fileext = ".rds")
  req <- httr::GET(url)
  if (req$status_code != 200) {
    stop("Unable to fetch all values from server. Is target app running with options(shiny.testmode=TRUE?)")
  }

  writeBin(req$content, tmpfile)
  on.exit(unlink(tmpfile))

  readRDS(tmpfile)
}
