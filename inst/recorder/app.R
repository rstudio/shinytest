target_url <- getOption("shinytest.recorder.url")
app_dir <- getOption("shinytest.app.dir")

if (is.null(target_url) || is.null(app_dir)) {
  stop("Test recorder requires the 'shinytest.recorder.url' and ",
    "'shinytest.app.dir' options to be set.")
}

# Can't register more than once, so remove existing one just in case.
removeInputHandler("shinytest.testevents")

# Need to avoid Shiny's default recursive unlisting
registerInputHandler("shinytest.testevents", function(val, shinysession, name) {
  val
})

escapeString <- function(s) {
  gsub('"', '\\"', s, fixed = TRUE)
}

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
      return(paste0('"', escapeString(value), '"'))
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



codeGenerators <- list(
  input = function(event) {
    paste0(
      "app$setInputs(",
      event$name, " = ",
      processInputValue(event$value, event$inputType),
      ")"
    )
  },

  fileUpload = function(event) {
    paste0(
      "app$uploadFile(",
      event$name, " = ",
      # `event$files` is a char vector, which works with the "default" input
      # processor.
      processInputValue(event$files, "default"),
      ")"
    )
  },

  outputValue = function(event) {
    paste0('app$snapshot(list(output = "', event$name, '"))')
  },

  snapshot = function(event) {
    "app$snapshot()"
  }
)

generateTestCode <- function(events, name) {
  # Generate code for each input and output event
  eventCode <- vapply(events, function(event) {
    codeGenerators[[event$type]](event)
  }, "")

  if (length(eventCode) != 0) {
    eventCode <- paste(eventCode, collapse = "\n")
  }

  paste(
    'app <- ShinyDriver$new("..")',
    paste0('app$snapshotInit("', name, '")'),
    '',
    eventCode,
    '\napp$snapshotCompare()\n',
    sep = "\n"
  )
}

shinyApp(
  ui = fluidPage(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "recorder.css"),
      tags$script(src = "inject-recorder.js")
    ),

    div(id = "app-iframe-container",
      tags$iframe(id = "app-iframe", src = target_url)
    ),
    div(id = "shiny-recorder",
      div(class = "shiny-recorder-title", "Test event recorder"),
      div(class = "shiny-recorder-controls",
        actionButton("snapshot", "Take snapshot"),
        actionButton("exit", "Exit", class = "btn-danger"),
        textInput("testname", label = "Name of tests", value = "mytests"),
        checkboxInput("editSaveFile", "Open script in editor on exit", value = TRUE),
        checkboxInput("runScript", "Run test script on exit", value = TRUE)
      ),
      div(class = "recorded-events-header", "Recorded events"),
      div(id = "recorded-events",
        tableOutput("recordedEvents")
      )
    )
  ),

  server = function(input, output) {
    # Read the recorder.js file for injection into iframe
    output$recorder_js <- renderText({
      file <- "recorder.js"
      readChar(file, file.info(file)$size, useBytes = TRUE)
    })
    outputOptions(output, "recorder_js", suspendWhenHidden = FALSE)

    testCode <- reactive({
      generateTestCode(input$testevents, input$testname)
    })

    saveFile <- reactive({
      file.path(app_dir, "tests", paste0(input$testname, ".R"))
    })

    output$recordedEvents <- renderTable(
      {
        # Genereate list of lists from all events. Inner lists have 'type' and
        # 'name' fields.
        events <- lapply(input$testevents, function(event) {
          type <- event$type

          if (type == "outputValue") {
            list(type = "snapshot-output", name = event$name)
          } else if (type == "snapshot") {
            list(type = "snapshot", name = "<all>")
          } else if (type == "input") {
            list(type = "input", name = event$name)
          }
        })

        # Transpose list of lists into data frame
        data.frame(
          `Event type` = vapply(events, `[[`, character(1), "type"),
          Name = vapply(events, `[[`, character(1), "name"),
          stringsAsFactors = FALSE,
          check.names = FALSE
        )
      },
      width = "100%",
      rownames = TRUE,
      striped = TRUE
    )

    observeEvent(input$exit, {
      stopApp({
        cat(testCode(), file = saveFile())
        message("Saved test code to ", saveFile())
        if (input$editSaveFile)
          file.edit(saveFile())

        invisible(list(
          appDir = app_dir,
          file = paste0(input$testname, ".R"),
          run = input$runScript
        ))
      })
    })
  }
)
