
#' @importFrom R6 R6Class

widget <- R6Class(
  "widget",

  public = list(
    initialize = function(name, element, type,
      iotype = c("input", "output"))
      widget_initialize(self, private, name, element, type,
                        match.arg(iotype)),

    get_name = function() private$name,
    get_element = function() private$element,
    get_type = function() private$type,
    get_iotype = function() private$iotype,
    is_input = function() private$iotype == "input",
    is_output = function() private$iotype == "output",

    get_value = function()
      widget_get_value(self, private),

    set_value = function(value)
      widget_set_value(self, private, value)
  ),

  private = list(
    name = NULL,                        # name in shiny
    element = NULL,                     # HTML element with name as id
    type = NULL,                        # e.g. selectInput
    iotype = NULL                       # "input" or "output"
  )
)

widget_initialize <- function(self, private, name, element, type, iotype) {
  private$name <- name
  private$element <- element
  private$type <- type
  private$iotype <- iotype
  invisible(self)
}

widget_set_value <- function(self, private, value) {
  ## TODO
}
