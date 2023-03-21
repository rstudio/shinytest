
#' @importFrom debugme debugme

.onLoad <- function(libname, pkgname) {
  debugme()

  # This will issue a message if phantomjs isn't found, converting the regular
  # message to a packageStartupMessage.
  withCallingHandlers(
    find_phantom(),
    message = function(cnd) {
      packageStartupMessage(conditionMessage(cnd), appendLF = FALSE)
      tryInvokeRestart("muffleMessage")
    }
  )
}
