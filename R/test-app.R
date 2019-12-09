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
#' @param interactive If there are any differences between current results and
#'   expected results, provide an interactive graphical viewer that shows the
#'   changes and allows the user to accept or reject the changes.
#' @param suffix An optional suffix for the expected results directory. For
#'   example, if the suffix is \code{"mac"}, the expected directory would be
#'   \code{mytest-expected-mac}.
#'
#' @seealso \code{\link{snapshotCompare}} and \code{\link{snapshotUpdate}} if
#'   you want to compare or update snapshots after testing. In most cases, the
#'   user is prompted to do these tasks interactively, but there are also times
#'   where it is useful to call these functions from the console.
#'
#' @export
testApp <- function(
  appDir = ".",
  testnames = NULL,
  quiet = FALSE,
  compareImages = TRUE,
  interactive = base::interactive(),
  suffix = NULL
)
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

  testsDir <- findTestsDir(appDir, quiet=FALSE)
  found_testnames <- findTests(testsDir, testnames)
  found_testnames_no_ext <- sub("\\.[rR]$", "", found_testnames)

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
    snapshotCompare(
      appDir,
      testnames = found_testnames_no_ext,
      quiet = quiet,
      images = compareImages,
      interactive = interactive,
      suffix = suffix
    )
  )
}

#' Identify in which directory the tests are contained.
#'
#' Prior to 1.3.1.9999, tests were stored directly in `tests/` rather than
#' nested in `tests/shinytests/`.
#'
#' @param mustExist If TRUE, will error if we can't find a test directory.
#' @param quiet If we see that the tests are stored in the top-level tests/ directory as we used to
#'   recommend, we will note the new recommendation in a message to the user if this is FALSE.
#'
#' This function does the following:
#'  1. Check to see if `tests/shinytests/` exists. If so, use it.
#'  2. Check to see if all the top-level R files in `tests/` appear to be shinytests. If
#'     some are and some aren't, throw an error.
#'  3. Assuming all top-level R files in `tests/` appear to be shinytests, return that dir.
#' @noRd
findTestsDir <- function(appDir, mustExist=TRUE, quiet=TRUE) {
  if (basename(appDir) == "tests"){
    # We were given a */tests/ directory. It's possible that we're in the middle of a nested tests
    # directory and the application dir is actually one level up. This happens in certain versions
    # of the RStudio IDE.
    # https://github.com/rstudio/rstudio/issues/5677

    if (!dir_exists(file.path(appDir, "tests"))){
      # We're in a dir called `tests` and there's not another `tests` directory inside, so we can
      # assume that the app dir is actually probably one level up.
      appDir <- dirname(appDir)
    }
  }

  testsDir <- file.path(appDir, "tests")
  if (!dir_exists(testsDir) && mustExist) {
    stop("tests/ directory doesn't exist")
  } else if (!dir_exists(testsDir) && !mustExist) {
    # Use the preferred directory if nothing exists yet.
    return(file.path(testsDir, "shinytests"))
  }

  r_files <- list.files(testsDir, pattern = "\\.[rR]$", full.names = TRUE)
  is_test <- vapply(r_files, function(f) {
    isShinyTest(readLines(f, warn=FALSE))
  }, logical(1))

  shinytestsDir <- file.path(testsDir, "shinytests")
  if (dir_exists(shinytestsDir)) {
    # We'll want to use this dir. But as a courtesy, let's warn if we find anything
    # that appears to be a shinytest in the top-level; it's possible that someone
    # using the old layout (tests at the top-level) might have just had a directory
    # named shinytests. Let's leave them a clue.
    if (any(is_test) && !quiet) {
      warning("Assuming that the shinytests are stored in tests/shinytests, but it appears that there are some ",
              "shinytests in the top-level tests/ directory. All shinytests should be placed in the tests/shinytests directory.")
    }

    return(shinytestsDir)
  }

  if (!any(is_test) && !mustExist){
    # There may be some stuff in the tests directory, but if it's not shinytest-related...
    # Ignore and just use the nested dir
    return(shinytestsDir)
  }

  if (!all(is_test)) {
    stop("Found R files that don't appear to be shinytests in the tests/ directory. shinytests should be placed in tests/shinytests/")
  }

  if (!quiet) {
    message("shinytests should be placed in the tests/shinytests directory. Storing them in the top-level tests/ directory will be deprecated in the future.")
  }
  testsDir
}

#' Check to see if the given text is a shinytest
#' Scans for the magic string of `app <- ShinyDriver$new(` as an indicator that this is a shinytest.
#' @noRd
isShinyTest <- function(text) {
  lines <- grepl("app\\s*<-\\s*ShinyDriver\\$new\\(", text, perl=TRUE)
  any(lines)
}

#' Finds the relevant tests in a given directory
#' @noRd
findTests <- function(testsDir, testnames=NULL) {
  found_testnames <- list.files(testsDir, pattern = "\\.[rR]$")
  found_testnames_no_ext <- sub("\\.[rR]$", "", found_testnames)

  if (!is.null(testnames)) {
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
  }

  found_testnames
}

all_testnames <- function(testDir, suffixes = c("-expected", "-current")) {
  # Create a regex string like "(-expected|-current)$"
  pattern <- paste0(
    "(",
    paste0(suffixes, collapse = "|"),
    ")$"
  )

  testnames <- dir(testDir, pattern = pattern)
  testnames <- sub(pattern, "", testnames)
  unique(testnames)
}


validate_testname <- function(testDir, testname) {
  valid_testnames <- all_testnames(testDir)

  if (is.null(testname) || !(testname %in% valid_testnames)) {
    stop('"', testname, '" ',
      'is not a valid testname for the app. Valid names are: "',
      paste(valid_testnames, collapse = '", "'), '".'
    )
  }
}
