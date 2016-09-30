client_initialize = function(self, private, shiny_url, load_timeout,
                             phantom_debug_level) {
  "!DEBUG start up phantomjs"
  private$start_phantomjs(phantom_debug_level)

  "!DEBUG create new phantomjs session"
  private$session <- session$new(port = private$phantom_port)

  "!DEBUG navigate to Shiny app"
  private$session$go(shiny_url)
  
  ## Set implicit timeout to zero. According to the standard it should
  ## be zero, but phantomjs uses about 200 ms
  private$session$set_timeout(implicit = 0)

  "!DEBUG wait until Shiny starts in client"
  load_ok <- private$session$wait_for(
    'window.shinytest && window.shinytest.connected === true',
    timeout = load_timeout
  )
  if (!load_ok) stop("Shiny app did not load in ", load_timeout, "ms")
}


#' Start phantomjs
#' 
#' It is not possible to start phantomjs on a randomized port currently, 
#' unfortunately.
#' 
#' `processx::process` will automatically kill it, once the client object is 
#' garbage collected.
#' 
#' @param self me
#' @param private dark side of me
#' @param debug_level debug level
#'   
#' @keywords internal

client_start_phantomjs <- function(self, private, debug_level) {
  phexe <- find_phantom()
  if (is.null(phexe)) stop("No phantom.js, exiting")

  private$phantom_port <- random_port()

  cmd <- paste0(
    shQuote(phexe), " --webdriver-loglevel=", debug_level,
    " --proxy-type=none --webdriver=127.0.0.1:", private$phantom_port
  )
  ph <- process$new(commandline = cmd)

  "!DEBUG waiting for phantom.js to start"
  if (! ph$is_alive()) {
    stop(
      "Failed to start phantomjs. Error: ",
      strwrap(ph$read_error_lines())
    )
  }
  "!DEBUG phantom.js started"

  ## Unfortunately we need to wait a bit for phantom to start
  for (i in 1:50) {
    l <- ph$read_output_lines(n = 1)
    if (length(l) > 0) break
    Sys.sleep(0.1)
  }

  private$phantom_process <- ph
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
