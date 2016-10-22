library(testthat)
library(shinytest)

if (Sys.getenv("NOT_CRAN", "") != "" || Sys.getenv("CI", "") != "") {
  if (is.null(shinytest:::find_phantom())) webdriver::install_phantomjs()
  message("Using phantom.js from ", shinytest:::find_phantom(), "\n")
  test_check("shinytest")
}
