
widget_get_value <- function(self, private) {
  widget_get_value_list[[private$type]](self, private)
}

## A button has no value, really
widget_get_value_actionButton <- function(self, private) {
  NULL
}

widget_get_value_checkboxInput <- function(self, private) {
  private$element$get_attribute("checked") == "true"
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
  ## TODO
}

widget_get_value_numericInput <- function(self, private) {
  as.numeric(private$element$get_value())
}

widget_get_value_radioButtons <- function(self, private) {
  selected <- private$element$find_elements(
    xpath = ".//input[@type='radio'][boolean(@checked)]"
  )[[1]]
  selected$get_value()
}

widget_get_value_selectInput <- function(self, private) {
  opt <- private$element$find_elements(
    xpath = ".//option[boolean(@selected)]"
  )
  vapply(opt, function(o) o$get_value(), "")
}

widget_get_value_sliderInput <- function(self, private) {
  if (! identical(private$element$get_data("type"), "double")) {
    single <- private$element$find_elements(
      xpath = paste0(
        ## all <div> ancestors
        "./ancestor::div",
        ## the first that has this class
        "[contains(concat(' ', @class, ' '), ' shiny-input-container ')][1]",
        ## and then down to span.irs-single
        "//span[contains(concat(' ', @class, ' '), ' irs-single ')]"
      )
    )
    as.numeric(single[[1]]$get_text())

  } else {
    ## otherwise slider range
    range <- private$element$find_elements(
      xpath = paste0(
        ## all <div> ancestors
        "./ancestor::div",
        ## the first that has this class
        "[contains(concat(' ', @class, ' '), ' shiny-input-container ')][1]",
        ## and then down to span.irs-from or span.irs-to
        "//span[",
        "contains(concat(' ', @class, ' '), ' irs-from ') or ",
        "contains(concat(' ', @class, ' '), ' irs-to ')",
        "]"
      )
    )

    as.numeric(vapply(range, function(e) e$get_text(), ""))
  }
}

widget_get_value_textInput <- function(self, private) {
  private$element$get_value()
}

widget_get_value_passwordInput <- function(self, private) {
  private$element$get_value()
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
