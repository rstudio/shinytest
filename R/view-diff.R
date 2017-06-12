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

    bin_data <- readBin(filename, "raw", n = file.info(filename)$size)

    if (grepl("\\.json$", filename)) {
      res <- rawToChar(bin_data)
      Encoding(res) <- "UTF-8"
      res
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
#' @param testname Name of test to compare.
#' @param appDir Directory of the Shiny application that was tested.
#'
#' @export
viewTestDiffWidget <- function(testname = NULL, appDir = ".") {
  expected <- file.path(appDir, "tests", paste0(testname, "-expected"))
  current  <- file.path(appDir, "tests", paste0(testname, "-current"))
  diffviewer_widget(expected, current)
}


#' Interactive viewer for changes in test results
#'
#' @inheritParams viewTestDiffWidget
#' @import shiny
#' @export
viewTestDiff <- function(testname = NULL, appDir = ".") {
  app <- shinyApp(
    ui = fluidPage(
      h2(paste0("Differences between expected and current test results for ", basename(appDir), ": ", testname)),
      viewTestDiffWidget(testname, appDir),
      wellPanel(
        actionButton("accept", "Save new results as expected results",
          class = "btn-primary"),
        actionButton("reject", "Quit (don't save new results)",
          class = "btn-danger")
      )
    ),

    server = function(input, output) {
      observeEvent(input$accept, {
        snapshotUpdate(appDir, testname)
        stopApp("accept")
      })

      observeEvent(input$reject, {
        stopApp("reject")
      })

    }
  )

  shiny::runApp(app)
}
