test_that("pre-recorded tests still pass", {
  skip_on_cran()
  skip_on_os("windows") # https://github.com/rstudio/shinytest/issues/270

  test_app <- function(x) {
    testApp(test_path(x), compareImages = FALSE, interactive = FALSE, quiet = TRUE)
  }

  expect_pass(test_app("recorded_tests/009-upload"))
  expect_pass(test_app("recorded_tests/041-dynamic-ui"))
  expect_pass(test_app("recorded_tests/app-waitForValue"))
  expect_pass(test_app("recorded_tests/inline-img-src"))

  skip("pre-recorded Rmd tests unstable")
  skip_on_os("linux") # recorded on mac
  expect_pass(test_app("recorded_tests/rmd"))
  expect_pass(test_app("recorded_tests/rmd-prerendered"))
})
