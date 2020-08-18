#' A Shiny Widget
#'
#' A `Widget` object represents a Shiny input or output control.
#'
#' @importFrom R6 R6Class
Widget <- R6Class(
  "Widget",
  private = list(
    name = NULL,     # name in shiny
    element = NULL,  # HTML element with name as id
    type = NULL,     # e.g. selectInput
    iotype = NULL    # "input" or "output"
  ),
  public = list(
    #' @description Create new `Widget`
    #' @param name Name of a Shiny widget.
    #' @param element [webdriver::Element]
    #' @param type Widget type
    #' @param iotype Input/output type.
    initialize = function(name, element, type, iotype = c("input", "output")) {
      iotype <- match.arg(iotype)

      private$name <- name
      private$element <- element
      private$type <- type
      private$iotype <- iotype
      invisible(self)
    },

    #' @description Control id (i.e. `inputId` or `outputId` that control
    #'   was created with).
    getName = function() private$name,
    #' @description Underlying [webdriver::Element()] object.
    getElement = function() private$element,
    #' @description Widget type, e.g. `textInput`, `selectInput`.
    getType = function() private$type,
    #' @description Is this an input or output control?
    getIoType = function() private$iotype,
    #' @description Is this an input control?
    isInput = function() private$iotype == "input",
    #' @description Is this an output control?
    isOutput = function() private$iotype == "output",

    #' @description Get current value of control.
    getValue = function()
      widget_getValue(self, private),

    #' @description Set value of control.
    #' @param value Value to set for the widget.
    setValue = function(value)
      widget_setValue(self, private, value),

    #' @description scrolls the element into view, then clicks the in-view
    #'   centre point of it.
    #' @return self, invisibly.
    click = function() {
      private$element$click()
      invisible(self)
    },

    #' @description Send specified key presses to control.
    #' @param keys Keys to send to the widget or the app. See [webdriver::key]
    #'   for how to specific special keys.
    sendKeys = function(keys) {
      "!DEBUG widget_sendKeys `private$name`"
      private$element$sendKeys(keys)
    },

    #' @description Lists the tab names of a [shiny::tabsetPanel()].
    #'  It fails for other types of widgets.
    listTabs = function() {
      if (private$type != "tabsetPanel") {
        stop("'listTabs' only works for 'tabsetPanel' Widgets")
      }
      tabs <- private$element$findElements("li a")
      vapply(tabs, function(t) t$getData("value"), "")
    },

    #' @description Upload a file to a [shiny::fileInput()].
    #'  It fails for other types of widgets.
    #' @param filename Path to file to upload
    uploadFile = function(filename) {
      private$element$uploadFile(filename = filename)
    }
  )
)
