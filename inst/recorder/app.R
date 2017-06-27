target_url <- getOption("shinytest.recorder.url")
app_dir    <- getOption("shinytest.app.dir")
load_mode  <- getOption("shinytest.load.mode")
seed       <- getOption("shinytest.seed")

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
  },

  shiny.fileupload = function(value) {
    # Extract filenames, then send to default processor
    value <- vapply(value, function(file) file$name, character(1))
    inputProcessors$default(value)
  }
)

# Given an input value taken from the client, return the value that would need
# to be passed to app$set_input() to set the input to that value.
processInputValue <- function(value, inputType) {
  if (is.null(inputProcessors[[inputType]]))
    inputType <- "default"

  inputProcessors[[inputType]](value)
}


# Quote variable/argument names. Normal names like x, x1, or x_y will not be changed, but
# if there are any strange characters, it will be quoted; x-1 will return `x-1`.
quoteName <- function(name) {
  if (!grepl("^[a-zA-Z0-9_]*$", name)) {
    paste0("`", name, "`")
  } else {
    name
  }
}

codeGenerators <- list(
  initialize = function(event, nextEvent = NULL, useTimes = FALSE) {
    NA_character_
  },

  input = function(event, nextEvent = NULL, useTimes = FALSE) {
    if (!event$hasBinding) {
      return(paste0(
        "# Input '", quoteName(event$name),
        "' was set, but doesn't have an input binding."
      ))
    }

    # Extra arguments when using times
    args <- ""
    if (useTimes && !is.null(nextEvent)) {
      if (nextEvent$type == "input") {
        # When using timings, don't wait when next event is also setting an input.
        args <- ", values_ = FALSE, wait_ = FALSE"

      } else if (nextEvent$type == "outputEvent") {
        # When the next event is an output event, use 3 * the timediff value
        # (rounded to the nearest whole number) for the timeout, or 3 seconds,
        # whichever is larger.
          args <- paste0(", timeout_ = ",
          max(3000, round(nextEvent$timediff * 3, -3))
        )
      }
    }

    if (event$inputType == "shiny.fileupload") {
      # Special case for file uploads
      paste0(
        "app$uploadFile(",
        quoteName(event$name), " = ",
        processInputValue(event$value, event$inputType),
        args,
        ")"
      )

    } else {
      paste0(
        "app$setInputs(",
        quoteName(event$name), " = ",
        processInputValue(event$value, event$inputType),
        args,
        ")"
      )
    }
  },

  fileDownload = function(event, nextEvent = NULL, useTimes = FALSE) {
    paste0('app$snapshotDownload("', event$name, '")')
  },

  outputEvent = function(event, nextEvent = NULL, useTimes = FALSE) {
     NA_character_
  },

  outputValue = function(event, nextEvent = NULL, useTimes = FALSE) {
    paste0('app$snapshot(list(output = "', event$name, '"))')
  },

  snapshot = function(event, nextEvent = NULL, useTimes = FALSE) {
    "app$snapshot()"
  }
)

