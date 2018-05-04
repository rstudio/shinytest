
random_open_port <- function(min = 3000, max = 9000, n = 20) {
  # Unsafe port list from shiny::runApp()
  valid_ports <- setdiff(min:max, c(3659, 4045, 6000, 6665:6669, 6697))

  # Try up to n ports
  for (port in sample(valid_ports, n)) {
    handle <- NULL

    # Check if port is open
    tryCatch(
      handle <- httpuv::startServer("127.0.0.1", port, list()),
      error = function(e) { }
    )
    if (!is.null(handle)) {
      httpuv::stopServer(handle)
      return(port)
    }
  }

  stop("Cannot find an available port")
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

parse_url <- function(url) {
  res <- regexpr("^(?<protocol>https?)://(?<host>[^:/]+)(:(?<port>\\d+))?(?<path>/.*)?$", url, perl = TRUE)

  if (res == -1) stop(url, " is not a valid URL.")

  start  <- attr(res, "capture.start",  exact = TRUE)[1, ]
  length <- attr(res, "capture.length", exact = TRUE)[1, ]

  get_piece <- function(n) {
    if (start[[n]] == 0) return("")

    s <- substring(url, start[[n]], start[[n]] + length[[n]] - 1)
  }

  list(
    protocol = get_piece("protocol"),
    host     = get_piece("host"),
    port     = get_piece("port"),
    path     = get_piece("path")
  )
}

# If it's a directory, return FALSE. If it's a file ending with .Rmd, return TRUE.
# For other cases, throw error.
is_rmd <- function(path) {
  if (utils::file_test('-d', path)) {
    FALSE
  } else if (grepl("\\.Rmd", path, ignore.case = TRUE)) {
    TRUE
  } else {
    stop("Unknown whether app is a regular Shiny app or .Rmd: ", path)
  }
}

# Given a path, return a path that can be passed to ShinyDriver$new()
# * If it is a path to an Rmd file including filename (like foo/doc.Rmd), return path unchanged.
# * If it is a dir containing app.R, server.R, return path unchanged.
# * If it is a dir containing index.Rmd, return the path with index.Rmd at the end.
# * Otherwise, throw error.
app_path <- function(path) {
  if (grepl("\\.Rmd", path, ignore.case = TRUE)) {
    return(path)
  }
  if (dir_exists(path)) {
    if (any(c("app.r", "server.r") %in% tolower(dir(path)))) {
      return(path)
    }
    if ("index.Rmd" %in% dir(path)) {
      return(file.path(path, "index.Rmd"))
    }
  }

  stop(path, " must be a directory containing app.R, server.R, or index.Rmd; or path to a .Rmd file (including the filename).")
}



raw_to_utf8 <- function(data) {
  res <- rawToChar(data)
  Encoding(res) <- "UTF-8"
  res
}

read_raw <- function(file) {
  readBin(file, "raw", n = file.info(file)$size)
}

read_utf8 <- function(file) {
  res <- read_raw(file)
  raw_to_utf8(res)
}
