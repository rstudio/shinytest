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
  content <- raw_to_utf8(req$content)
  content <- hash_snapshot_image_data(content)
  content <- jsonlite::prettify(content, indent = 2)
  writeChar(content, file.path(current_dir, filename), eos = NULL)

  if (screenshot) {
    # Replace extension with .png
    scr_filename <- paste0(sub("\\.[^.]*$", "", filename), ".png")
    self$takeScreenshot(file.path(current_dir, scr_filename))
  }

  # Invisibly return JSON content as a string
  invisible(raw_to_utf8(req$content))
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

  # For first snapshot, create -current snapshot dir.
  if (private$snapshotCount == 1) {
    if (dir_exists(current_dir)) {
      unlink(current_dir, recursive = TRUE)
    }
    dir.create(current_dir, recursive = TRUE)
  }

  writeBin(req$content, file.path(current_dir, filename))

  invisible(req$content)
}

#' Compare current and expected snapshots
#'
#' This compares current and expected snapshots for a test set, and prints any
#' differences to the console.
#'
#' @param testnames Name or names of a test. If NULL, compare all test results.
#' @param appDir Directory that holds the tests for an application. This is the
#'   parent directory for the expected and current snapshot directories.
#' @param autoremove If the current results match the expected results, should
#'   the current results be removed automatically? Defaults to TRUE.
#' @param interactive If there are any differences between current results and
#'   expected results, provide an interactive graphical viewer that shows the
#'   changes and allows the user to accept or reject the changes.
#' @param quiet Should output be suppressed? This is useful for automated
#'   testing.
#' @param images Should screenshots and PNG images be compared? It can be useful
#'   to set this to \code{FALSE} when the expected results were taken on a
#'   different platform from the current results.
#' @param suffix An optional suffix for the expected results directory. For
#'   example, if the suffix is \code{"mac"}, the expected directory would be
#'   \code{mytest-expected-mac}.
#'
#' @seealso \code{\link{testApp}}
#'
#' @export
snapshotCompare <- function(
  appDir,
  testnames = NULL,
  autoremove = TRUE,
  images = TRUE,
  quiet = FALSE,
  interactive = base::interactive(),
  suffix = NULL
) {

  testDir <- findTestsDir(appDir, quiet=TRUE)
  if (is.null(testnames)) {
    testnames <- all_testnames(testDir, "-current")
  }

  results <- lapply(
    testnames,
    function(testname) {
      snapshotCompareSingle(appDir, testname, autoremove, quiet, images, interactive, suffix)
    }
  )

  if (!interactive && !quiet) {
    pass_idx <- vapply(results, `[[`, "pass", FUN.VALUE = FALSE)
    all_pass <- all(pass_idx)

    relativeAppDir <- getOption("shinytest.app.dir", default = appDir)

    if (!all_pass) {
      message('\nTo view a textual diff, run:\n  viewTestDiff("', relativeAppDir, '", interactive = FALSE)')
    }
  }

  invisible(structure(
    list(
      appDir = appDir,
      results = results,
      images = images
    ),
    class = "shinytest.results"
  ))
}


snapshotCompareSingle <- function(
  appDir,
  testname,
  autoremove = TRUE,
  quiet = FALSE,
  images = TRUE,
  interactive = base::interactive(),
  suffix = NULL
) {
  testDir <- findTestsDir(appDir, quiet = TRUE)
  current_dir  <- file.path(testDir, paste0(testname, "-current"))
  expected_dir <- file.path(testDir, paste0(testname, "-expected"))
  expected_dir <- paste0(expected_dir, normalize_suffix(suffix))

  # When this function is called from testApp(), this is the way that we get
  # the relative path from the current working dir when testApp() is called.
  # (By the time this function is called, the current working dir is usually set
  # to the test directory.) If the option isn't set, this function was probably
  # called directly (not from testApp()), and we'll just use the value passed
  # in.
  relativeAppDir <- getOption("shinytest.app.dir", default = appDir)

  if (!quiet) {
    message("==== Comparing ", testname, "... ", appendLF = FALSE)
  }

  if (dir_exists(expected_dir)) {

    if (images) {
      filter_fun <- NULL
    } else {
      filter_fun <- remove_image_hashes_json
    }

    res <- dirs_differ(expected_dir, current_dir, filter_fun)

    if (!images) {
      res <- res[!grepl(".*\\.png$", res$name), ]
    }

    # If any files are missing from current or expected, or if they are not
    # identical, then there are differences between the dirs.
    any_different <- any(!res$current | !res$expected | !res$identical)

    if (any_different) {
      snapshot_pass <- FALSE
      snapshot_status <- "different"

      if (!quiet) {
        message("\n  Differences detected between ", basename(current_dir),
                "/ and ", basename(expected_dir), "/:\n")

        # A data frame that shows the differences, just for printed output.
        status <- data.frame(
          Name = res$name,
          " " = "",
          Status = "No change",
          stringsAsFactors = FALSE, check.names = FALSE
        )

        status[[" "]]     [!res$current]  <- "-"
        status[["Status"]][!res$current]  <- "Missing in -current"

        status[[" "]]     [!res$expected] <- "+"
        status[["Status"]][!res$expected] <- "Missing in -expected"

        # Use which() to ignore NA's
        status[[" "]][which(!res$identical)]      <- "!="
        status[["Status"]][which(!res$identical)] <- "Files differ"

        # Add spaces for nicer printed output
        names(status)[names(status) == "Name"] <- "Name     "

        status_table <- utils::capture.output(print(status, row.names = FALSE, right = FALSE))
        status_table <- sub("^", "   ", status_table)

        message(paste(status_table, collapse = "\n"))
      }

      if (interactive) {
        response <- readline("Would you like to view the differences between expected and current results [y/n]? ")
        if (tolower(response) == "y") {
          result <- viewTestDiff(appDir, testname, interactive, suffix = suffix)[[1]]

          if (result == "accept") {
            snapshot_pass <- TRUE
            snapshot_status <- "updated"
            quiet <- TRUE
          }
        }
      }

      if (!quiet && interactive) {

        if (is.null(suffix) || suffix == "") {
          suffix_param <- ""
        } else {
          suffix_param <- paste0(', suffix="', suffix, '"')
        }
        message('\n  To view differences between expected and current results, run:\n',
                '    viewTestDiff("', relativeAppDir, '", "', testname, '"', suffix_param, ')\n',
                '  To save current results as expected results, run:\n',
                '    snapshotUpdate("', relativeAppDir, '", "', testname, '"', suffix_param, ')\n')
      }

    } else {
      if (!quiet) {
        message("No changes.")
      }
      snapshot_pass <- TRUE
      snapshot_status <- "same"
    }

    if (!any_different && autoremove) {
      # If identical contents, remove dir with current results
      unlink(current_dir, recursive = TRUE)
    }

  } else {
    if (!quiet) {
      message("\n  No existing snapshots at ", basename(expected_dir), "/.",
              " This is a first run of tests.\n")
    }

    snapshotUpdate(appDir, testname, quiet = quiet, suffix = suffix)

    snapshot_pass <- TRUE
    snapshot_status <- "new"
  }

  invisible(list(
    appDir = appDir,
    name = testname,
    pass = snapshot_pass,
    status = snapshot_status,
    images = images
  ))
}


