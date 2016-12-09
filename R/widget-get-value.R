
widget_getValue <- function(self, private) {

  "!DEBUG widget_getValue `private$name`"

  res <- if (private$iotype == "input") {
    private$element$executeScript(
      "var el = $(arguments[0]);
       return el.data('shinyInputBinding').getValue(el[0]);"
    )

  } else {
    if (is.null(widget_getValueFuncs[[private$type]])) {
      stop("getValue is not implemented for ", private$type)
    } else {
      widget_getValueFuncs[[private$type]](self, private)
    }
  }

  if (! is.null(widget_getValuePostprocess[[private$type]])) {
    res <- widget_getValuePostprocess[[private$type]](res)
  }
  res
}

widget_getValueFuncs <- list(

  htmlOutput = function(self, private) {
    private$element$executeScript("return $(arguments[0]).html();")
  },

  verbatimTextOutput = function(self, private) {
    private$element$getText()
  },

  textOutput = function(self, private) {
    private$element$getText()
  }
)

widget_getValuePostprocess <- list(
  checkboxGroupInput = function(x) as.character(unlist(x)),
  dateInput = function(x) as.Date(x),
  dateRangeInput = function(x) as.Date(unlist(x)),
  sliderInput = function(x) as.numeric(unlist(x))
)
