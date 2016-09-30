
#' @importFrom processx process
#' @importFrom webdriver session

app_initialize <- function(self, private, path, load_timeout, clients,
                           check_names, debug, phantom_debug_level) {

  "!DEBUG start up shiny app from `path`"
  private$start_shiny(path)

  "!DEBUG create clients"
  for (i in seq_len(clients)) {
    self$clients[[i]] <- shinyapp_client$new(
      private$get_shiny_url(),
      load_timeout,
      phantom_debug_level
    )
  }

  "!DEBUG shiny started"
  private$state <- "running"

  private$setup_debugging(debug)

  "!DEBUG checking widget names"
  if (check_names) {
    for (i in seq_len(clients)) {
      self$clients[[i]]$check_unique_widget_names()
    }
  }

  invisible(self)
}


#' @importFrom shiny runApp
#' @importFrom rematch re_match

app_start_shiny <- function(self, private, path) {

  rcmd <- paste0("shinytest:::with_shinytest_js(shiny::runApp('", path, "'))")

  Rexe <- if (is_windows()) "R.exe" else "R"
  Rbin <- file.path(R.home("bin"), Rexe)
  cmd <- paste0(
    shQuote(Rbin), " -q -e ",
    shQuote(rcmd)
  )

  sh <- process$new(commandline = cmd)

  "!DEBUG waiting for shiny to start"
  if (! sh$is_alive()) {
    stop(
      "Failed to start shiny. Error: ",
      strwrap(sh$read_error_lines())
    )
  }

  "!DEBUG finding shiny port"
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

  "!DEBUG shiny up and running, port `m[, 'port']`"

  private$shiny_host <- assert_host(m[, "host"])
  private$shiny_port <- assert_port(as.integer(m[, "port"]))
  private$shiny_process <- sh
}

app_get_shiny_url <- function(self, private) {
  paste0("http://", private$shiny_host, ":", private$shiny_port)
}
