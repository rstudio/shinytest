
#' Class for a Shiny widget
#'
#' @section Usage:
#' \preformatted{w <- app$findWidget(name,
#'     iotype = c("auto", "input", "output"))
#'
#' w$getName()
#' w$getElement()
#' w$getType()
#' w$getIoType()
#' w$isInput()
#' w$isOutput()
#'
#' w$getValue()
#' w$setValue(value)
#'
#' w$sendKeys(keys)
#'
#' w$listTabs()
#' }
#'
#' @section Arguments:
#' \describe{
#'   \item{app}{A \code{\link{ShinyDriver}} object.}
#'   \item{w}{A \code{Widget} object.}
#'   \item{name}{Name of a Shiny widget.}
#'   \item{iotype}{Character scalar, whether the widget is \sQuote{input}
#'     or \sQuote{output}. The default \sQuote{auto} value works well,
#'     provided that widgets have unique names. (Shiny allows an input
#'     and an output widget with the same name.)}
#'   \item{value}{Value to set for the widget. Its interpretation depends
#'     on the type of the widget, see details below.}
#'   \item{keys}{Keys to send to the widget. See the \code{sendKeys}
#'     method of the \code{\link[webdriver]{Element}} class in the
#'     \code{webdriver} package.}
#' }
#'
#' @section Details:
#'
#' A \code{Widget} object represents a Shiny input or output widget.
#' \code{app$findWidget} creates a widget object from a
#' \code{\link{ShinyDriver}} object.
#'
#' \code{w$getName()} returns the name of the widget.
#'
#' \code{w$getElement()} returns an HTML element. This is an
#' \code{\link[webdriver]{Element}} object from the \code{webdriver}
#' package.
#'
#' \code{w$getType()} returns the type of the widget, possible values
#' are \code{textInput}, \code{selectInput}, etc.
#'
#' \code{w$getIoType()} returns \sQuote{input} or \sQuote{output},
#' whether the widget is an input or output widget.
#'
#' \code{w$isInput()} returns \code{TRUE} for input widgets, \code{FALSE}
#' otherwise.
#'
#' \code{w$isOutput()} returns \code{TRUE} for output widgets, \code{FALSE}
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
#' \code{w$listTabs} lists the tab names of a \code{tabsetPanel} widget.
#' It fails for other types of widgets.
#'
#' @name Widget
#' @examples{
#'
#' }
NULL

#' @importFrom R6 R6Class

Widget <- R6Class(
  "Widget",

  public = list(
    initialize = function(name, element, type,
      iotype = c("input", "output"))
      widget_initialize(self, private, name, element, type,
                        match.arg(iotype)),

    getName = function() private$name,
    getElement = function() private$element,
    getType = function() private$type,
    getIoType = function() private$iotype,
    isInput = function() private$iotype == "input",
    isOutput = function() private$iotype == "output",

    getValue = function()
      widget_getValue(self, private),

    setValue = function(value)
      widget_setValue(self, private, value),

    sendKeys = function(keys)
      widget_sendKeys(self, private, keys),

    listTabs = function()
      widget_listTabs(self, private),

    uploadFile = function(filename)
      widget_uploadFile(self, private, filename)

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

widget_listTabs <- function(self, private) {
  if (private$type != "tabsetPanel") {
    stop("'listTabs' only works for 'tabsetPanel' Widgets")
  }
  tabs <- private$element$findElements("li a")
  vapply(tabs, function(t) t$getData("value"), "")
}

widget_uploadFile <- function(self, private, filename) {
  private$element$uploadFile(
    filename = filename
  )
}
