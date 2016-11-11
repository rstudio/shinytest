removeInputHandler("shinytest.testevents")

# Need to avoid Shiny's default recursive unlisting
registerInputHandler("shinytest.testevents", function(val, shinysession, name) {
  val
})


inputProcessors <- list(
  default = function(value) {
    # This function is designed to operate on atomic vectors (not lists), so if
    # this is a list, we need to unlist it.
    if (is.list(value))
      value <- unlist(value, recursive = FALSE)

    if (length(value) > 1) {
      # If it's an array, recurse
      vals <- vapply(value, inputProcessors$default, "")
      return(paste0(
        "c(",
        paste0(vals, collapse = ", "),
        ")"
      ))
    }

    if (length(value) == 0) {
      return("character(0)")
    }

    if (is.character(value)) {
      return(paste0('"', value, '"'))
    } else {
      return(as.character(value))
    }
  },

  shiny.action = function(value) {
    '"click"'
  }
)

# Given an input value taken from the client, return the value that would need
# to be passed to app$set_input() to set the input to that value.
processInputValue <- function(value, inputType) {
  if (is.null(inputProcessors[[inputType]]))
    inputType <- "default"

  inputProcessors[[inputType]](value)
}

inputCodeGenerator <- function(event) {
  paste0(
    "app$set_input(",
    event$name, " = ",
    processInputValue(event$value, event$inputType),
    ")"
  )
}

shinyApp(
  ui = fluidPage(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "recorder.css"),
      tags$script(src = "inject-recorder.js")
    ),

    div(id = "app-iframe-container",
      # TODO: Need to pass in URL a different way
      tags$iframe(id = "app-iframe", src = app$get_url())
    ),
    div(id = "shiny-recorder",
      div(class="shiny-recorder-title", "Test event recorder"),
      div(
        actionButton("snapshot", "Take snapshot")
      ),
      # div(class="shiny-recorder-code", pre())
      verbatimTextOutput("testCode")
    )
  ),

  server = function(input, output) {
    # Read the recorder.js file for injection into iframe
    output$recorder_js <- renderText({
      file <- "recorder.js"
      readChar(file, file.info(file)$size, useBytes = TRUE)
    })
    outputOptions(output, "recorder_js", suspendWhenHidden = FALSE)

    n_snapshots <- 0
    observeEvent(input$snapshot, {
      req <- httr::GET(input$testEndpointUrl)
      n_snapshots <<- n_snapshots + 1
      # TODO: Save snapshot in a different directory
      writeBin(req$content, paste0("snapshot-", n_snapshots, ".rds"))
    });

    output$testCode <- renderText({
      code <- vapply(input$testevents, inputCodeGenerator, "")
      paste(code, collapse = "\n")

    })
  }
)
