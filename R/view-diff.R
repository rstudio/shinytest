#' Creat an htmlwidget that shows differences between files or directories
#'
#' This function can be used for viewing differences between current test
#' results and the expected results
#'
#' @param old,new Names of the old and new directories to compare.
#'   Alternatively, they can be a character vectors of specific files to
#'   compare.
#' @param pattern A filter to apply to the old and new directories.
#' @param width Width of the htmlwidget.
#' @param height Height of the htmlwidget
#'
#' @export
diffviewer_widget <- function(old, new, width = NULL, height = NULL,
  pattern = NULL)
{

  if (xor(assertthat::is.dir(old), assertthat::is.dir(new))) {
      stop("`old` and `new` must both be directories, or character vectors of filenames.")
  }

  # If `old` or `new` are directories, get a list of filenames from both directories
  if (assertthat::is.dir(old)) {
    all_filenames <- sort(unique(c(
      dir(old, recursive = TRUE, pattern = pattern),
      dir(new, recursive = TRUE, pattern = pattern)
    )))
  }

  # TODO: Make sure old and new are the same length. Needed if someone passes
  # in files directly.
  #
  # Also, make it work with file lists in general.

  get_file_contents <- function(filename) {
    if (!file.exists(filename)) {
      return(NULL)
    }

    bin_data <- read_raw(filename)

    # Assume .json and .download files are text
    if (grepl("\\.json$", filename) || grepl("\\.download$", filename)) {
      raw_to_utf8(bin_data)
    } else if (grepl("\\.png$", filename)) {
      paste0("data:image/png;base64,", jsonlite::base64_enc(bin_data))
    } else {
      ""
    }
  }

  get_both_file_contents <- function(filename) {
    list(
      filename = filename,
      old = get_file_contents(file.path(old, filename)),
      new = get_file_contents(file.path(new, filename))
    )
  }

  diff_data <- lapply(all_filenames, get_both_file_contents)

  htmlwidgets::createWidget(
    name = "diffviewer",
    list(
      diff_data = diff_data
    ),
    sizingPolicy = htmlwidgets::sizingPolicy(
      defaultWidth = "100%",
      defaultHeight = "100%",
      browser.padding = 10,
      viewer.fill = FALSE
    ),
    package = "shinytest"
  )
}


#' Interactive viewer widget for changes in test results
#'
#' @param appDir Directory of the Shiny application that was tested.
#' @param testname Name of test to compare.
#'
#' @export
viewTestDiffWidget <- function(appDir = ".", testname = NULL) {
  expected <- file.path(appDir, "tests", paste0(testname, "-expected"))
  current  <- file.path(appDir, "tests", paste0(testname, "-current"))
  diffviewer_widget(expected, current)
}


#' Interactive viewer for changes in test results
#'
#' @inheritParams viewTestDiffWidget
#' @import shiny
#' @export
viewTestDiff <- function(appDir = ".", testname = NULL) {
  valid_testnames <- dir(file.path(appDir, "tests"), pattern = "-(expected|current)$")
  valid_testnames <- sub("-(expected|current)$", "", valid_testnames)
  valid_testnames <- unique(valid_testnames)
  if (is.null(testname) || !(testname %in% valid_testnames)) {
    stop('"', testname, '" ',
      'is not a valid testname for the app. Valid names are: "',
      paste(valid_testnames, collapse = '", "'), '".'
    )
  }


  withr::with_options(
    list(
      shinytest.app.dir = normalizePath(appDir, mustWork = TRUE),
      shinytest.test.name = testname
    ),
    invisible(
      shiny::runApp(system.file("diffviewerapp", package = "shinytest"))
    )
  )
}
