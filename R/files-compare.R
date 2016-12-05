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


dirs_identical <- function(expected, current) {
  diff_found <- FALSE

  if (!dir_exists(expected)) stop("Directory ", expected, " not found.")
  if (!dir_exists(current))  stop("Directory ", current, " not found.")

  expected_files <- list.files(expected)
  current_files  <- list.files(current)

  # Compare individual files
  all_files <- sort(union(expected_files, current_files))
  for (file in all_files) {
    expected_file <- file.path(expected, file)
    current_file  <- file.path(current, file)

    if (!file.exists(expected_file)) {
      message("Current dir contains files not found in expected dir: ", file)
      diff_found <- TRUE

    } else if (!file.exists(current_file)) {
      message("Expected dir contains files not found in current dir: ", file)
      diff_found <- TRUE

    } else {
      res <- files_identical(expected_file, current_file)
      if (!res) {
        message("Expected file ", expected_file,
          " and current file ", current_file, " have different contents."
        )
        diff_found <- TRUE
      }
    }
  }

  !diff_found
}


compare_to_expected <- function(filename, expected_dir, current_dir) {
  if (!dir_exists(expected_dir)) stop("Directory ", expected_dir, " not found.")
  if (!dir_exists(current_dir))  stop("Directory ", current_dir, " not found.")

  expected_file <- file.path(expected_dir, filename)
  current_file  <- file.path(current_dir,  filename)

  if (!file.exists(expected_file)) {
    message("File not found in expected dir: ", filename)
    return(FALSE)

  } else if (!file.exists(current_file)) {
    message("Expected dir contains files not found in current dir: ", filename)
    return(FALSE)

  } else if (!files_identical(expected_file, current_file)) {
    message(
      "File named ", filename, " in ", expected_dir,
      " has different contents from ", current_dir, "."
    )
    return(FALSE)
  }

  TRUE
}

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
