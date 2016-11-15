target_url <- getOption("shinytest.recorder.url")
save_dir <- getOption("shinytest.recorder.savedir")

if (is.null(target_url) || is.null(save_dir)) {
  stop("Test recorder requires the 'shinytest.recorder.url' and ",
    "'shinytest.recorder.savedir' options to be set.")
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

# Given a string, indent every line by some number of spaces.
# The exception is to not add spaces after a trailing \n.
indent <- function(str, indent = 2) {
  gsub("(^|\\n)(?!$)",
    paste0("\\1", paste(rep(" ", indent), collapse = "")),
    str,
    perl = TRUE
  )
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
      "app$set_inputs(",
      event$name, " = ",
      processInputValue(event$value, event$inputType),
      ")"
    )
  },

  outputValue = function(event) {
    paste0("expect_identical(\n",
      "  app$get_all_values()$outputs[['",
        event$name, "']],\n",
      '  "', escapeString(event$value), '"\n)'
    )
  },

  snapshot = function(event) {
    paste0(
      "expect_identical(\n",
        '  app$get_all_values(inputs=FALSE, exports=TRUE, outputs=TRUE),\n',
        '  readRDS("',
          file.path(save_dir, paste0("snapshot-", as.character(event$value), ".rds")),
        '")\n',
      ")"
    )
  }
)

generateTestCode <- function(events) {
  # Generate code for each input and output event
  eventCode <- vapply(events, function(event) {
    codeGenerators[[event$type]](event)
  }, "")

  if (length(eventCode) != 0)
    eventCode <- indent(paste(eventCode, collapse = "\n"))

  # Use paste(c()) so that if eventCode is character(0), it gets dropped;
  # otherwise when empty it will result in an extra `\n`.
  paste(
    c(
      'test_that("ADD TEST DESCRIPTION HERE", {',
      '  app <- shinyapp$new("PATH/TO/APP")',
      eventCode,
      '})'
    ),
    collapse = "\n"
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
        actionButton("exit", "Exit", class = "btn-danger")
      ),
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

      # Save snapshot
      writeBin(
        req$content,
        file.path(save_dir, paste0("snapshot-", n_snapshots, ".rds"))
      )
    });

    testCode <- reactive({
      generateTestCode(input$testevents)
    })

    output$testCode <- renderText(testCode())

    observeEvent(input$exit, {
      stopApp({
        cat(sep = "\n",
          "========== Code for testing application ==========",
          testCode()
        )
        invisible(testCode())
      })
    })
  }
)
