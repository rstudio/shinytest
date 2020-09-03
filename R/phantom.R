#' Checks for/install dependencies
#'
#' `dependenciesInstalled()` that all the required system dependency,
#' PhantomJS, is installed, and `installDependencies()` installs it if needed.
#' For more information about where PhantomJS will be installed
#' see [webdriver::install_phantomjs()].
#'
#' @return `TRUE` when all dependencies are fulfilled; otherwise, `FALSE`.
#' @export
#' @keywords internal
dependenciesInstalled <- function() {
  !is.null(find_phantom(quiet = TRUE))
}

#' @export
#' @rdname dependenciesInstalled
installDependencies <- function() {
  if (is.null(find_phantom(quiet = TRUE))) {
    webdriver::install_phantomjs()
  }
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
      inform(c(
        "shinytest requires PhantomJS to record and run tests.",
        "To install it, run shinytest::installDependencies()",
        "If it is installed, please check it is available on the PATH"
      ))
    }
    return(NULL)
  }
  path.expand(path)
}



phantom_env <- new.env()

#' @importFrom webdriver run_phantomjs

get_phantomPort <- function(timeout = 5000) {
  if (! is_phantom_alive()) {
    ph <- run_phantomjs(timeout = timeout)
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
