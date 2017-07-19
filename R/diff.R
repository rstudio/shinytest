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
