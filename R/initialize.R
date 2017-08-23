
#' @importFrom processx process
#' @importFrom webdriver Session

sd_initialize <- function(self, private, path, loadTimeout, checkNames,
                          debug, phantomTimeout, seed, cleanLogs) {

  private$cleanLogs <- cleanLogs

  self$logEvent("Start ShinyDriver initialization")

  "!DEBUG get phantom port (starts phantom if not running)"
  self$logEvent("Getting PhantomJS port")
  private$phantomPort <- get_phantomPort(timeout = phantomTimeout)

  if (grepl("^http(s?)://", path)) {
    private$setShinyUrl(path)

  } else {
    "!DEBUG starting shiny app from path"
    self$logEvent("Starting Shiny app")
    private$startShiny(path, seed)
  }

  "!DEBUG create new phantomjs session"
  self$logEvent("Creating new phantomjs session")
  private$web <- Session$new(port = private$phantomPort)

  ## Set implicit timeout to zero. According to the standard it should
  ## be zero, but phantomjs uses about 200 ms
  private$web$setTimeout(implicit = 0)

  "!DEBUG navigate to Shiny app"
  self$logEvent("Navigating to Shiny app")
  private$web$go(private$getShinyUrl())

  "!DEBUG inject shiny-tracer.js"
  self$logEvent("Injecting shiny-tracer.js")
  js_file <- system.file("js", "shiny-tracer.js", package = "shinytest")
  js <- readChar(js_file, file.info(js_file)$size, useBytes = TRUE)
  private$web$executeScript(js)

  "!DEBUG wait until Shiny starts"
  self$logEvent("Waiting until Shiny app starts")
  load_ok <- private$web$waitFor(
    'window.shinytest && window.shinytest.connected === true',
    timeout = loadTimeout
  )
  if (!load_ok) {
    stop(
      "Shiny app did not load in ", loadTimeout, "ms.\n",
      format(self$getDebugLog())
    )
  }

  "!DEBUG shiny started"
  self$logEvent("Shiny app started")
  private$state <- "running"

  private$setupDebugging(debug)

  private$shinyWorkerId <- private$web$executeScript(
    'return Shiny.shinyapp.config.workerId'
  )
  if (identical(private$shinyWorkerId, ""))
    private$shinyWorkerId <- NA_character_

  private$shinyTestSnapshotBaseUrl <- private$web$executeScript(
    'if (Shiny.shinyapp.getTestSnapshotBaseUrl)
      return Shiny.shinyapp.getTestSnapshotBaseUrl({ fullUrl:true });
    else
      return null;'
  )

  "!DEBUG checking widget names"
  if (checkNames) self$checkUniqueWidgetNames()

  invisible(self)
}

#' @importFrom rematch re_match
#' @importFrom withr with_envvar

sd_startShiny <- function(self, private, path, seed) {

  assert_that(is_string(path))

  private$path <- normalizePath(path)

  libpath <- paste(deparse(.libPaths()), collapse = "")
  rcmd <- sprintf(
    paste(
      # Use collapse and c() so that if seed is NULL, we don't get ";;", which
      # would cause an error.
      collapse = ";",
      c(
        ".libPaths(c(%s, .libPaths()))",
        if (!is.null(seed)) sprintf("set.seed(%s)", seed),
        "shiny::runApp('%s', test.mode=TRUE)"
      )
    ),
    libpath,
    path
  )

  ## On windows, if is better to use single quotes
  rcmd <- gsub('"', "'", rcmd)

  Rexe <- if (is_windows()) "R.exe" else "R"
  Rbin <- file.path(R.home("bin"), Rexe)
  args <- c("-q", "-e", rcmd)

  tempfile_format <- tempfile("%s-", fileext = ".log")
  p <- with_envvar(
    c("R_TESTS" = NA),
    process$new(
      command = Rbin,
      args = args,
      stdout = sprintf(tempfile_format, "shiny-stdout"),
      stderr = sprintf(tempfile_format, "shiny-stderr"),
      supervise = TRUE
    )
  )

  "!DEBUG waiting for shiny to start"
  if (! p$is_alive()) {
    stop(
      "Failed to start shiny. Error: ",
      strwrap(readLines(p$get_error_file()))
    )
  }

  "!DEBUG finding shiny port"
  ## Try to read out the port, keep trying for 10 seconds
  for (i in 1:50) {
    err_lines <- readLines(p$get_error_file())

    if (!p$is_alive()) {
      stop("Error starting application:\n", paste(err_lines, collapse = "\n"))
    }
    if (any(grepl("Listening on http", err_lines))) break

    Sys.sleep(0.2)
  }
  if (i == 50) {
    stop("Cannot find shiny port number. Error:\n", paste(err_lines, collapse = "\n"))
  }

  line <- err_lines[grepl("Listening on http", err_lines)]
  m <- re_match(text = line, "https?://(?<host>[^:]+):(?<port>[0-9]+)")

  "!DEBUG shiny up and running, port `m[, 'port']`"

  url <- sub(".*(https?://.*)", "\\1", line)
  private$setShinyUrl(url)

  private$shinyProcess <- p
}

sd_getShinyUrl <- function(self, private) {
  paste0(
    private$shinyUrlProtocol, "://", private$shinyUrlHost,
    if (!is.null(private$shinyUrlPort)) paste0(":", private$shinyUrlPort),
    private$shinyUrlPath
  )
}

sd_setShinyUrl <- function(self, private, url) {
  res <- parse_url(url)

  if (nzchar(res$port)) {
    res$port <- as.integer(res$port)
    assert_that(is_port(res$port))
  } else {
    res$port <- NULL
  }

  res$path <- if (nzchar(res$path)) res$path else "/"

  assert_that(is_host(res$host))
  assert_that(is_url_path(res$path))

  private$shinyUrlProtocol <- res$protocol
  private$shinyUrlHost     <- res$host
  private$shinyUrlPort     <- res$port
  private$shinyUrlPath     <- res$path
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


sd_finalize <- function(self, private) {
  if (isTRUE(private$cleanLogs)) {
    unlink(private$shinyProcess$get_output_file())
    unlink(private$shinyProcess$get_error_file())
  }
}
