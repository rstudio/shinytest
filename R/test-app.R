#' Run tests for a Shiny application
#'
#' @param appDir Path to the Shiny application to be tested.
#' @param files Test script(s) to run. The .R extension of the filename is
#'   optional. For example, \code{"mytest"} or \code{c("mytest", "mytest2.R")}.
#'   If \code{NULL} (the default), all scripts in the tests/ directory will be
#'   run.
#' @param quiet Should output be suppressed? This is useful for automated
#'   testing.
#' @param compareImages Should screenshots be compared? It can be useful to
#'   set this to \code{FALSE} when the expected results were taken on a
#'   different platform from the one currently being used to test the
#'   application.
#' @param interactive If there are any differences between current results and
#'   expected results, provide an interactive graphical viewer that shows the
#'   changes and allows the user to accept or reject the changes.
#'
#' @export
testApp <- function(appDir = ".", files = NULL, quiet = FALSE,
  compareImages = TRUE, interactive = base::interactive())
{
  library(shinytest)

  # appDir could be the path to an .Rmd file. If so, make it point to the actual
  # directory.
  if (is_rmd(appDir)) {
    app_filename <- basename(appDir)
    appDir       <- dirname(appDir)
    if (length(dir(appDir, pattern = "\\.Rmd$", ignore.case = TRUE)) > 1) {
      stop("For testing, only one .Rmd file is allowed per directory.")
    }
  } else {
    app_filename <- NULL
    appDir       <- appDir
  }

  testsDir <- file.path(appDir, "tests")

  found_files <- list.files(testsDir, pattern = "\\.[r|R]$")
  if (!is.null(files)) {
    # Strip .R extension from supplied filenames and found filenames
    files_no_ext <- sub("\\.[rR]$", "", files)
    found_files_no_ext <- sub("\\.[rR]$", "", found_files)

    # Keep only specified files
    idx <- match(files_no_ext, found_files_no_ext)

    if (any(is.na(idx))) {
      stop("Test files do not exist: ",
        paste0(files[is.na(idx)], collapse =", ")
      )
    }

    # Keep only specified files
    found_files <- found_files[idx]
  }

  if (length(found_files) == 0) {
    stop("No test scripts found in ", testsDir)
  }

  # Run all the test scripts.
  if (!quiet) {
    message("Running ", appendLF = FALSE)
  }
  lapply(found_files, function(file) {
    # Run in test directory, and pass the (usually relative) path as an option,
    # so that the printed output can print the relative path.
    withr::local_dir(testsDir)
    # Some apps have different behavior if RSTUDIO is present.
    withr::local_envvar(c(RSTUDIO = ""))
    withr::local_options(list(shinytest.app.dir = "appdir"))

    # This will kill any existing Shiny processes launched by shinytest,
    # in case they're using some of the same resources.
    gc()

    env <- new.env(parent = .GlobalEnv)
    if (!quiet) {
      message(file, " ", appendLF = FALSE)
    }
    source(file, local = env)
  })

  gc()

  if (!quiet) message("")  # New line

  # Compare all results
  return(
    snapshotCompare(appDir, quiet = quiet, images = compareImages,
      interactive = interactive)
  )
}


all_testnames <- function(appDir, suffixes = c("-expected", "-current")) {
  # Create a regex string like "(-expected|-current)$"
  pattern <- paste0(
    "(",
    paste0(suffixes, collapse = "|"),
    ")$"
  )

  testnames <- dir(file.path(appDir, "tests"), pattern = pattern)
  testnames <- sub(pattern, "", testnames)
  unique(testnames)
}


validate_testname <- function(appDir, testname) {
  valid_testnames <- all_testnames(appDir)

  if (is.null(testname) || !(testname %in% valid_testnames)) {
    stop('"', testname, '" ',
      'is not a valid testname for the app. Valid names are: "',
      paste(valid_testnames, collapse = '", "'), '".'
    )
  }
}
