app_snapshot <- function(self, private, items, filename, screenshot)
{
  if (!is.list(items) && !is.null(items))
    stop("'items' must be NULL or a list.")

  private$snapshot_count <- private$snapshot_count + 1

  current_dir  <- paste0(self$get_snapshot_dir(), "-current")

  if (is.null(filename)) {
    filename <- sprintf("%02d.json", private$snapshot_count)
  }

  # The default is to take a screenshot when the default is used for items (all
  # items), but not when the user specifies items.
  if (is.null(screenshot)) {
    screenshot <- is.null(items)
  }

  # Figure out which items to snapshot ----------------------------------------
  # By default, record all items.
  if (is.null(items)) {
    items <- list(input = TRUE, output = TRUE, export = TRUE)
  }

  extra_names <- setdiff(names(items), c("input", "output", "export"))
  if (length(extra_names) > 0) {
    stop("'items' must be a list containing one or more items named",
      "'input', 'output' and 'export'. Each of these can be TRUE, FALSE, ",
      " or a character vector.")
  }

  if (is.null(items$input))  items$input  <- FALSE
  if (is.null(items$output)) items$output <- FALSE
  if (is.null(items$export)) items$export <- FALSE

  # Take snapshot -------------------------------------------------------------
  url <- private$get_test_snapshot_url(items$input, items$output, items$export)
  req <- httr::GET(url)

  # For first snapshot, create -current snapshot dir.
  if (private$snapshot_count == 1) {
    if (dir_exists(current_dir)) {
      unlink(current_dir, recursive = TRUE)
    }
    dir.create(current_dir, recursive = TRUE)
  }

  writeBin(req$content, file.path(current_dir, filename))

  if (screenshot) {
    # Replace extension with .png
    scr_filename <- paste0(sub("\\.[^.]*$", "", filename), ".png")
    self$take_screenshot(file.path(current_dir, scr_filename))
  }

  # Invisibly return JSON content as a string
  data <- rawToChar(req$content)
  Encoding(data) <- "UTF-8"
  invisible(data)
}


app_snapshot_compare <- function(self, private, autoremove) {
  snapshot_compare(private$snapshot_dir, self$getTestsDir(), autoremove)
}

#' Compare current and expected snapshots
#'
#' This compares a current and expected snapshot for a test set, and prints
#' any differences to the console.
#'
#' @param name Name of a snapshot.
#' @param testsDir Directory that holds the tests for an application. This is
#'   the parent directory for the expected and current snapshot directories.
#' @param autoremove If the current results match the expected results, should
#'   the current results be removed automatically? Defaults to TRUE.
#'
#' @export
snapshot_compare <- function(name, testsDir, autoremove = TRUE) {
  current_dir  <- file.path(testsDir, paste0(name, "-current"))
  expected_dir <- file.path(testsDir, paste0(name, "-expected"))

  # When this function is called from test_app(), this is the way that we get
  # the relative path from the current working dir when test_app() is called.
  # (By the time this function is called, the current working dir is usually set
  # to the test directory.) If the option isn't set, this function was probably
  # called directly (not from test_app()), and we'll just use the value passed
  # in.
  relativeTestsDir <- getOption("shinytest.tests.dir", default = testsDir)

  if (dir_exists(expected_dir)) {
    res <- dirs_diff(expected_dir, current_dir)

    # If any files are missing from current or expected, or if they are not
    # identical, then there are differences between the dirs.
    any_different <- any(!res$current | !res$expected | !res$identical)

    if (any_different) {
      message("  Differences detected between ", basename(current_dir),
              "/ and ", basename(expected_dir), "/:\n")

      # A data frame that shows the differences, just for printed output.
      status <- data.frame(
        Name = res$name,
        " " = "",
        Status = "No change",
        stringsAsFactors = FALSE, check.names = FALSE
      )

      status[[" "]]     [!res$current]  <- "-"
      status[["Status"]][!res$current]  <- "Missing in -current/"

      status[[" "]]     [!res$expected] <- "+"
      status[["Status"]][!res$expected] <- "Missing in -expected/"

      # Use which() to ignore NA's
      status[[" "]][which(!res$identical)]      <- "\U2260"   # not-equal symbol
      status[["Status"]][which(!res$identical)] <- "Files differ"

      # Add spaces for nicer printed output
      names(status)[names(status) == "Name"] <- "Name     "

      status_table <- utils::capture.output(print(status, row.names = FALSE, right = FALSE))
      status_table <- sub("^", "   ", status_table)
      message(paste(status_table, collapse = "\n"))

      message('\n  To save current results as expected results, run:\n',
              '    snapshot_update("', name, '", "',
              relativeTestsDir, '")\n')
    }

    if (!any_different && autoremove) {
      # If identical contents, remove dir with current results
      unlink(current_dir, recursive = TRUE)
    }


    snapshot_status <- if (any_different) "different" else "same"

  } else {
    message("  No existing snapshots at ", basename(expected_dir), "/.",
            " This is a first run of tests.\n",
            '  To save current results as expected results, run:\n',
            '    snapshot_update("', name, '", "',
            relativeTestsDir, '")\n')

    snapshot_status <- "new"
  }

  invisible(list(
    name = name,
    status = snapshot_status
  ))
}


#' Update expected snapshot with current snapshot
#'
#' @rdname snapshot_compare
#' @inheritParams snapshot_compare
#' @export
snapshot_update <- function(name, testsDir = ".") {
  # Strip off trailing slash if present
  name <- sub("/$", "", name)

  base_path <- file.path(testsDir, name)
  current_dir  <- paste0(base_path, "-current")
  expected_dir <- paste0(base_path, "-expected")

  if (!dir_exists(current_dir)) {
    stop("Current result directory not found: ", current_dir)
  }

  if (dir_exists(expected_dir)) {
    message("Removing ", rel_path(expected_dir), ".")
    unlink(expected_dir, recursive = TRUE)
  }

  message("Renaming ", rel_path(current_dir),
          "\n      => ", rel_path(expected_dir), ".")
  file.rename(current_dir, expected_dir)
  invisible()
}
