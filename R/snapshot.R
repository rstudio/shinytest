app_snapshot <- function(self, private, filename, dir, items, screenshot)
{
  if (!is.list(items))
    stop("'items' must be a list.")

  extra_names <- setdiff(names(items), c("input", "output", "export"))
  if (length(extra_names) > 0) {
    stop("'items' must be a list containing one or more items named",
      "'input', 'output' and 'export'. Each of these can be TRUE, FALSE, ",
      " or a character vector.")
  }

  if (is.null(items$input))  items$input  <- FALSE
  if (is.null(items$output)) items$output <- FALSE
  if (is.null(items$export)) items$export <- FALSE

  if (!dir_exists(dir))
    dir.create(dir, recursive = TRUE)

  url <- private$get_test_snapshot_url(items$input, items$output, items$export)
  req <- httr::GET(url)

  writeBin(req$content, file.path(dir, filename))

  if (screenshot) {
    # Replace extension with .png
    scr_filename <- paste0(sub("\\.[^.]*$", "", filename), ".png")
    app$take_screenshot(file.path(dir, scr_filename))
  }

  # Invisibly return JSON content as a string
  data <- rawToChar(req$content)
  Encoding(data) <- "UTF-8"
  invisible(data)
}


app_next_snapshot_name <- function(self, private) {
  private$snapshot_count <- private$snapshot_count + 1
  sprintf("snapshot-%02d.json", private$snapshot_count)
}