generateTestCode <- function(events, name, useTimes = FALSE) {
  if (useTimes) {
    # Convert from absolute to relative times; first event has time 0.
    startTime <- NA
    if (length(events) != 0) {
      events[[1]]$timediff <- 0
      for (i in seq_len(length(events)-1)) {
        events[[i+1]]$timediff <- events[[i+1]]$time - events[[i]]$time
      }
    }
  }

  # Generate code for each input and output event
  eventCode <- mapply(
    function(event, nextEvent, useTimes) {
      codeGenerators[[event$type]](event, nextEvent, useTimes)
    },
    events,
    c(events[-1], list(NULL)),
    useTimes
  )

  # Find the indices of the initialize event and output events. The code lines
  # and (optional) Sys.sleep() calls for these events will be removed later.
  # We need the output events for now in order to calculate times.
  removeEvents <- vapply(events, function(event) {
    event$type %in% c("initialize", "outputEvent")
  }, logical(1))

  if (length(eventCode) != 0) {
    if (useTimes) {
      timingCode <- vapply(events, function(event) {
        sprintf("Sys.sleep(%0.1f)", event$timediff / 1000)
      }, "")

      # Remove unwanted events
      eventCode  <- eventCode[!removeEvents]
      timingCode <- timingCode[!removeEvents]

      # Interleave events and times with c(rbind()) trick
      eventCode <- c(rbind(timingCode, eventCode))

    } else {
      # Remove unwanted events
      eventCode  <- eventCode[!removeEvents]
    }

    eventCode <- paste(eventCode, collapse = "\n")
  }

  paste(
    if (load_mode) {
      'app <- ShinyLoadDriver$new()'
    } else {
      paste0(
        'app <- ShinyDriver$new(".."',
        if (!is.null(seed)) sprintf(", seed = %s", seed),
        ')'
      )
    },
    paste0('app$snapshotInit("', name, '")'),
    '',
    eventCode,
    if (load_mode) {
      '\napp$snapshot()\napp$stop()\napp$getEventLog()\n'
    },
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
      div(class = "shiny-recorder-header", "Test event recorder"),
      div(class = "shiny-recorder-controls",
        if (!load_mode) {
          tagList(
            actionLink("snapshot",
              span(
                img(src = "snapshot.png", class = "shiny-recorder-icon"),
                "Take snapshot"
              )
            ),
            hr()
          )
        },
        actionLink("exit_save",
          span(
            img(src = "exit-save.png", class = "shiny-recorder-icon"),
            "Save script and exit test event recorder"
          )
        ),
        actionLink("exit_nosave",
          span(
            img(src = "exit-nosave.png", class = "shiny-recorder-icon"),
            "Quit without saving"
          )
        ),
        textInput("testname", label = "On exit, save tests as:",
          value = if (load_mode) "myloadtest" else "mytest"),
        checkboxInput("editSaveFile", "Open script in editor on exit", value = TRUE),
        if (!load_mode) checkboxInput("runScript", "Run test script on exit", value = TRUE)
      ),
      div(class = "shiny-recorder-header", "Recorded events"),
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

    saveFile <- reactive({
      file.path(app_dir, "tests", paste0(input$testname, ".R"))
    })

    # Number of snapshot or fileDownload events in input$testevents
    numSnapshots <- reactive({
        snapshots <- vapply(input$testevents, function(event) {
          return(event$type %in% c("snapshot", "fileDownload"))
        }, logical(1))
        sum(snapshots)
    })

    output$recordedEvents <- renderTable(
      {
        # Genereate list of lists from all events. Inner lists have 'type' and
        # 'name' fields.
        events <- lapply(input$testevents, function(event) {
          type <- event$type

          if (type == "initialize") {
            NULL
          } else if (type == "outputValue") {
            list(type = "snapshot-output", name = event$name)
          } else if (type == "snapshot") {
            list(type = "snapshot", name = "<all>")
          } else if (type == "input") {
            if (event$inputType == "shiny.fileupload") {
              # File uploads are a special case of inputs
              list(type = "file-upload", name = event$name)
            } else {
              list(type = "input", name = event$name)
            }
          } else if (type == "fileDownload") {
            list(type = "file-download", name = event$name)
          } else if (type == "outputEvent") {
            list(type = "output-event", name = "--")
          }
        })

        events <- events[!vapply(events, is.null, logical(1))]

        # Transpose list of lists into data frame
        data.frame(
          `Event type` = vapply(events, `[[`, character(1), "type"),
          Name = vapply(events, `[[`, character(1), "name"),
          stringsAsFactors = FALSE,
          check.names = FALSE
        )
      },
      width = "100%",
      rownames = TRUE
    )

    observeEvent(input$exit_save, {
      stopApp({
        # If no snapshot events occurred, don't write file. However, in load
        # testing mode, we don't expect snapshots (except one at the end).
        if (!load_mode && numSnapshots() == 0) {
          message("No snapshot or download events occurred; not saving test code.")
          invisible(list(
            appDir = NULL,
            file = NULL,
            run = FALSE
          ))

        } else {

          code <- generateTestCode(input$testevents, input$testname,
                                   useTimes = load_mode)

          cat(code, file = saveFile())
          message("Saved test code to ", saveFile())
          if (input$editSaveFile)
            file.edit(saveFile())

          invisible(list(
            appDir = app_dir,
            file = paste0(input$testname, ".R"),
            run = input$runScript
          ))
        }
      })
    })

    observeEvent(input$exit_nosave, {
      stopApp({
        message("Quitting without saving or running tests.")
        invisible(list(
          appDir = NULL,
          file = NULL,
          run = FALSE
        ))
      })
    })
  }
)
