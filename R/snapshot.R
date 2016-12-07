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
  current_dir  <- paste0(self$get_snapshot_dir(), "-current")
  expected_dir <- paste0(self$get_snapshot_dir(), "-expected")

  if (dir_exists(expected_dir)) {
    res <- dirs_identical(expected_dir, current_dir)

    if (res && autoremove) {
      # If identical contents, remove dir with current results
      unlink(current_dir)
    }

    invisible(res)

  } else {
    message("No existing snapshots at ", rel_path(expected_dir), ".\n",
      "This must be a first run of tests.\n",
      "Run app$snapshot_update() to save current results as expected results.")
    invisible(FALSE)
  }
}


app_snapshot_update <- function(self, private) {
  current_dir  <- paste0(self$get_snapshot_dir(), "-current")
  expected_dir <- paste0(self$get_snapshot_dir(), "-expected")

  if (dir_exists(expected_dir)) {
    message("Removing old expected directory ", rel_path(expected_dir), ".")
    unlink(expected_dir, recursive = TRUE)
  }

  message("Renaming ", rel_path(current_dir), " => ", rel_path(expected_dir), ".")
  file.rename(current_dir, expected_dir)
  invisible()
}
