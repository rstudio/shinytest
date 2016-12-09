
#' Class for a Shiny widget
#'
#' @section Usage:
#' \preformatted{w <- app$findWidget(name,
#'     iotype = c("auto", "input", "output"))
#'
#' w$get_name()
#' w$get_element()
#' w$get_type()
#' w$get_iotype()
#' w$in_input()
#' w$is_output()
#'
#' w$getValue()
#' w$setValue(value)
#'
#' w$sendKeys(keys)
#'
#' w$list_tabs()
#' }
#'
#' @section Arguments:
#' \describe{
#'   \item{app}{A \code{\link{ShinyDriver}} object.}
#'   \item{w}{A \code{widget} object.}
#'   \item{name}{Name of a Shiny widget.}
#'   \item{iotype}{Character scalar, whether the widget is \sQuote{input}
#'     or \sQuote{output}. The default \sQuote{auto} value works well,
#'     provided that widgets have unique names. (Shiny allows an input
#'     and an output widget with the same name.)}
#'   \item{value}{Value to set for the widget. Its interpretation depends
#'     on the type of the widget, see details below.}
#'   \item{keys}{Keys to send to the widget. See the \code{sendKeys}
#'     method of the \code{\link[webdriver]{element}} class in the
#'     \code{webdriver} package.}
#' }
#'
#' @section Details:
#'
#' A \code{widget} object represents a Shiny input or output widget.
#' \code{app$findWidget} creates a widget object from a
#' \code{\link{ShinyDriver}} object.
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
#' \code{w$getValue()} returns the value of the widget. The exact type
#' returned depends on the type of the widget. TODO: list widgets and their
#' return types.
#'
#' \code{w$setValue()} sets the value of the widget, through the web
#' browser. Different widget types expect different different \code{value}
#' arguments. TODO: list widgets and types.
#'
#' \code{w$sendKeys} sends the specified keys to the HTML element of the
#' widget.
#'
#' \code{w$list_tabs} lists the tab names of a \code{tabsetPanel} widget.
#' It fails for other types of widgets.
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

    getValue = function()
      widget_getValue(self, private),

    setValue = function(value)
      widget_setValue(self, private, value),

    sendKeys = function(keys)
      widget_sendKeys(self, private, keys),

    list_tabs = function()
      widget_list_tabs(self, private),

    upload_file = function(filename)
      widget_upload_file(self, private, filename)

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

widget_sendKeys <- function(self, private, keys) {
  "!DEBUG widget_sendKeys `private$name`"
  private$element$sendKeys(keys)
}

widget_list_tabs <- function(self, private) {
  if (private$type != "tabsetPanel") {
    stop("'list_tabs' only works for 'tabsetPanel' widgets")
  }
  tabs <- private$element$find_elements("li a")
  vapply(tabs, function(t) t$get_data("value"), "")
}

widget_upload_file <- function(self, private, filename) {
  private$element$upload_file(
    filename = filename
  )
}
