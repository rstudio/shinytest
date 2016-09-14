
#' Class for a Shiny widget
#'
#' @section Usage:
#' \preformatted{w <- app$find_widget(name,
#'     iotype = c("auto", "input", "output"))
#'
#' w$get_name()
#' w$get_element()
#' w$get_type()
#' w$get_iotype()
#' w$in_input()
#' w$is_output()
#'
#' w$get_value()
#' w$set_value(value)
#'
#' w$send_keys(keys)
#' }
#'
#' @section Arguments:
#' \describe{
#'   \item{app}{A \code{\link{shinyapp}} object.}
#'   \item{w}{A \code{widget} object.}
#'   \item{name}{Name of a Shiny widget.}
#'   \item{iotype}{Character scalar, whether the widget is \sQuote{input}
#'     or \sQuote{output}. The default \sQuote{auto} value works well,
#'     provided that widgets have unique names. (Shiny allows an input
#'     and an output widget with the same name.)}
#'   \item{value}{Value to set for the widget. Its interpretation depends
#'     on the type of the widget, see details below.}
#'   \item{keys}{Keys to send to the widget. See the \code{send_keys}
#'     method of the \code{\link[webdriver]{element}} class in the
#'     \code{webdriver} package.}
#' }
#'
#' @section Details:
#'
#' A \code{widget} object represents a Shiny input or output widget.
#' \code{app$find_widget} creates a widget object from a
#' \code{\link{shinyapp}} object.
#'
#' \code{w$get_name()} returns the name of the widget.
#'
#' \code{w$get_element()} returns an HTML element. This is an
#' \code{\link[webdriver]{element}} object from the \code{webdriver}
#' package.
#'
#' \code{w$get_type()} returns the type of the widget, possible values
#' are \code{textInput}, \code{selectInput}, etc.
#'
#' \code{w$get_iotype()} returns \sQuote{input} or \sQuote{output},
#' whether the widget is an input or output widget.
#'
#' \code{w$is_input()} returns \code{TRUE} for input widgets, \code{FALSE}
#' otherwise.
#'
#' \code{w$is_output()} returns \code{TRUE} for output widgets, \code{FALSE}
#' otherwise.
#'
#' \code{w$get_value()} returns the value of the widget. The exact type
#' returned depends on the type of the widget. TODO: list widgets and their
#' return types.
#'
#' \code{w$set_value()} sets the value of the widget, through the web
#' browser. Different widget types expect different different \code{value}
#' arguments. TODO: list widgets and types.
#'
#' \code{w$send_keys} sends the specified keys to the HTML element of the
#' widget.
#'
#' @name widget
#' @examples{
#'
#' }
NULL

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
      widget_set_value(self, private, value),

    send_keys = function(keys)
      widget_send_keys(self, private, keys)

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

widget_send_keys <- function(self, private, keys) {
  private$element$send_keys(keys)
}
