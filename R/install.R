#' Checks all dependencies are installed
#'
#' Checks that all the required system dependencies are installed properly,
#' returns. If dependencie are missing, consider running
#' \link{installDependencies}.
#'
#' @return \code{TRUE} when all dependencies are fullfilled; otherwise,
#'   \code{FALSE}.
#'
#' @seealso \code{\link{installDependencies}} to install missing dependencies.
#'
#' @export
dependenciesInstalled <- function() {
  !is.null(shinytest::find_phantom())
}

#' Installs missing dependencies
#'
#' Installs all the required system depencies to record and run tests.
#'
#'
#' @seealso \code{\link{dependenciesInstalled}} to check if dependencies are
#'   missing.
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
  if (!is.null(shinytest::find_phantom())) {
    webdriver::install_phantomjs()
  }
}