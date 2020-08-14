# Note: This queries the server
sd_getAllValues <- function(self, private, input, output, export) {
  "!DEBUG sd_getAllValues"
  url <- private$getTestSnapshotUrl(input, output, export, format = "rds")

  self$logEvent("Getting all values")
  tmpfile <- tempfile("shinytest_values", fileext = ".rds")
  req <- httr::GET(url)

  if (httr::status_code(req) != 200) {
    cat("Query failed: ------------------\n")
    cat(httr::content(req, "text")), "\n")
    cat("---------------------------------\n")
    stop("Unable to fetch all values from server.")
  }

  writeBin(req$content, tmpfile)
  on.exit(unlink(tmpfile))

  readRDS(tmpfile)
}
