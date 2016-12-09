
#' Try to deduce the shiny input/output element type from its name
#'
#' @param self me
#' @param private private me
#' @param name The name of the Shiny input or output to search for.
#' @param iotype It is possible that an input has the same name as
#'   an output, and in this case there is no way to get element without
#'   knowing whether it is an input or output element.
#'
#' @keywords internal

sd_findWidget <- function(self, private, name, iotype) {

  "!DEBUG finding a widget `name` (`iotype`)"

  css <- if (iotype == "auto") {
    paste0("#", name)

  } else if (iotype == "input") {
    paste0("#", name, ".shiny-bound-input")

  } else if (iotype == "output") {
    paste0("#", name, ".shiny-bound-output")
  }

  els <- self$findElements(css = css)

  if (length(els) == 0) {
    stop(
      "Cannot find ",
      if (iotype != "auto") paste0(iotype, " "),
      "widget ", name
    )

  } else if (length(els) > 1) {
    warning(
      "Multiple ",
      if (iotype != "auto") paste0(iotype, " "),
      "widgets with id ", name
    )
  }

  type <- els[[1]]$executeScript(
    "var el = $(arguments[0]);
     if (el.data('shinyInputBinding') !== undefined) {
       return ['input', el.data('shinyInputBinding').name];
     } else {
       var name = el.data('shinyOutputBinding').binding.name;
       if (name == 'shiny.textOutput' && el[0].tagName == 'PRE') {
         return ['output', 'shiny.verbatimTextOutput'];
       } else {
         return ['output', name];
       }
     }"
  )

  ## We could use the JS names as well, but it is maybe better to use
  ## the names the users encounter with in the Shiny R docs
  widget_names <- c(
    "shiny.actionButtonInput"  = "actionButton",
    "shiny.checkboxInput"      = "checkboxInput",
    "shiny.checkboxGroupInput" = "checkboxGroupInput",
    "shiny.dateInput"          = "dateInput",
    "shiny.dateRangeInput"     = "dateRangeInput",
    "shiny.fileInputBinding"   = "fileInput",
    "shiny.numberInput"        = "numericInput",
    "shiny.radioInput"         = "radioButtons",
    "shiny.selectInput"        = "selectInput",
    "shiny.sliderInput"        = "sliderInput",
    "shiny.textInput"          = "textInput",
    "shiny.passwordInput"      = "passwordInput",
    "shiny.bootstrapTabInput"  = "tabsetPanel",

    "shiny.textOutput"         = "textOutput",
    "shiny.verbatimTextOutput" = "verbatimTextOutput",
    "shiny.htmlOutput"         = "htmlOutput",
    "shiny.imageOutput"        = "plotOutput",
    "datatables"               = "tableOutput"
  )

  Widget$new(
    name = name,
    element = els[[1]],
    type = unname(widget_names[type[[2]]] %|NA|% type[[2]]),
    iotype = type[[1]]
  )
}