#' @rdname snapshotCompare
#' @export
snapshotUpdate <- function(
  appDir = ".",
  testnames = NULL,
  quiet = FALSE,
  suffix = NULL
) {
  testDir <- findTestsDir(appDir, quiet=TRUE)
  if (is.null(testnames)) {
    testnames <- all_testnames(testDir, "-current")
  }

  for (testname in testnames) {
    snapshotUpdateSingle(appDir, testname, quiet, suffix)
  }
}


snapshotUpdateSingle <- function(
  appDir = ".",
  testname,
  quiet = FALSE,
  suffix = NULL
) {
  # Strip off trailing slash if present
  testname <- sub("/$", "", testname)

  testDir <- findTestsDir(appDir, quiet=TRUE)
  base_path <- file.path(testDir, testname)
  current_dir  <- paste0(base_path, "-current")
  expected_dir <- paste0(base_path, "-expected")
  expected_dir <- paste0(expected_dir, normalize_suffix(suffix))

  if (!dir_exists(current_dir)) {
    stop("Current result directory not found: ", current_dir)
  }

  if (!quiet) {
    message("Updating baseline results at ",  expected_dir, "...")
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

  # Search for base64-encoded image data. There are two named groups:
  # - data_url is the entire data URL, including the leading quote,
  #   "data:image/png;base64,", the base64-encoded data, and the trailing quote.
  # - img_data is just the base64-encoded data.
  image_offsets <- gregexpr(
    '\\n\\s*"[^"]*"\\s*:\\s*(?<data_url>"data:image/[^;]+;base64,(?<img_data>[^"]+)")',
    data,
    perl = TRUE
  )[[1]]

  # No image data found
  if (length(image_offsets) == 1 && image_offsets == -1) {
    return(data)
  }

  attr2 <- function(x, name) {
    attr(x, name, exact = TRUE)
  }

  # Image data indices
  image_start_idx <- as.integer(attr2(image_offsets, "capture.start")[,"img_data"])
  image_stop_idx <- image_start_idx +
    as.integer(attr2(image_offsets, "capture.length")[,"img_data"]) - 1

  # Text (non-image) data indices
  text_start_idx <- c(
    0,
    attr2(image_offsets, "capture.start")[,"data_url"] +
      attr2(image_offsets, "capture.length")[,"data_url"]
  )
  text_stop_idx <- c(
    attr(image_offsets, "capture.start")[,"data_url"] - 1,
    nchar(data)
  )

  # Get the strings representing image data, and all the other stuff
  image_data <- substring(data, image_start_idx, image_stop_idx)
  text_data  <- substring(data, text_start_idx,  text_stop_idx)

  # Hash the images
  image_hashes <- vapply(image_data, FUN.VALUE = "", function(dat) {
    tryCatch({
      image_data <- jsonlite::base64_dec(dat)
      digest::digest(
        image_data,
        algo = "sha1", serialize = FALSE
      )
    }, error = function(e) {
      "Error hashing image data"
    })
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


# Given a JSON string, replace any lines like this:
#   "src": "[image data sha1: ebee9032833ed776d2be63a4c4025961e39d1afe]",
# with this:
#   "src": "[image data]",
remove_image_hashes <- function(json) {
  gsub(
    '((^|\\n)\\s*"src":\\s*"\\[image data) sha1: [^]]+\\]"',
    "\\1]",
    json
  )
}

# Given a filename and contents: if it is a JSON file, remove the image hashes
# and return the new JSON. If it is not a JSON file, return content unchanged.
remove_image_hashes_json <- function(filename, content) {
  if (!grepl("\\.json$", filename))
    return(content)

  content <- raw_to_utf8(content)
  content <- remove_image_hashes(content)
  charToRaw(content)
}

# Given a filename: If it is a PNG file, delete the file. If it is a JSON
# file, remove the image hashes and overwrite the original file with the new
# contents. For all other files, do nothing.
remove_image_hashes_and_files <- function(filename) {
  if (grepl("\\.png$", filename)) {
    unlink(filename)

  } else if (grepl("\\.json$", filename)) {
    content <- read_utf8(filename)
    content <- remove_image_hashes(content)
    writeChar(content, filename, eos = NULL)
    filename
  }

  filename
}
