test_that("pre-recorded tests still pass", {
  skip_on_cran()
  skip_on_os("windows") # https://github.com/rstudio/shinytest/issues/270
  skip_if_not_installed("shiny", "1.7.4")

  sleep_on_ci()

  test_app <- function(...) {
    testApp(test_path(...), compareImages = FALSE, interactive = FALSE, quiet = TRUE)
  }

  expect_recorded_app <- function(subpath) {
    expect_pass(test_app("recorded_tests", subpath))
    sleep_on_ci()
  }

  expect_recorded_app("009-upload")
  expect_recorded_app("041-dynamic-ui")
  expect_recorded_app("app-waitForValue")
  expect_recorded_app("inline-img-src")

  skip_on_os("linux") # recorded on mac
  skip("testing Rmds is very fragile")
  expect_recorded_app("rmd")
  expect_recorded_app("rmd-prerendered")
})
