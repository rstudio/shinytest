widget_getValue <- function(self, private) {
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
      stop("getValue is not implemented for ", private$type)
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
}
