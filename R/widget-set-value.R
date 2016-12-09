
widget_setValue <- function(self, private, value) {

  "!DEBUG widget_setValue `private$name`"

  if (private$iotype == "output") {
    stop("Cannot set values of output widgets")
  }

  if (!is.null(widget_setValuePreprocess[[private$type]])) {
    value <-
      widget_setValuePreprocess[[private$type]](value, self, private)
  }


  private$element$executeScript(setValueScript, value)

  invisible(self)
}

widget_setValuePreprocess <- list(

  dateRangeInput = function(value, self, private) {
    list(start = value[1], end = value[2])
  },

  radioButtons = function(value, self, private) {
    if (!is.null(value)) as.character(value)
  }
)

setValueScript <-
  "var el = $(arguments[0]);
   var val = arguments[1];
   el.data('shinyInputBinding').setValue(el[0], val);
   el.trigger('change');"
