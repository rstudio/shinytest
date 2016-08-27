
widget_get_value <- function(self, private) {
  widget_get_value_list[[private$type]](self, private)
}

widget_get_value_actionButton <- function(self, private) {

}

widget_get_value_checkboxInput <- function(self, private) {

}

widget_get_value_checkboxGroupInput <- function(self, private) {

}

widget_get_value_dateInput <- function(self, private) {

}

widget_get_value_dateRangeInput <- function(self, private) {

}

widget_get_value_fileInput <- function(self, private) {

}

widget_get_value_numericInput <- function(self, private) {

}

widget_get_value_radioButtons <- function(self, private) {

}

widget_get_value_selectInput <- function(self, private) {

}

widget_get_value_sliderInput <- function(self, private) {

}

widget_get_value_textInput <- function(self, private) {
  private$element$get_attribute("value")
}

widget_get_value_passwordInput <- function(self, private) {

}

widget_get_value_htmlOutput <- function(self, private) {

}

widget_get_value_plotOutput <- function(self, private) {

}

widget_get_value_tableOutput <- function(self, private) {

}

widget_get_value_verbatimTextOutput <- function(self, private) {

}

widget_get_value_textOutput <- function(self, private) {

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
