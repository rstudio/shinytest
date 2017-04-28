#' @inheritParams diffviewer_widget
#' @export
view_diff <- function(old, new, pattern = NULL) {

  app <- shinyApp(
    ui = fluidPage(
      diffviewer_widget(old, new, pattern = pattern)
    ),
    server = function(input, output) {

    }
  )

  runApp(app)
}


#' @param old,new Names of the old and new directories to compare.
#'   Alternatively, they can be a character vectors of specific files to
#'   compare.
#' @param pattern A filter to apply to the old and new directories.
#' @param width Width of the htmlwidget.
#' @param height Height of the htmlwidget
#'
#' @export
diffviewer_widget <- function(old, new, width = NULL, height = NULL, pattern = NULL) {

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
    if (file.exists(filename)) {
      rawToChar(readBin(filename, 'raw', n = file.info(filename)$size))
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
    width = width,
    height = height,
    package = "shinytest"
  )
}
