app_get_all_values <- function(self, private, input, output, export) {
  "!DEBUG app_get_all_values"
  url <- private$get_test_snapshot_url(input, output, export, format = "rds")

  tmpfile <- tempfile("shinytest_values", fileext = ".rds")
  req <- httr::GET(url)
  writeBin(req$content, tmpfile)
  on.exit(unlink(tmpfile))

  readRDS(tmpfile)
}
