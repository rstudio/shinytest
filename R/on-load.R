
#' @importFrom debugme debugme

.onLoad <- function(libname, pkgname) {
  debugme()

  # This will issue a message if phantomjs isn't found.
  find_phantom()
}
