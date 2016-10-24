
#' @importFrom processx process
#' @importFrom webdriver session

app_initialize <- function(self, private, path, load_timeout, check_names,
                           debug, phantom_debug_level) {

  "!DEBUG get phantom port (starts phantom if not running)"
  private$phantom_port <- get_phantom_port()

  "!DEBUG start up shiny app from `path`"
  private$start_shiny(path)

  "!DEBUG create new phantomjs session"
  private$web <- session$new(port = private$phantom_port)

  ## Set implicit timeout to zero. According to the standard it should
  ## be zero, but phantomjs uses about 200 ms
  private$web$set_timeout(implicit = 0)

  "!DEBUG navigate to Shiny app"
  private$web$go(private$get_shiny_url())

  "!DEBUG wait until Shiny starts"
  load_ok <- private$web$wait_for(
    'window.shinytest && window.shinytest.connected === true',
    timeout = load_timeout
  )
  if (!load_ok) stop("Shiny app did not load in ", load_timeout, "ms")

  "!DEBUG shiny started"
  private$state <- "running"

  private$setup_debugging(debug)

  "!DEBUG checking widget names"
  if (check_names) self$check_unique_widget_names()

  invisible(self)
}

#' @importFrom rematch re_match
#' @importFrom withr with_envvar

app_start_shiny <- function(self, private, path) {

  assert_that(is_string(path))

  libpath <- paste(deparse(.libPaths()), collapse = "")
  rcmd <- sprintf(
    paste(
      sep = ";",
      ".libPaths(c(%s, .libPaths()))",
      "options(shiny.testing=TRUE)",
      "shinytest:::with_shinytest_js(shiny::runApp('%s'))"
    ),
    libpath,
    path
  )

  ## On windows, if is better to use single quotes
  rcmd <- gsub('"', "'", rcmd)

  Rexe <- if (is_windows()) "R.exe" else "R"
  Rbin <- file.path(R.home("bin"), Rexe)
  cmd <- paste0(
    shQuote(Rbin), " -q -e ",
    shQuote(rcmd)
  )

  sh <- with_envvar(
    c("R_TESTS" = NA),
    process$new(commandline = cmd)
  )

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

  assert_that(is_host(host <- m[, "host"]))
  assert_that(is_port(port <- as.integer(m[, "port"])))

  private$shiny_host <- host
  private$shiny_port <- port
  private$shiny_process <- sh
}

app_get_shiny_url <- function(self, private) {
  paste0("http://", private$shiny_host, ":", private$shiny_port)
}

# Possible locations of the PhantomJS executable
phantom_paths <- function() {
  if (is_windows()) {
    path <- Sys.getenv('APPDATA', '')
    path <- if (dir_exists(path)) file.path(path, 'PhantomJS')
  } else if (is_osx()) {
    path <- '~/Library/Application Support'
    path <- if (dir_exists(path)) file.path(path, 'PhantomJS')
  } else {
    path <- '~/bin'
  }
  path <- c(path, system.file('PhantomJS', package = 'webdriver'))
  path
}

# Find PhantomJS from PATH, APPDATA, system.file('webdriver'), ~/bin, etc
find_phantom <- function() {
  path <- Sys.which( "phantomjs" )
  if (path != "") return(path)

  for (d in phantom_paths()) {
    exec <- if (is_windows()) "phantomjs.exe" else "phantomjs"
    path <- file.path(d, exec)
    if (utils::file_test("-x", path)) break else path <- ""
  }

  if (path == "") {
    # It would make the most sense to throw an error here. However, that would
    # cause problems with CRAN. The CRAN checking systems may not have phantomjs
    # and may not be capable of installing phantomjs (like on Solaris), and any
    # packages which use webdriver in their R CMD check (in examples or vignettes)
    # will get an ERROR. We'll issue a message and return NULL; other
    message(
      "PhantomJS not found. You can install it with webdriver::install_phantomjs(). ",
      "If it is installed, please make sure the phantomjs executable ",
      "can be found via the PATH variable."
    )
    return(NULL)
  }
  path.expand(path)
}
