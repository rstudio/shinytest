#' A Shiny Widget
#'
#' @description
#' A `Widget` object represents a Shiny input or output control, and provides
#' methods for finer grained interaction.
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
    #' @description retrieve the underlying HTML for a widget
    getHtml = function() {
      private$element$executeScript("return arguments[0].outerHTML;")
    },
    #' @description Widget type, e.g. `textInput`, `selectInput`.
    getType = function() private$type,
    #' @description Is this an input or output control?
    getIoType = function() private$iotype,
    #' @description Is this an input control?
    isInput = function() private$iotype == "input",
    #' @description Is this an output control?
    isOutput = function() private$iotype == "output",

    #' @description Get current value of control.
    getValue = function(){
      "!DEBUG widget_getValue `private$name`"

      if (private$iotype == "input") {
        res <- private$element$executeScript(
          "var el = $(arguments[0]);
           return el.data('shinyInputBinding').getValue(el[0]);"
        )
      } else {
        res <- switch(private$type,
          htmlOutput = private$element$executeScript("return $(arguments[0]).html();"),
          verbatimTextOutput = private$element$getText(),
          textOutput = private$element$getText(),
          abort(paste0("getValue is not implemented for ", private$type))
        )
      }

      # Post-process, if needed
      res <- switch(private$type,
        checkboxGroupInput = as.character(unlist(res)),
        dateInput = as.Date(res),
        dateRangeInput = as.Date(unlist(res)),
        sliderInput = as.numeric(unlist(res)),
        res
      )

      res
    },

    #' @description Set value of control.
    #' @param value Value to set for the widget.
    setValue = function(value) {
      "!DEBUG widget_setValue `private$name`"
      if (private$iotype == "output") {
        abort("Cannot set values of output widgets")
      }

      # Preprocess value
      value <- switch(private$type,
        dateRangeInput = list(start = value[1], end = value[2]),
        radioButtons = if (!is.null(value)) as.character(value),
        value
      )

      setValueScript <-"
        var el = $(arguments[0]);
        var val = arguments[1];
        el.data('shinyInputBinding').setValue(el[0], val);
        el.trigger('change');
      "
      private$element$executeScript(setValueScript, value)

      invisible(self)
    },

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
        abort("'listTabs' only works for 'tabsetPanel' Widgets")
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
