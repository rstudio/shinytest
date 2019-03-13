#' Checks all dependencies are installed
#'
#' Checks that all the required system dependencies are installed properly,
#' returns. If dependencies are missing, consider running
#' \link{installDependencies}.
#'
#' @return \code{TRUE} when all dependencies are fulfilled; otherwise,
#'   \code{FALSE}.
#'
#' @seealso \code{\link{installDependencies}} to install missing dependencies.
#'
#' @export
dependenciesInstalled <- function() {
  !is.null(find_phantom(quiet = TRUE))
}

#' Installs missing dependencies
#'
#' Installs all the required system depencies to record and run tests. This will
#' install a headless web browser, PhantomJS.
#'
#'
#' @seealso \code{\link{dependenciesInstalled}} to check if dependencies are
#'   missing. For more information about where PhantomJS will be installed, see
#'   \code{\link[webdriver]{install_phantomjs}}.
#'
#' @examples
#' \dontrun{
#'
#' if (!dependenciesInstalled() &&
#'     identical(menu(c("Yes", "No"), "Install missing dependencies?"), 1L)) {
#'   installDependencies()
#' }
#'
#' }
#'
#' @export
installDependencies <- function() {
  if (is.null(find_phantom(quiet = TRUE))) {
    webdriver::install_phantomjs()
  }
}
