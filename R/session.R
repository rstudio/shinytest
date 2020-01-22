
sd_getUrl <- function(self, private) {
  "!DEBUG sd_getUrl"
  private$web$getUrl()
}

sd_goBack <- function(self, private) {
  "!DEBUG sd_goBack"
  private$web$goBack()
  invisible(self)
}

sd_refresh <- function(self, private) {
  "!DEBUG refresh"
  private$web$refresh()
  invisible(self)
}

sd_getTitle <- function(self, private) {
  "!DEBUG sd_getTitle"
  private$web$getTitle()
}

sd_getSource <- function(self, private) {
  "!DEBUG sd_getSource"
  private$web$getSource()
}

sd_takeScreenshot <- function(self, private, file) {
  "!DEBUG sd_takeScreenshot"
  self$logEvent("Taking screenshot")
  private$web$takeScreenshot(file)

  # On Windows, need to fix up the PNG resolution header to make it
  # consistent.
  if (is_windows()) {
    normalize_png_res_header(file)
  }
}

sd_findElement <- function(self, private, css, linkText,
                           partialLinkText, xpath) {
  "!DEBUG sd_findElement '`css %||% linkText %||% partialLinkText %||% xpath`'"
  private$web$findElement(css, linkText, partialLinkText, xpath)
}

sd_findElements <- function(self, private, css, linkText,
                            partialLinkText, xpath) {
  "!DEBUG sd_findElements '`css %||% linkText %||% partialLinkText %||% xpath`'"
  private$web$findElements(css, linkText, partialLinkText, xpath)
}
