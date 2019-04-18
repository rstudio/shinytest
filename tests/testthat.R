library(testthat)
library(shinytest)

if (Sys.getenv("NOT_CRAN", "") != "" || Sys.getenv("CI", "") != "") {
  if (!dependenciesInstalled()) installDependencies()
  message("Using phantom.js from ", shinytest:::find_phantom(), "\n")
  # The default RNG kind changed in R > 3.6...the recorded tests
  # currently rely on randomness and are currently expecting
  # the default RNG kind from R 3.5
  # CRAN has suggested this as workaround for random tests
  suppressWarnings(RNGversion("3.5.0"))
  test_check("shinytest")
}
