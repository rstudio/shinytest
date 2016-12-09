
#' Generate a random port number
#'
#' Ideally, phantomjs should support a random port, assigned by the OS.
#' But it does not, so we generate one randomly and hope for the best.
#'
#' @param min lower limit
#' @param max upper limit
#' @return integer scalar, generated port number
#'
#' @keywords internal

random_port <- function(min = 3000, max = 9000) {
  if (min < max) sample(min:max, 1) else min
}

check_external <- function(x) {
  if (Sys.which(x) == "") {
    stop("Cannot start '", x, "', make sure it is in the path")
  }
}

parse_class <- function(x) {
  strsplit(x, "\\s+")[[1]]
}

`%||%` <- function(l, r) if (is.null(l)) r else l

`%|NA|%` <- function(l, r) ifelse(! is.na(l), l, r)

#' @importFrom utils packageName

package_version <- function(pkg = packageName()) {
  asNamespace(pkg)$`.__NAMESPACE__.`$spec[["version"]]
}

`%+%` <- function(l, r) {
  assert_that(is_string(l))
  assert_that(is_string(r))
  paste0(l, r)
}

str <- function(x) as.character(x)

is_windows <- function() .Platform$OS.type == "windows"

is_osx     <- function() Sys.info()[['sysname']] == 'Darwin'

is_linux   <- function() Sys.info()[['sysname']] == 'Linux'

dir_exists <- function(path) utils::file_test('-d', path)

rel_path <- function(path, base = getwd()) {
  # Attempt to normalize path; if it fails, leave unchanged
  try(
    path <- normalizePath(path, winslash = "/", mustWork = TRUE),
    silent = TRUE
  )

  base_len <- nchar(base)

  if (substring(path, 1, base_len) == base) {
    new_path <- substring(path, base_len + 1)
    # Strip off leading / if present
    if (substring(new_path, 1, 1) == "/") {
      new_path <- substring(new_path, 2)
    }
    if (new_path == "")
      return(".")
    else
      return(new_path)

  } else {
    path
  }
}
