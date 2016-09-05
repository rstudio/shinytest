library(testthat)
library(shinytest)

if (Sys.getenv("NOT_CRAN", "") != "" ||
    Sys.getenv("CI", "") != "") {
  test_check("shinytest")
}
