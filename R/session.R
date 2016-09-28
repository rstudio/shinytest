
app_get_url <- function(self, private) {
  "!DEBUG app_get_url"
  private$web$get_url()
}

app_go_back <- function(self, private) {
  "!DEBUG app_go_back"
  private$web$go_back()
  invisible(self)
}

app_refresh <- function(self, private) {
  "!DEBUG refresh"
  private$web$refresh()
  invisible(self)
}

app_get_title <- function(self, private) {
  "!DEBUG app_get_title"
  private$web$get_title()
}

app_get_source <- function(self, private) {
  "!DEBUG app_get_source"
  private$web$get_source()
}

app_take_screenshot <- function(self, private, file) {
  "!DEBUG app_take_screenshot"
  private$web$take_screenshot(file)
}

app_find_element <- function(self, private, css, link_text,
                             partial_link_text, xpath) {
  "!DEBUG app_find_element '`css %||% link_text %||% partial_link_text %||% xpath`'"
  private$web$find_element(css, link_text, partial_link_text, xpath)
}

app_find_elements <- function(self, private, css, link_text,
                              partial_link_text, xpath) {
  "!DEBUG app_find_elements '`css %||% link_text %||% partial_link_text %||% xpath`'"
  private$web$find_elements(css, link_text, partial_link_text, xpath)
}
