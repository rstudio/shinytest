
#' @importFrom R6 R6Class
#' @export

shinyapp <- R6Class(
  "shinyapp",

  public = list(

    initialize = function(path = ".")
      app_initialize(self, private, path),

    value = function(name)
      app_value(self, private, name),

    update = function(...)
      app_update(self, private, ...),

    stop = function()
      app_stop(self, private)

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

app_update <- function(self, private, ...) {
  ## TODO
}

app_stop <- function(self, private) {
  private$shiny_process$kill()
  private$phantom_process$kill()
  private$state <- "stopped"
  invisible(self)
}
