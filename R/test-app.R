#' Run tests for a Shiny application
#'
#' @param appDir Path to the Shiny application to be tested.
#' @param testnames Test script(s) to run. The .R extension of the filename is
#'   optional. For example, \code{"mytest"} or \code{c("mytest", "mytest2.R")}.
#'   If \code{NULL} (the default), all scripts in the tests/ directory will be
#'   run.
#' @param quiet Should output be suppressed? This is useful for automated
#'   testing.
#' @param compareImages Should screenshots be compared? It can be useful to set
#'   this to \code{FALSE} when the expected results were taken on a different
#'   platform from the one currently being used to test the application.
#' @param normalizeContent This will pre-process the pages content to
#'   canonicalize it (alphabetical order), so changes of JSON objects order will
#'   no longer be considered as differences. It can be useful to set
#'   this to \code{TRUE} when the content of snapshot is quite heavy
#'   (which means that the snapshooted page may be loaded hieratically).
#' @param ignoreContent This will pre-process the pages content to ignore text
#'   matching these patterns (using gsub to replace it by arbitrary value).
#' @param ignoreElement This will pre-process the pages elements to remove those
#'   matching these patterns.
#' @param interactive If there are any differences between current results and
#'   expected results, provide an interactive graphical viewer that shows the
#'   changes and allows the user to accept or reject the changes.
#'
#'
#' @seealso \code{\link{snapshotCompare}} and \code{\link{snapshotUpdate}} if
#'   you want to compare or update snapshots after testing. In most cases, the
#'   user is prompted to do these tasks interactively, but there are also times
#'   where it is useful to call these functions from the console.
#'
#' @export
testApp <- function(appDir = ".", testnames = NULL, quiet = FALSE,
  compareImages = TRUE, normalizeContent = FALSE, ignoreElement = NULL, ignoreContent = NULL, interactive = base::interactive())
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

  found_testnames <- list.files(testsDir, pattern = "\\.[r|R]$")
  found_testnames_no_ext <- sub("\\.[rR]$", "", found_testnames)
  if (!is.null(testnames)) {
    # Strip .R extension from supplied filenames
    testnames_no_ext <- sub("\\.[rR]$", "", testnames)

    # Keep only specified files
    idx <- match(testnames_no_ext, found_testnames_no_ext)

    if (any(is.na(idx))) {
      stop("Test scripts do not exist: ",
        paste0(testnames[is.na(idx)], collapse =", ")
      )
    }

    # Keep only specified files
    found_testnames <- found_testnames[idx]
    found_testnames_no_ext <- found_testnames_no_ext[idx]
  }

  if (length(found_testnames) == 0) {
    stop("No test scripts found in ", testsDir)
  }

  # Run all the test scripts.
  if (!quiet) {
    message("Running ", appendLF = FALSE)
  }
  lapply(found_testnames, function(testname) {
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
      message(testname, " ", appendLF = FALSE)
    }
    source(testname, local = env)
  })

  gc()

  if (!quiet) message("")  # New line

  # Compare all results
  return(
    snapshotCompare(appDir, testnames = found_testnames_no_ext, quiet = quiet,
      images = compareImages, normalize_data = normalizeContent, ignore_keys = ignoreElement, ignore_text = ignoreContent, interactive = interactive)
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
