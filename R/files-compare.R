files_identical <- function(a, b, preprocess = NULL) {
  if (!file.exists(a)) {
    message("File ", a, " not found.")
    return(FALSE)
  }
  if (!file.exists(b)) {
    message("File ", b, " not found.")
    return(FALSE)
  }

  if (is.null(preprocess)) { # if preprocess is here, size diff is no longer sufficient to return FALSE
    # Fast path: if not the same size, return FALSE
    a_size <- file.info(a)$size
    b_size <- file.info(b)$size
    if (!identical(a_size, b_size)) {
      return(FALSE)
    }
  }

  a_content <- read_raw(a)
  b_content <- read_raw(b)

  if (!is.null(preprocess)) {
    a_content <- preprocess(a, a_content)
    b_content <- preprocess(b, b_content)
  }

  identical(a_content, b_content)
}

# `expected` and `current` are directories. `file_preprocess` is an optional
# function that takes two arguments, `name` (a filename) and `content` (a raw
# vector of the file's contents). If present, the `file_preprocess` function
# will be used to prepare file contents before they are compared.
dirs_differ <- function(expected, current, preprocess = NULL) {
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
      res$identical <- files_identical(expected_file, current_file, preprocess)
    } else {
      warning("Missing files: ",ifelse(res$expected,"expected ",""),ifelse(res$current,"current",""))
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
#
# If present, the `file_preprocess` function will be used to prepare file
# contents before they are compared.
diff_files <- function(file1, file2, preprocess = NULL) {
  diff_prog <- which_diff()

  if (!is.null(preprocess)) {
    file_preprocess <- function(filename) {
      if (grepl("\\.png$", filename)) {
        unlink(filename)
      } else if (grepl("\\.json$", filename)) {
        content <- read_raw(filename)
        content <- raw_to_utf8(preprocess(filename,content))
        writeChar(content, filename, eos = NULL)
      }
      filename
    }
  } else
    file_preprocess = NULL

  tmp_dir <- tempfile("shinytest-diff-")
  dir.create(tmp_dir)
  on.exit(unlink(tmp_dir, recursive = TRUE))
  out_file <- file.path(tmp_dir, "shinytest-diff-output.txt")


  # If there's a preprocess function, we need to copy the files to a temp
  # directory and preprocess them before we can compare them.
  if (!is.null(file_preprocess)) {
    tmp_file1 <- file.path(tmp_dir, basename(file1))
    tmp_file2 <- file.path(tmp_dir, basename(file2))

    file.copy(file1, tmp_dir, recursive = TRUE)
    file.copy(file2, tmp_dir, recursive = TRUE)

    # Remove image hashes from tmp_file1 and tmp_file2. They can be files or
    # directories.
    lapply(
      list(tmp_file1, tmp_file2),
      function(path) {
        if (file.info(path)$isdir) {
          lapply(dir(path, full.names = TRUE), file_preprocess)
        } else {
          file_preprocess(path)
        }
      }
    )

    file1 <- tmp_file1
    file2 <- tmp_file2

    working_dir <- tmp_dir
  } else {
    working_dir <- getwd()
  }

  withr::with_dir(working_dir,
    {
      p <- process$new(
        command = which_diff(),
        stdout = out_file,
        args = c(file1, file2)
      )
    }
  )
  p$wait(timeout = 5000)
  p$kill()

  if (p$get_exit_status() == 0) {
    status <- "accept"
  } else {
    status <- "reject"
  }

  structure(
    read_utf8(out_file),
    status = status
  )
}
