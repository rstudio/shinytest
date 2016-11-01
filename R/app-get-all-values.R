app_get_all_values <- function(self, private, inputs, outputs, exports) {
  "!DEBUG app_get_all_values"
  url <- private$get_test_endpoint_url(inputs, outputs, exports)

  tmpfile <- tempfile("shinytest_values", fileext = ".rds")
  req <- httr::GET(url)
  writeBin(req$content, tmpfile)
  on.exit(unlink(tmpfile))

  readRDS(tmpfile)
}
