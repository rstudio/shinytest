
#' @importFrom processx process
#' @importFrom webdriver session

app_initialize <- function(self, private, path, load_timeout, check_names) {

  ## Start up phantomjs
  private$start_phantomjs()

  ## Start up shiny
  private$start_shiny(path)

  ## New session in phantomjs
  private$web <- session$new(port = private$phantom_port)

  ## Navigate to shiny app
  private$web$go(private$get_shiny_url())

  ## Wait until shiny starts
  load_ok <- private$web$wait_for(
    'window.shinytest && window.shinytest.connected === true',
    timeout = load_timeout
  )
  if (!load_ok) stop("Shiny app did not load in ", load_timeout, "ms")

  private$state <- "running"

  if (check_names) self$check_unique_widget_names()

  invisible(self)
}

#' Start phantomjs
#'
#' It is not possible to start phantomjs on a randomized port currently,
#' unfortunately.
#'
#' `processx::process` will automaticall kill it, once `app` is
#' garbage collected.
#'
#' @param self me
#' @param private dark side of me
#'
#' @keywords internal

app_start_phantomjs <- function(self, private) {
  check_external("phantomjs")
  private$phantom_port <- random_port()

  cmd <- paste0("phantomjs --proxy-type=none --webdriver=127.0.0.1:", private$phantom_port)
  ph <- process$new(commandline = cmd)

  if (! ph$is_alive()) {
    stop(
      "Failed to start phantomjs. Error: ",
      strwrap(ph$read_error_lines())
    )
  }

  private$phantom_process <- ph
}

#' @importFrom shiny runApp
#' @importFrom rematch re_match

app_start_shiny <- function(self, private, path) {

  rcmd <- paste0("shinytest:::run_app('", path, "')")

  R <- file.path(R.home("bin"), "R")
  cmd <- paste0(
    shQuote(R), " -q -e ",
    shQuote(rcmd)
  )

  sh <- process$new(commandline = cmd)

  if (! sh$is_alive()) {
    stop(
      "Failed to start shiny. Error: ",
      strwrap(sh$read_error_lines())
    )
  }

  ## Try to read out the port, keep trying for 5 seconds
  err_lines <- character()
  for (i in 1:50) {
    l <- sh$read_error_lines(n = 1)
    err_lines <- c(err_lines, l)
    if (length(l) && grepl("Listening on http", l)) break
    Sys.sleep(0.1)
  }
  if (i == 50) {
    stop("Cannot find shiny port number. Error: ", strwrap(err_lines))
  }

  m <- re_match(text = l, "https?://(?<host>[^:]+):(?<port>[0-9]+)")

  private$shiny_host <- assert_host(m[, "host"])
  private$shiny_port <- assert_port(as.integer(m[, "port"]))
  private$shiny_process <- sh
}

app_get_shiny_url <- function(self, private) {
  paste0("http://", private$shiny_host, ":", private$shiny_port)
}
