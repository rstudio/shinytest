files_identical <- function(a, b) {
  if (!file.exists(a)) {
    message("File ", a, " not found.")
    return(FALSE)
  }
  if (!file.exists(b)) {
    message("File ", b, " not found.")
    return(FALSE)
  }

  # Fast path: if not the same size, return FALSE
  a_size <- file.info(a)$size
  b_size <- file.info(b)$size
  if (!identical(a_size, b_size)) {
    return(FALSE)
  }

  a_content <- readBin(a, "raw", n = a_size)
  b_content <- readBin(b, "raw", n = b_size)
  identical(a_content, b_content)
}


dirs_diff <- function(expected, current) {
  diff_found <- FALSE

  if (!dir_exists(expected)) stop("Directory ", expected, " not found.")
  if (!dir_exists(current))  stop("Directory ", current, " not found.")

  expected_files <- list.files(expected)
  current_files  <- list.files(current)

  # Compare individual files
  all_files <- sort(union(expected_files, current_files))
  res <- lapply(all_files, function(file) {
    expected_file <- file.path(expected, file)
    current_file  <- file.path(current, file)

    res <- list(
      name = file,
      expected = file.exists(expected_file),
      current  = file.exists(current_file)
    )

    if (res$expected && res$current) {
      res$identical <- files_identical(expected_file, current_file)
    } else {
      res$identical <- NA
    }
    res
  })

  # Convert to data frame
  data.frame(
    name      = vapply(res, `[[`, "name",      FUN.VALUE = ""),
    expected  = vapply(res, `[[`, "expected",  FUN.VALUE = TRUE),
    current   = vapply(res, `[[`, "current",   FUN.VALUE = TRUE),
    identical = vapply(res, `[[`, "identical", FUN.VALUE = TRUE)
  )
}


# Return path to a diff program. Either `diff` or, if not found, then use `fc`
# (Windows only).
which_diff <- function() {
  path <- Sys.which("diff")
  if (path != "")
    return(path)

  if (is_windows()) {
    path <- Sys.which("fc")
    if (path != "")
      return(path)

    stop("No program named `diff` or `fc` found in path.")
  }
  stop("No program named `diff` found in path.")
}


# Return a text diff of two files or directories. First attempts to use `diff`
# program, but if not found, will fall back to using `fc` on Windows. The format
# of the output therefore can vary on different platforms.
diff_files <- function(file1, file2) {
  diff_prog <- which_diff()

  out_file <- tempfile(fileext=".diff")
  on.exit(unlink(out_file))

  p <- process$new(
    command = which_diff(),
    stdout = out_file,
    args = c(file1, file2)
  )
  p$wait(timeout = 1000)

  bin_data <- readBin(out_file, "raw", n = file.info(out_file)$size)
  res <- rawToChar(bin_data)
  Encoding(res) <- "UTF-8"
  res
}
