
widget_set_value <- function(self, private, value) {

  if (private$iotype == "output") {
    stop("Cannot set values of output widgets")
  }

  if (!is.null(widget_set_value_preprocess[[private$type]])) {
    value <-
      widget_set_value_preprocess[[private$type]](value, self, private)
  }

  if (!is.null(widget_set_value_funcs[[private$type]])) {
    widget_set_value_funcs[[private$type]](value, self, private)

  } else {
    private$element$execute_script(
      "var el = $(arguments[0]);
       var val = arguments[1];
       el.data('shinyInputBinding').setValue(el[0], val);
       el.trigger('change');",
      value
    )
  }

  invisible(self)
}

widget_set_value_preprocess <- list(

  dateRangeInput = function(value, self, private) {
    list(start = value[1], end = value[2])
  },

  radioButtons = function(value, self, private) {
    if (!is.null(value)) as.character(value)
  }
)

widget_set_value_funcs <- list()
