
widget_get_value <- function(self, private) {
  widget_get_value_list[[private$type]](self, private)
}

## A button has no value, really
widget_get_value_actionButton <- function(self, private) {
  NULL
}

widget_get_value_checkboxInput <- function(self, private) {
  private$element$execute_script("return arguments[0].checked;")
}

widget_get_value_checkboxGroupInput <- function(self, private) {
  checked <- private$element$find_elements(
    xpath = ".//input[@type='checkbox'][boolean(@checked)]"
  )
  vapply(checked, function(c) c$get_value(), "")
}

widget_get_value_dateInput <- function(self, private) {
  del <- private$element$find_element(xpath = ".//input[@type='text']")
  as.Date(del$get_value())
}

widget_get_value_dateRangeInput <- function(self, private) {
  dels <- private$element$find_elements(xpath = ".//input[@type='text']")
  as.Date(vapply(dels, function(c) c$get_value(), ""))
}

widget_get_value_fileInput <- function(self, private) {
  stop("get_value is not yet implemented for fileInput")
  ## TODO
}

widget_get_value_numericInput <- function(self, private) {
  as.numeric(private$element$get_value())
}

widget_get_value_radioButtons <- function(self, private) {
  private$element$execute_script(
    "return $(arguments[0]).find('input:radio:checked').val();"
  )
}

widget_get_value_selectInput <- function(self, private) {
  private$element$execute_script("return $(arguments[0]).val();");
}

widget_get_value_sliderInput <- function(self, private) {
  if (! identical(private$element$get_data("type"), "double")) {
    res <- private$element$execute_script(
      "return $(arguments[0]).data('ionRangeSlider').result;"
    )
    as.numeric(res$from)

  } else {
    ## otherwise slider range
    res <- private$element$execute_script(
      "return $(arguments[0]).data('ionRangeSlider').result;"
    )
    as.numeric(c(res$from, res$to))
  }
}

widget_get_value_textInput <- function(self, private) {
  private$element$get_value()
}

widget_get_value_passwordInput <- function(self, private) {
  private$element$get_value()
}

widget_get_value_htmlOutput <- function(self, private) {
  private$element$execute_script("return $(arguments[0]).html();")
}

widget_get_value_plotOutput <- function(self, private) {
  stop("get_value is not yet implemented for plotOutput")
  ## TODO
}

widget_get_value_tableOutput <- function(self, private) {
  stop("get_value is not yet implemented for tableOutput")
  ## TODO
}

widget_get_value_verbatimTextOutput <- function(self, private) {
  private$element$get_text()
}

widget_get_value_textOutput <- function(self, private) {
  private$element$get_text()
}

widget_get_value_list = list(
  "actionButton"  = widget_get_value_actionButton,
  "checkboxInput" = widget_get_value_checkboxInput,
  "checkboxGroupInput" = widget_get_value_checkboxGroupInput,
  "dateInput" = widget_get_value_dateInput,
  "dateRangeInput" = widget_get_value_dateRangeInput,
  "fileInput" = widget_get_value_fileInput,
  "numericInput" = widget_get_value_numericInput,
  "radioButtons" = widget_get_value_radioButtons,
  "selectInput" = widget_get_value_selectInput,
  "sliderInput" = widget_get_value_sliderInput,
  "textInput" = widget_get_value_textInput,
  "passwordInput" = widget_get_value_passwordInput,

  "htmlOutput" = widget_get_value_htmlOutput,
  "plotOutput" = widget_get_value_plotOutput,
  "tableOutput" = widget_get_value_tableOutput,
  "verbatimTextOutput" = widget_get_value_verbatimTextOutput,
  "textOutput" = widget_get_value_textOutput
)
