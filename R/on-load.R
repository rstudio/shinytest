
#' @importFrom debugme debugme

.onLoad <- function(libname, pathname) {
  debugme()

  shiny::addResourcePath(
    "shinytest",
    system.file("js", package = "shinytest")
  )
}
