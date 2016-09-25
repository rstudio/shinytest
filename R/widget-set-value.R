
widget_set_value <- function(self, private, value) {

  "!DEBUG widget_set_value"

  if (private$iotype == "output") {
    stop("Cannot set values of output widgets")
  }

  if (!is.null(widget_set_value_preprocess[[private$type]])) {
    value <-
      widget_set_value_preprocess[[private$type]](value, self, private)
  }


  private$element$execute_script(set_value_script, value)

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

set_value_script <-
  "var el = $(arguments[0]);
   var val = arguments[1];
   el.data('shinyInputBinding').setValue(el[0], val);
   el.trigger('change');"
