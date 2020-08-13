test_that("pre-recorded tests still pass", {
  skip_on_cran()

  test_app <- function(x) {
    testApp(test_path(x), compareImages = FALSE, interactive = FALSE, quiet = TRUE)
  }

  expect_pass(test_app("recorded_tests/041-dynamic-ui"))
  expect_pass(test_app("recorded_tests/inline-img-src"))

  skip_on_os("windows")
  expect_pass(test_app("recorded_tests/009-upload")) # file size different
  expect_pass(test_app("recorded_tests/app-waitForValue")) # plot coords different

  skip_on_os("linux") # recorded on mac
  skip_on_ci() # fails for unknown reasons currently
  expect_pass(test_app("recorded_tests/rmd"))
  expect_pass(test_app("recorded_tests/rmd-prerendered"))
})
