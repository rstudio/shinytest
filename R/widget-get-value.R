
widget_get_value <- function(self, private) {

  "!DEBUG widget_get_value `private$name`"

  res <- if (private$iotype == "input") {
    private$element$execute_script(
      "var el = $(arguments[0]);
       return el.data('shinyInputBinding').getValue(el[0]);"
    )

  } else {
    if (is.null(widget_get_value_funcs[[private$type]])) {
      stop("get_value is not implemented for ", private$type)
    } else {
      widget_get_value_funcs[[private$type]](self, private)
    }
  }

  if (! is.null(widget_get_value_postprocess[[private$type]])) {
    res <- widget_get_value_postprocess[[private$type]](res)
  }
  res
}

widget_get_value_funcs <- list(

  htmlOutput = function(self, private) {
    private$element$execute_script("return $(arguments[0]).html();")
  },

  verbatimTextOutput = function(self, private) {
    private$element$get_text()
  },

  textOutput = function(self, private) {
    private$element$get_text()
  }
)

widget_get_value_postprocess <- list(
  checkboxGroupInput = function(x) as.character(unlist(x)),
  dateInput = function(x) as.Date(x),
  dateRangeInput = function(x) as.Date(unlist(x)),
  sliderInput = function(x) as.numeric(unlist(x))
)
