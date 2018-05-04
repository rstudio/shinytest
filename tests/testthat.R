library(testthat)
library(shinytest)

if (Sys.getenv("NOT_CRAN", "") != "" || Sys.getenv("CI", "") != "") {
  if (!dependenciesInstalled()) installDependencies()
  message("Using phantom.js from ", shinytest:::find_phantom(), "\n")
  test_check("shinytest")
}
