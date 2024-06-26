
#' @importFrom debugme debugme

.onLoad <- function(libname, pkgname) {
  debugme()

  packageStartupMessage(
    "IMPORTANT! shinytest is deprecated and may not work with shiny>1.8.1.1.\n",
    "Please switch to shinytest2.\n",
    "See https://rstudio.github.io/shinytest2/articles/z-migration.html"
  )

  # This will issue a message if phantomjs isn't found, converting the regular
  # message to a packageStartupMessage.
  convert_message_to_package_startup_message({
    find_phantom()
  })
}


# Evaluate an expression, and if it emits any messsages, convert them to
# packageStartupMessage.
convert_message_to_package_startup_message <- function(expr) {
  withCallingHandlers(
    force(expr),
    message = function(cnd) {
      packageStartupMessage(conditionMessage(cnd))
      maybe_restart("muffleMessage")
    }
  )
}


# This is equivalent to tryInvokeRestart, but that function is available only in
# R 4.0 and above.
maybe_restart <- function(restart) {
  if (!is.null(findRestart(restart))) {
    invokeRestart(restart)
  }
}
