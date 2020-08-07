#' Migrate legacy \pkg{shinytest} files to new test directory structure
#'
#' This function migrates the old-style directory structure used by
#' \pkg{shinytest} (versions 1.3.1 and below) to new test directory structure
#' used in shinytest 1.4.0 and above.
#'
#' Before \pkg{shinytest} 1.4.0, the shinytest scripts and results were put in a
#' subdirectory of the application named `tests/`. As of \pkg{shinytest} 1.4.0,
#' the tests are put in `tests/shinytest/`, so that it works with the
#' `runTests()` function shiny package (added in \pkg{shiny} 1.5.0).
#'
#' With \pkg{shinytest} 1.3.1 and below, the tests/ subdirectory of the
#' application was used specifically for \pkg{shinytest}, and could not be used
#' for other types of tests. So the directory structure would look like this:
#'
#' ```
#' appdir/
#'  `- tests
#'      `- mytest.R
#' ```
#'
#' In Shiny 1.5.0, the `shiny::runTests()` function was added, and it will run
#' test scripts tests/ subdirectory of the application. This makes it possible
#' to use other testing systems in addition to shinytest. \pkg{shinytest} 1.4.0
#' is designed to work with this new directory structure. The directory
#' structure looks something like this:
#'
#' ```
#' appdir/
#'  |- R
#'  |- tests
#'      |- shinytest.R
#'      |- shinytest
#'      |   `- mytest.R
#'      |- testthat.R
#'      `- testthat
#'          `- test-script.R
#' ```
#'
#' This allows for tests using the \pkg{shinytest} package as well as other
#' testing tools, such as the `shiny::testServer()` function, which can be used
#' for testing module and server logic, and for unit tests of functions in an R/
#' subdirectory.
#'
#' In \pkg{shinytest} 1.4.0 and above, it defaults to creating the new directory
#' structure.
#'
#' @param appdir A directory containing a Shiny application.
#' @param dryrun If `TRUE`, print out the changes that would be made, but don't
#'   actually do them.
#'
#' @export
migrateShinytestDir <- function(appdir, dryrun = FALSE) {
  tests_dir <- file.path(appdir, "tests")
  if (!file.exists(tests_dir)) {
    message(tests_dir, " does not exist; doing nothing.")
    return(invisible(FALSE))
  }

  shinytest_dir <- file.path(tests_dir, "shinytest")
  if (file.exists(shinytest_dir)) {
    message(shinytest_dir, " exists; doing nothing.")
    return(invisible(FALSE))
  }

  message("Moving tests from ", tests_dir, " to ", shinytest_dir)
  if (!dryrun) {
    shinytest_temp_dir <- file.path(appdir, "shinytest")
    file.rename(tests_dir, shinytest_temp_dir)
    dir.create(tests_dir)
    invisible(file.rename(shinytest_temp_dir, shinytest_dir))
  }

  update_test_script <- function(file) {
    message("Updating test script ", file)
    if (!dryrun) {
      txt <- readLines(file)
      txt <- sub('ShinyDriver$new("../', 'ShinyDriver$new("../../', txt, fixed = TRUE)
      writeLines(txt, file)
    }
  }

  if (dryrun) {
    script_files <- list.files(tests_dir, pattern = "\\.R", full.names = TRUE)
    script_files <- file.path(dirname(script_files), "shinytest", basename(script_files))
  } else {
    script_files <- list.files(shinytest_dir, pattern = "\\.R", full.names = TRUE)
  }
  lapply(script_files, update_test_script)

  # Create tests/shinytest.R
  shinytest_script <- file.path(tests_dir, "shinytest.R")
  if (!file.exists(shinytest_script)) {
    message("Creating ", shinytest_script)
    if (!dryrun) {
      writeLines(
        c('library(shinytest)', 'shinytest::testApp("../")'),
        shinytest_script
      )
    }
  }

  invisible(TRUE)
}
