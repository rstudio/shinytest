
widget_set_value <- function(self, private, value) {
  widget_set_value_list[[private$type]](self, private, value)
  invisible(self)
}

## Can't really set a value I am afraid, but we can click...
widget_set_value_actionButton <- function(self, private, value) {
  private$element$click()
}

widget_set_value_checkboxInput <- function(self, private, value) {
  private$element$execute_script(
    "arguments[0].checked = arguments[1];",
    value
  )
}

widget_set_value_checkboxGroupInput <- function(self, private, value) {

  js <-
    "var root = $(arguments[0])
     var newvals = arguments[1];
     var inputs = root.find('input');
     inputs.attr('checked', function(i) {
       return newvals.indexOf(this.value) >= 0;
     });"

  private$element$execute_script(js, value);
}

widget_set_value_dateInput <- function(self, private, value) {
  assert_date(value)

  js <-
    "var newval = arguments[1];
    if (newval === null) {
      $(arguments[0]).find('input').val('').datepicker('update');
    } else {
      $(arguments[0]).find('input').datepicker('update', arguments[1]);
    }"

  private$element$execute_script(js, value);
}

widget_set_value_dateRangeInput <- function(self, private, value) {
  assert_date_range(value)

  inputs <- private$element$find_elements(xpath = ".//input")
  inputs[[1]]$clear()$send_keys(as.character(value[1]))
  inputs[[2]]$clear()$send_keys(as.character(value[2]))
}

widget_set_value_fileInput <- function(self, private, value) {
  stop("set_value() is not implemented for fileInput")
  ## TODO
}

widget_set_value_numericInput <- function(self, private, value) {
  private$element$clear()$send_keys(as.character(value))
}

widget_set_value_radioButtons <- function(self, private, value) {
  stopifnot(length(value) == 1)

  sel <- private$element$find_elements(
    xpath = paste0(".//input[@value='", value, "']")
  )
  if (!length(sel)) stop("Invalid value in radio buttons")

  sel[[1]]$click()
}

widget_set_value_selectInput <- function(self, private, value) {
  private$element$execute_script(
    "var el = arguments[0];
     var value = arguments[1];
     var selectize = $(el)[0].selectize;
     if (!selectize ) {
       $(el).val(value);
     } else {
       selectize.setValue(value)
     }",
    value
  )
}

widget_set_value_sliderInput <- function(self, private, value) {

  if (!identical(private$element$get_data("type"), "double")) {
    assert_scalar_number(value)
    js <- "
      var el = $(arguments[0]);
      var value = arguments[1];
      var slider = el.data('ionRangeSlider');
      slider.update({ from: value });
      if (slider.$cache && slider.$cache.input) {
        slider.$cache.input.trigger('change');
      }
    "
  } else {
    assert_numeric(value, .length =2)
    js <- "
      var el = $(arguments[0]);
      var values = arguments[1];
      var slider = el.data('ionRangeSlider');
      slider.update({ from: values[0], to: values[1] });
      if (slider.$cache && slider.$cache.input) {
        slider.$cache.input.trigger('change');
      }
    "
  }

  private$element$execute_script(js, value)
}

widget_set_value_textInput <- function(self, private, value) {
  private$element$clear()$send_keys(value)
}

widget_set_value_passwordInput <- function(self, private, value) {
  private$element$clear()$send_keys(value)
}

widget_set_value_htmlOutput <- function(self, private, value) {
  stop("set_value() is not implemented for htmlOutput")
}

widget_set_value_plotOutput <- function(self, private, value) {
  stop("set_value() is not implemented for plotOutput")
}

widget_set_value_tableOutput <- function(self, private, value) {
  stop("set_value() is not implemented for tableOutput")
}

widget_set_value_verbatimTextOutput <- function(self, private, value) {
  stop("set_value() is not implemented for verbatimTextOutput")
}

widget_set_value_textOutput <- function(self, private, value) {
  stop("set_value() is not implemented for textOutput")
}

widget_set_value_list = list(
  "actionButton"  = widget_set_value_actionButton,
  "checkboxInput" = widget_set_value_checkboxInput,
  "checkboxGroupInput" = widget_set_value_checkboxGroupInput,
  "dateInput" = widget_set_value_dateInput,
  "dateRangeInput" = widget_set_value_dateRangeInput,
  "fileInput" = widget_set_value_fileInput,
  "numericInput" = widget_set_value_numericInput,
  "radioButtons" = widget_set_value_radioButtons,
  "selectInput" = widget_set_value_selectInput,
  "sliderInput" = widget_set_value_sliderInput,
  "textInput" = widget_set_value_textInput,
  "passwordInput" = widget_set_value_passwordInput,

  "htmlOutput" = widget_set_value_htmlOutput,
  "plotOutput" = widget_set_value_plotOutput,
  "tableOutput" = widget_set_value_tableOutput,
  "verbatimTextOutput" = widget_set_value_verbatimTextOutput,
  "textOutput" = widget_set_value_textOutput
)
