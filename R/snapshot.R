app_snapshot <- function(self, private, items, filename, dir, screenshot)
{
  if (!is.list(items) && !is.null(items))
    stop("'items' must be NULL or a list.")

  private$snapshot_count <- private$snapshot_count + 1

  # Strip off trailing slash if present
  dir <- sub("/$", "", dir)
  cur_dir <- paste0(dir, "-current")
  expected_dir <- paste0(dir, "-expected")

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
    if (dir_exists(cur_dir)) {
      unlink(cur_dir, recursive = TRUE)
    }
    dir.create(cur_dir, recursive = TRUE)
  }

  writeBin(req$content, file.path(cur_dir, filename))

  if (screenshot) {
    # Replace extension with .png
    scr_filename <- paste0(sub("\\.[^.]*$", "", filename), ".png")
    app$take_screenshot(file.path(cur_dir, scr_filename))
  }

  # Compare to expected result ------------------------------------------------
  if (dir_exists(expected_dir)) {
    compare_to_expected(filename, expected_dir, current_dir)
  } else {
    if (private$snapshot_count == 1) {
      message("First run with snapshots. No expected directory to compare to.",
        " When finished, run update_expected().")
    }
  }

  # Invisibly return JSON content as a string
  data <- rawToChar(req$content)
  Encoding(data) <- "UTF-8"
  invisible(data)
}
