
app_getUrl <- function(self, private) {
  "!DEBUG app_getUrl"
  private$web$getUrl()
}

app_goBack <- function(self, private) {
  "!DEBUG app_goBack"
  private$web$goBack()
  invisible(self)
}

app_refresh <- function(self, private) {
  "!DEBUG refresh"
  private$web$refresh()
  invisible(self)
}

app_getTitle <- function(self, private) {
  "!DEBUG app_getTitle"
  private$web$getTitle()
}

app_getSource <- function(self, private) {
  "!DEBUG app_getSource"
  private$web$getSource()
}

app_takeScreenshot <- function(self, private, file) {
  "!DEBUG app_takeScreenshot"
  private$web$takeScreenshot(file)
}

app_findElement <- function(self, private, css, link_text,
                             partialLinkText, xpath) {
  "!DEBUG app_findElement '`css %||% link_text %||% partialLinkText %||% xpath`'"
  private$web$findElement(css, link_text, partialLinkText, xpath)
}

app_findElements <- function(self, private, css, link_text,
                              partialLinkText, xpath) {
  "!DEBUG app_findElements '`css %||% link_text %||% partialLinkText %||% xpath`'"
  private$web$findElements(css, link_text, partialLinkText, xpath)
}
