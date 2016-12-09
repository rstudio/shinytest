#' Run tests for a Shiny application
#'
#' @param appDir Path to the Shiny application to be tested.
#'
#' @export
testApp <- function(appDir) {
  testsDir <- file.path(appDir, "tests")
  r_files <- list.files(testsDir, pattern = "\\.[r|R]$")

  res <- lapply(r_files, function(file) {
    # Run in test directory, and pass the (usually relative) path as an option,
    # so that the printed output can print the relative path.
    withr::with_dir(testsDir, {
      withr::with_options(list(shinytest.tests.dir = testsDir), {
        env <- new.env(parent = .GlobalEnv)
        message("====== Running ", file, " ======")
        source(file, local = env)
      })
    })
  })
}
