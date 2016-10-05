
phantom_env <- new.env()

#' @importFrom webdriver run_phantomjs

get_phantom_port <- function() {
  if (! is_phantom_alive()) {
    ph <- run_phantomjs()
    phantom_env$process <- ph$process
    phantom_env$port <- ph$port
  }

  phantom_env$port
}

#' @importFrom pingr ping_port

is_phantom_alive <- function() {
  ! is.null(phantom_env$process) &&
    ! is.null(phantom_env$port) &&
    ! is.na(ping_port("127.0.0.1", port = phantom_env$port, count = 1))
}
