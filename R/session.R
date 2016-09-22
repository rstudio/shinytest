
app_get_url <- function(self, private) {
  private$web$get_url()
}

app_go_back <- function(self, private) {
  private$web$go_back()
  invisible(self)
}

app_refresh <- function(self, private) {
  private$web$refresh()
  invisible(self)
}

app_get_title <- function(self, private) {
  private$web$get_title()
}

app_get_source <- function(self, private) {
  private$web$get_source()
}

app_take_screenshot <- function(self, private, file) {
  private$web$take_screenshot(file)
}

app_find_element <- function(self, private, css, link_text,
                             partial_link_text, xpath) {
  private$web$find_element(css, link_text, partial_link_text, xpath)
}

app_find_elements <- function(self, private, css, link_text,
                              partial_link_text, xpath) {
  private$web$find_elements(css, link_text, partial_link_text, xpath)
}
