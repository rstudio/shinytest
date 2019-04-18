
#' @importFrom callr process
#' @importFrom webdriver Session

sd_initialize <- function(self, private, path, loadTimeout, checkNames,
                          debug, phantomTimeout, seed, cleanLogs,
                          shinyOptions) {

  private$cleanLogs <- cleanLogs

  self$logEvent("Start ShinyDriver initialization")

  if (is.null(find_phantom())) {
    stop("PhantomJS not found.")
  }

  "!DEBUG get phantom port (starts phantom if not running)"
  self$logEvent("Getting PhantomJS port")
  private$phantomPort <- get_phantomPort(timeout = phantomTimeout)

  if (grepl("^http(s?)://", path)) {
    private$setShinyUrl(path)

  } else {
    "!DEBUG starting shiny app from path"
    self$logEvent("Starting Shiny app")
    private$startShiny(path, seed, loadTimeout, shinyOptions)
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
  js <- read_utf8(js_file)
  private$web$executeScript(js)

  "!DEBUG wait until Shiny starts"
  self$logEvent("Waiting until Shiny app starts")
  load_ok <- private$web$waitFor(
    'window.shinytest && window.shinytest.ready === true',
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

sd_startShiny <- function(self, private, path, seed, loadTimeout, shinyOptions) {

  assert_that(is_string(path))

  private$path <- normalizePath(path)

  if (is.null(shinyOptions$port)) {
    shinyOptions$port <- random_open_port()
  }

  tempfile_format <- tempfile("%s-", fileext = ".log")

  # the RNG kind should inherit from the parent process
  rng_kind <- RNGkind()

  p <- with_envvar(
    c("R_TESTS" = NA),
    callr::r_bg(
      function(path, shinyOptions, rmd, seed, rng_kind) {

        if (!is.null(seed)) {
          # Prior to R 3.6, RNGkind has 2 args, otherwise it has 3
          do.call(RNGkind, as.list(rng_kind))
          set.seed(seed);
          shiny:::withPrivateSeed(set.seed(seed + 11))
        }

        options(shiny.testmode = TRUE)

        if (rmd) {
          # Shiny document
          rmarkdown::run(path, shiny_args = shinyOptions)
        } else {
          # Normal shiny app
          do.call(shiny::runApp, c(path, shinyOptions))
        }
      },
      args = list(path, shinyOptions, is_rmd(path), seed, rng_kind),
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
  ## Try to read out the port. Try 5 times/sec, until timeout.
  max_i <- loadTimeout / 1000 * 5
  for (i in seq_len(max_i)) {
    err_lines <- readLines(p$get_error_file())

    if (!p$is_alive()) {
      stop("Error starting application:\n", paste(err_lines, collapse = "\n"))
    }
    if (any(grepl("Listening on http", err_lines))) break

    Sys.sleep(0.2)
  }
  if (i == max_i) {
    stop("Cannot find shiny port number. Error:\n", paste(err_lines, collapse = "\n"))
  }

  line <- err_lines[grepl("Listening on http", err_lines)]
  m <- re_match(text = line, "https?://(?<host>[^:]+):(?<port>[0-9]+)")

  # m[, 'port'] should be the same as port, but we don't enforce it.
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
find_phantom <- function(quiet = FALSE) {
  path <- Sys.which( "phantomjs" )
  if (path != "") return(path)

  for (d in phantom_paths()) {
    exec <- if (is_windows()) "phantomjs.exe" else "phantomjs"
    path <- file.path(d, exec)
    if (utils::file_test("-x", path)) break else path <- ""
  }

  if (path == "") {
    if (!quiet) {
      # It would make the most sense to throw an error here. However, that would
      # cause problems with CRAN. The CRAN checking systems may not have phantomjs
      # and may not be capable of installing phantomjs (like on Solaris), and any
      # packages which use webdriver in their R CMD check (in examples or vignettes)
      # will get an ERROR. We'll issue a message and return NULL; other
      message(
        "shinytest requires a headless web browser (PhantomJS) to record and run tests.\n",
        "To install it, run shinytest::installDependencies()\n",
        "If it is installed, please make sure the phantomjs executable ",
        "can be found via the PATH variable."
      )
    }
    return(NULL)
  }
  path.expand(path)
}


sd_finalize <- function(self, private) {
  self$stop()

  if (isTRUE(private$cleanLogs)) {
    unlink(private$shinyProcess$get_output_file())
    unlink(private$shinyProcess$get_error_file())
  }
}
