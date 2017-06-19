sd_snapshot <- function(self, private, items, filename, screenshot)
{
  if (!is.list(items) && !is.null(items))
    stop("'items' must be NULL or a list.")

  private$snapshotCount <- private$snapshotCount + 1

  current_dir  <- paste0(self$getSnapshotDir(), "-current")

  if (is.null(filename)) {
    filename <- sprintf("%03d.json", private$snapshotCount)
  }

  # The default is to take a screenshot when the snapshotScreenshot option is
  # TRUE and the user does not specify specific items to snapshot.
  if (is.null(screenshot)) {
    screenshot <- private$snapshotScreenshot && is.null(items)
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
  self$logEvent("Taking snapshot")
  url <- private$getTestSnapshotUrl(items$input, items$output, items$export)
  req <- httr::GET(url)

  # For first snapshot, create -current snapshot dir.
  if (private$snapshotCount == 1) {
    if (dir_exists(current_dir)) {
      unlink(current_dir, recursive = TRUE)
    }
    dir.create(current_dir, recursive = TRUE)
  }

  # Convert to text, then replace base64-encoded images with hashes of them.
  content <- rawToChar(req$content)
  Encoding(content) <- "UTF-8"
  content <- hash_snapshot_image_data(content)
  writeChar(content, file.path(current_dir, filename), eos = NULL)

  if (screenshot) {
    # Replace extension with .png
    scr_filename <- paste0(sub("\\.[^.]*$", "", filename), ".png")
    self$takeScreenshot(file.path(current_dir, scr_filename))
  }

  # Invisibly return JSON content as a string
  data <- rawToChar(req$content)
  Encoding(data) <- "UTF-8"
  invisible(data)
}


sd_snapshotCompare <- function(self, private, autoremove) {
  message("app$snapshotCompare() no longer used")
}

sd_snapshotDownload <- function(self, private, id, filename) {

  current_dir <- paste0(self$getSnapshotDir(), "-current")

  private$snapshotCount <- private$snapshotCount + 1

  if (is.null(filename)) {
    filename <- sprintf("%03d.download", private$snapshotCount)
  }

  # Find the URL to download from (the href of the <a> tag)
  url <- self$findElement(paste0("#", id))$getAttribute("href")

  req <- httr::GET(url)
  writeBin(req$content, file.path(current_dir, filename))

  invisible(req$content)
}

#' Compare current and expected snapshots
#'
#' This compares a current and expected snapshot for a test set, and prints any
#' differences to the console.
#'
#' @param name Name of a snapshot.
#' @param appDir Directory that holds the tests for an application. This is the
#'   parent directory for the expected and current snapshot directories.
#' @param autoremove If the current results match the expected results, should
#'   the current results be removed automatically? Defaults to TRUE.
#' @param interactive If there are any differences between current results and
#'   expected results, provide an interactive graphical viewer that shows the
#'   changes and allows the user to accept or reject the changes.
#' @param quiet Should output be suppressed? This is useful for automated
#'   testing.
#'
#' @export
snapshotCompare <- function(appDir, name, autoremove = TRUE,
  interactive = base::interactive(), quiet = FALSE)
{
  current_dir  <- file.path(appDir, "tests", paste0(name, "-current"))
  expected_dir <- file.path(appDir, "tests", paste0(name, "-expected"))

  # When this function is called from testApp(), this is the way that we get
  # the relative path from the current working dir when testApp() is called.
  # (By the time this function is called, the current working dir is usually set
  # to the test directory.) If the option isn't set, this function was probably
  # called directly (not from testApp()), and we'll just use the value passed
  # in.
  relativeAppDir <- getOption("shinytest.app.dir", default = appDir)

  if (dir_exists(expected_dir)) {
    res <- dirs_diff(expected_dir, current_dir)

    # If any files are missing from current or expected, or if they are not
    # identical, then there are differences between the dirs.
    any_different <- any(!res$current | !res$expected | !res$identical)

    if (any_different) {
      snapshot_pass <- FALSE
      snapshot_status <- "different"

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
      status[[" "]][which(!res$identical)]      <- "!="
      status[["Status"]][which(!res$identical)] <- "Files differ"

      # Add spaces for nicer printed output
      names(status)[names(status) == "Name"] <- "Name     "

      status_table <- utils::capture.output(print(status, row.names = FALSE, right = FALSE))
      status_table <- sub("^", "   ", status_table)
      message(paste(status_table, collapse = "\n"))

      if (interactive) {
        response <- readline("Would you like to view the differences between expected and current results [y/n]? ")
        if (tolower(response) == "y") {
          quiet <- TRUE
          result <- viewTestDiff(appDir, name)

          if (result == "accept") {
            snapshot_pass <- TRUE
            snapshot_status <- "updated"
          }
        }
      }

      if (!quiet) {
        message('\n  To view differences between expected and current results, run:\n',
                '    viewTestDiff("', relativeAppDir, '", "', name, '")\n',
                '  To save current results as expected results, run:\n',
                '    snapshotUpdate("', relativeAppDir, '", "', name, '")\n')
      }

    } else {
      snapshot_pass <- TRUE
      snapshot_status <- "same"
    }

    if (!any_different && autoremove) {
      # If identical contents, remove dir with current results
      unlink(current_dir, recursive = TRUE)
    }

  } else {
    if (!quiet) {
      message("  No existing snapshots at ", basename(expected_dir), "/.",
              " This is a first run of tests.\n")
    }

    snapshotUpdate(appDir, name, quiet = quiet)

    snapshot_pass <- TRUE
    snapshot_status <- "new"
  }

  invisible(list(
    name = name,
    pass = snapshot_pass,
    status = snapshot_status
  ))
}


#' Update expected snapshot with current snapshot
#'
#' @rdname snapshotCompare
#' @inheritParams snapshotCompare
#' @export
snapshotUpdate <- function(appDir = ".", name, quiet = FALSE) {
  # Strip off trailing slash if present
  name <- sub("/$", "", name)

  base_path <- file.path(appDir, "tests", name)
  current_dir  <- paste0(base_path, "-current")
  expected_dir <- paste0(base_path, "-expected")

  if (!dir_exists(current_dir)) {
    stop("Current result directory not found: ", current_dir)
  }

  if (!quiet) {
    message("Updating baseline snapshot at ",  expected_dir, "...")
  }

  if (dir_exists(expected_dir)) {
    if (!quiet)
      message("Removing ", rel_path(expected_dir), ".")
    unlink(expected_dir, recursive = TRUE)
  }

  if (!quiet) {
    message("Renaming ", rel_path(current_dir),
            "\n      => ", rel_path(expected_dir), ".")
  }
  file.rename(current_dir, expected_dir)
  invisible(expected_dir)
}


# Given a JSON string, find any strings that represent base64-encoded images
# and replace them with a hash of the value. The image is base64-decoded and
# then hashed with SHA1. The resulting hash value is the same as if the image
# were saved to a file on disk and then hashed.
hash_snapshot_image_data <- function(data) {
  image_offsets <- gregexpr(
    '"data:image/[^;]+;base64,([^"]+)"', data, useBytes = TRUE, perl = TRUE
  )[[1]]

  # No image data found
  if (length(image_offsets) == 1 && image_offsets == -1) {
    return(data)
  }

  # Image data indices
  image_start_idx <- as.integer(attr(image_offsets, "capture.start", exact = TRUE))
  image_stop_idx <- image_start_idx +
    as.integer(attr(image_offsets, "capture.length", exact = TRUE)) - 1

  # Text (non-image) data indices
  text_start_idx <- c(
    0,
    image_offsets + attr(image_offsets, "match.length", exact = TRUE)
  )
  text_stop_idx <- c(
    image_offsets - 1,
    nchar(data, type = "bytes")
  )

  # Get the strings representing image data, and all the other stuff
  image_data <- substring(data, image_start_idx, image_stop_idx)
  text_data  <- substring(data, text_start_idx,  text_stop_idx)

  # Hash the images
  image_hashes <- vapply(image_data, FUN.VALUE = "", function(dat) {
    digest::digest(
      jsonlite::base64_dec(dat),
      algo = "sha1", serialize = FALSE
    )
  })

  image_hashes <- paste0('"[image data sha1: ', image_hashes, ']"')

  # There's one fewer image hash than text elements. We need to add a blank
  # so that we can properly interleave them.
  image_hashes <- c(image_hashes, "")

  # Interleave the text data and the image hashes
  paste(
    c(rbind(text_data, image_hashes)),
    collapse = ""
  )
}
