#' Run tests for a Shiny application
#'
#' @param appDir Path to the Shiny application to be tested.
#' @param files Test script(s) to run. For example, \code{"mytest.R"} or
#'   \code{c("mytest.R", "mytest2.R")}. If \code{NULL} (the default), all
#'   scripts in the tests/ directory will be run.
#' @param quiet Should output be suppressed? This is useful for automated
#'   testing.
#'
#' @export
testApp <- function(appDir = ".", files = NULL, quiet = FALSE) {
  testsDir <- file.path(appDir, "tests")

  r_files <- list.files(testsDir, pattern = "\\.[r|R]$")
  if (!is.null(files)) {
    # Keep only specified files
    idx <- match(files, r_files)

    if (any(is.na(idx))) {
      stop("Test files do not exist: ",
        paste0(files[is.na(idx)], collapse =", ")
      )
    }

    # Drop duplicates
    r_files <- unique(files)
  }

  # Run all the test scripts.
  if (!quiet) {
    message("Running ", appendLF = FALSE)
  }
  lapply(r_files, function(file) {
    name <- sub("\\.[rR]$", "", file)

    # Run in test directory, and pass the (usually relative) path as an option,
    # so that the printed output can print the relative path.
    withr::with_dir(testsDir, {
      withr::with_options(list(shinytest.app.dir = appDir), {
        env <- new.env(parent = .GlobalEnv)
        if (!quiet) {
          message(file, " ", appendLF = FALSE)
        }
        source(file, local = env)
      })
    })
  })

  if (!quiet) message("")  # New line

  # Compare all results
  results <- lapply(r_files, function(file) {
    name <- sub("\\.[rR]$", "", file)
    if (!quiet) {
      message("====== Comparing ", name, " ======")
    }
    snapshotCompare(appDir, name, quiet = quiet)
  })

  invisible(list(
    appDir = appDir,
    results = results
  ))
}
