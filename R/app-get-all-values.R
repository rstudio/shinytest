app_get_all_values <- function(self, private) {
  "!DEBUG app_get_all_values"
  url <- paste0(private$shiny_test_url, "&inputs=1&outputs=1&exports=1")

  tmpfile <- tempfile("shinytest_values", fileext = ".rds")
  req <- httr::GET(url)
  writeBin(req$content, tmpfile)
  on.exit(unlink(tmpfile))

  readRDS(tmpfile)
}
