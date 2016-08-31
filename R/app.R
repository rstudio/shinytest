
#' Class to manage shiny app and phantom.js processes for testing
#'
#' @section Usage:
#'
#' TODO
#'
#' @section Arguments:
#'
#' TODO
#'
#' @section Details:
#'
#' TODO
#'
#' @importFrom R6 R6Class
#' @name shinyapp
NULL

#' @export

shinyapp <- R6Class(
  "shinyapp",

  public = list(

    initialize = function(path = ".", load_timeout = 5000)
      app_initialize(self, private, path, load_timeout),

    stop = function()
      app_stop(self, private),

    value = function(name)
      app_value(self, private, name),

    focus_on = function(name)
      app_focus_on(self, private, name),

    send_keys = function(name = NULL, keys)
      app_send_keys(self, private, name, keys),

    set_window_size = function(width, height)
      app_set_window_size(self, private, width, height),

    ## These are just forwarded to the webdriver session

    get_url = function()
      app_get_url(self, private),

    go_back = function()
      app_go_back(self, private),

    refresh = function()
      app_refresh(self, private),

    get_title = function()
      app_get_title(self, private),

    get_source = function()
      app_get_source(self, private),

    take_screenshot = function(file = NULL)
      app_take_screenshot(self, private, file),

    find_element = function(css = NULL, link_text = NULL,
      partial_link_text = NULL, xpath = NULL)
      app_find_element(self, private, css, link_text, partial_link_text,
                       xpath),

    find_widget = function(name, iotype = c("auto", "input", "output"))
      app_find_widget(self, private, name, match.arg(iotype)),

    expect_update = function(output, ..., timeout = 3000,
      iotype = c("auto", "input", "output"))
      app_expect_update(self, private, output, ..., timeout = timeout,
                        iotype = match.arg(iotype))
  ),

  private = list(

    state = "stopped",                  # stopped or running
    path = NULL,                        # Shiny app path
    shiny_host = NULL,                  # usually 127.0.0.1
    shiny_port = NULL,
    shiny_process = NULL,               # process object
    phantom_port = NULL,
    phantom_process = NULL,             # process object
    web = NULL,                         # webdriver session

    start_phantomjs = function()
      app_start_phantomjs(self, private),

    start_shiny = function(path)
      app_start_shiny(self, private, path),

    get_shiny_url = function()
      app_get_shiny_url(self, private)
  )
)

app_value <- function(self, private, name) {
  ## TODO
}

app_focus_on <- function(self, private, name) {

}

app_send_keys <- function(self, private, name, keys) {

}

app_set_window_size <- function(self, private, width, height) {

}

app_stop <- function(self, private) {
  private$shiny_process$kill()
  private$phantom_process$kill()
  private$state <- "stopped"
  invisible(self)
}
