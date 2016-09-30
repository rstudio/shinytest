
client_get_url <- function(self, private) {
  "!DEBUG client_get_url"
  private$session$get_url()
}

client_go_back <- function(self, private) {
  "!DEBUG client_go_back"
  private$session$go_back()
  invisible(self)
}

client_refresh <- function(self, private) {
  "!DEBUG client_refresh"
  private$session$refresh()
  invisible(self)
}

client_get_title <- function(self, private) {
  "!DEBUG client_get_title"
  private$session$get_title()
}

client_get_source <- function(self, private) {
  "!DEBUG client_get_source"
  private$session$get_source()
}

client_take_screenshot <- function(self, private, file) {
  "!DEBUG client_take_screenshot"
  private$session$take_screenshot(file)
}

client_find_element <- function(self, private, css, link_text,
                                partial_link_text, xpath) {
  "!DEBUG client_find_element '`css %||% link_text %||% partial_link_text %||% xpath`'"
  private$session$find_element(css, link_text, partial_link_text, xpath)
}

client_find_elements <- function(self, private, css, link_text,
                                 partial_link_text, xpath) {
  "!DEBUG client_find_elements '`css %||% link_text %||% partial_link_text %||% xpath`'"
  private$session$find_elements(css, link_text, partial_link_text, xpath)
}
