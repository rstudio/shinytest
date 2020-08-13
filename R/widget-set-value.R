widget_setValue <- function(self, private, value) {
  "!DEBUG widget_setValue `private$name`"
  if (private$iotype == "output") {
    stop("Cannot set values of output widgets")
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
}
