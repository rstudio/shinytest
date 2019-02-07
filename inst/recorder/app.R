library(promises)

target_url   <- getOption("shinytest.recorder.url")
app          <- getOption("shinytest.app")
debug        <- getOption("shinytest.debug")
load_mode    <- getOption("shinytest.load.mode")
load_timeout <- getOption("shinytest.load.timeout")
start_seed   <- getOption("shinytest.seed")
shiny_options<- getOption("shinytest.shiny.options")

# If there are any reasons to not run a test, a message should be appended to
# this vector.
dont_run_reasons <- character(0)
add_dont_run_reason <- function(reason) {
  dont_run_reasons <<- c(dont_run_reasons, reason)
}

if (is.null(target_url) || is.null(app$getAppDir())) {
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
  # escape \ as well as "
  s <- gsub('\\', '\\\\', s, fixed = TRUE)
  gsub('"', '\\"', s, fixed = TRUE)
}

# A replacement for deparse() that's a little less verbose for named lists.
deparse2 <- function(x) {
  expr <- deparse(x)
  expr <- paste(expr, collapse = "")

  # If the deparsed expression is something like:
  #   "structure(list(a = 1, b = 2), .Names = c(\"a\", \"b\"))"
  # simplify it to "list(a = 1, b = 2)".
  expr <- sub("^structure\\((list.*), \\.Names = c\\([^(]+\\)\\)$", "\\1", expr)
  # Same as above, but for single item in .Names, like:
  #  "structure(list(a = 1), .Names = \"a\")"
  expr <- sub('^structure\\((list.*), \\.Names = \\"[^\\"]*\\"\\)$', "\\1", expr)

  expr
}


# A modified version of shiny::numericInput but with a placholder
numericInput <- function(..., placeholder = NULL) {
  res <- shiny::numericInput(...)
  res$children[[2]]$attribs$placeholder <- placeholder
  res
}

# Create a question mark icon that displays a tooltip when hovered over.
tooltip <- function(text, placement = "top") {
  a(href = "#",
    `data-toggle` = "tooltip",
    title = text,
    icon("question-sign", lib = "glyphicon"),
    `data-placement` = placement
  )
}

enable_tooltip_script <- function() {
  tags$script("$('a[data-toggle=\"tooltip\"]').tooltip({ delay: 250 });")
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
  initialize = function(event, nextEvent = NULL, useTimes = FALSE, ...) {
    NA_character_
  },

  input = function(event, nextEvent = NULL, useTimes = FALSE, allowInputNoBinding = FALSE, ...) {
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
      filename <- processInputValue(event$value, event$inputType)

      code <- paste0(
        "app$uploadFile(",
        quoteName(event$name), " = ", filename,
        args,
        ")"
      )

      # Get unescaped filenames in a char vector, with full path
      filepaths <- vapply(event$value, `[[`, "name", FUN.VALUE = "")
      filepaths <- file.path(app$getAppDir(), "tests", filepaths)

      # Check that all files exist. If not, add a message and don't run test
      # automatically on exit.
      if (!all(file.exists(filepaths))) {
        add_dont_run_reason("An uploadFile() must be updated: use the correct path relative to the app's tests/ directory, or copy the file to the app's tests/ directory.")
        code <- paste0(code,
          " # <-- This should be the path to the file, relative to the app's tests/ directory"
        )
      }

      code

    } else if (event$hasBinding) {
      paste0(
        "app$setInputs(",
        quoteName(event$name), " = ",
        processInputValue(event$value, event$inputType),
        args,
        ")"
      )

    } else {
      if (allowInputNoBinding) {
        args <- paste0(args, ", allowInputNoBinding_ = TRUE")
        if (identical(event$priority, "event")) args <- paste0(args, ', priority_ = "event"')
        paste0(
          "app$setInputs(",
          quoteName(event$name), " = ",
          processInputValue(event$value, inputType = "default"),
          args,
          ")"
        )
      } else {
        paste0(
          "# Input '", quoteName(event$name),
          "' was set, but doesn't have an input binding."
        )
      }
    }
  },

  fileDownload = function(event, nextEvent = NULL, useTimes = FALSE, ...) {
    paste0('app$snapshotDownload("', event$name, '")')
  },

  outputEvent = function(event, nextEvent = NULL, useTimes = FALSE, ...) {
     NA_character_
  },

  outputSnapshot = function(event, nextEvent = NULL, useTimes = FALSE, ...) {
    paste0('app$snapshot(list(output = "', event$name, '"))')
  },

  snapshot = function(event, nextEvent = NULL, useTimes = FALSE, ...) {
    "app$snapshot()"
  }
)

generateTestCode <- function(events, name, seed, useTimes = FALSE,
  allowInputNoBinding = FALSE)
{
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
      codeGenerators[[event$type]](event, nextEvent, useTimes,
                                   allowInputNoBinding = allowInputNoBinding)
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
        'app <- ShinyDriver$new("', paste("..", app$getAppFilename(), sep = "/"), '"',
        if (!is.null(seed)) sprintf(", seed = %s", seed),
        if (!is.null(load_timeout)) paste0(", loadTimeout = ", load_timeout),
        if (length(shiny_options) > 0) paste0(", shinyOptions = ", deparse2(shiny_options)),
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

hasInputsWithoutBinding <- function(events) {
  any(vapply(events, function(event) {
    return(event$type == "input" && !event$hasBinding)
  }, TRUE))
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
          span(
            actionLink("snapshot",
              span(
                img(src = "snapshot.png", class = "shiny-recorder-icon"),
                "Take snapshot"
              ),
              style = "display: inline;"
            ),
            tooltip(
              "You can also Ctrl-click or ⌘-click on an output to snapshot just that one output.\n To trigger a snapshot via the keyboard, press Ctrl-shift-S or ⌘-shift-S",
              placement = "bottom"
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
        textInput("testname", label = "On exit, save test script as:",
          value = if (load_mode) "myloadtest" else "mytest"),
        checkboxInput("editSaveFile", "Open script in editor on exit", value = TRUE),
        if (!load_mode) checkboxInput("runScript", "Run test script on exit", value = TRUE),
        checkboxInput(
          "allowInputNoBinding",
          tagList("Save inputs that do not have a binding",
            tooltip(
              paste(
                "This enables recording inputs that do not have a binding, which is common in htmlwidgets",
                "like DT and plotly. Note that playback support is limited: shinytest will set the input",
                "value so that R gets the input value, but the htmlwidget itself will not be aware of the value."
              ),
              placement = "bottom"
            )
          ),
          value = FALSE
        ),
        numericInput("seed",
          label = tagList("Random seed:",
            tooltip("A seed is recommended if your application uses any randomness. This includes all Shiny Rmd documents.")
          ),
          value = start_seed,
          placeholder = "(None)"
        )
      ),
      div(class = "shiny-recorder-header", "Recorded events"),
      div(id = "recorded-events",
        tableOutput("recordedEvents")
      ),
      enable_tooltip_script()
    )
  ),

  server = function(input, output) {
    # Read the recorder.js file for injection into iframe
    output$recorder_js <- renderText({
      file <- "recorder.js"
      readChar(file, file.info(file)$size, useBytes = TRUE)
    })
    outputOptions(output, "recorder_js", suspendWhenHidden = FALSE)

    # echo console output from the driver object (in real-time)
    if (!identical(debug, "none")) {
      nConsoleLines <- 0
      observe({
        invalidateLater(500)
        logs <- app$getDebugLog(debug)
        n <- nrow(logs)
        if (n > nConsoleLines) {
          newLines <- seq.int(nConsoleLines + 1, n)
          print(logs[newLines, ], short = TRUE)
          cat("\n")
        }
        nConsoleLines <<- n
      })
    }

    saveFile <- reactive({
      file.path(app$getAppDir(), "tests", paste0(input$testname, ".R"))
    })

    # Number of snapshot or fileDownload events in input$testevents
    numSnapshots <- reactive({
      snapshots <- vapply(input$testevents, function(event) {
        return(event$type %in% c("snapshot", "outputSnapshot", "fileDownload"))
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
          } else if (type == "outputSnapshot") {
            list(type = "snapshot-output", name = event$name)
          } else if (type == "snapshot") {
            list(type = "snapshot", name = "<all>")
          } else if (type == "input") {
            if (event$inputType == "shiny.fileupload") {
              # File uploads are a special case of inputs
              list(type = "file-upload", name = event$name)
            } else if (!event$hasBinding) {
              list(type = "input *", name = event$name)
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

    saveAndExit <- function() {
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

          seed <- as.integer(input$seed)
          if (is.null(seed) || is.na(seed))
            seed <- NULL

          code <- generateTestCode(input$testevents, input$testname,
            seed = seed, useTimes = load_mode,
            allowInputNoBinding = input$allowInputNoBinding)

          cat(code, file = saveFile())
          message("Saved test code to ", saveFile())
          if (input$editSaveFile)
            file.edit(saveFile())

          invisible(list(
            appDir = app$getAppDir(),
            file = paste0(input$testname, ".R"),
            run = input$runScript && (length(dont_run_reasons) == 0),
            dont_run_reasons = dont_run_reasons
          ))
        }
      })
    }


    presentModal <- function(modalDialog, cancel, ok) {
      promise(function(resolve, reject) {
        cancelObs <- observeEvent(input[[cancel]],
          {
            okObs$destroy()
            cancelObs$destroy()
            reject("cancelObs")
          },
          ignoreInit = TRUE
        )

        okObs <- observeEvent(input[[ok]],
          {
            okObs$destroy()
            cancelObs$destroy()
            resolve(TRUE)
          },
          ignoreInit = TRUE
        )

        showModal(modalDialog)
      })
    }

    observeEvent(input$exit_save, {
      if (!load_mode && numSnapshots() == 0) {
        showModal(
          modalDialog("Must have at least one snapshot to save and exit.")
        )
        return()
      }

      p <- promise_resolve(TRUE)

      if (hasInputsWithoutBinding(input$testevents) && !input$allowInputNoBinding) {
        p <- p %...>% {
          presentModal(
            modalDialog(
              tagList(
                "There are some input events (marked with a *) that do not have a corresponding input binding.",
                "If you want them to be saved in the test script, press Cancel, then check ",
                tags$b("Save inputs that do not have a binding."),
                "If you don't want to save them, press Continue."
              ),
              footer = tagList(
                actionButton("inputs_no_binding_cancel",   "Cancel",   `data-dismiss` = "modal"),
                actionButton("inputs_no_binding_continue", "Continue", `data-dismiss` = "modal")
              )
            ),
            "inputs_no_binding_cancel",
            "inputs_no_binding_continue"
          )
        }
      }

      p <- p %...>% {
        if (file.exists(saveFile())) {
          presentModal(
            modalDialog(
              paste0("Overwrite ", basename(saveFile()), "?"),
              footer = tagList(
                actionButton("overwrite_cancel",   "Cancel",   `data-dismiss` = "modal"),
                actionButton("overwrite_continue", "Continue", `data-dismiss` = "modal")
              )
            ),
            "overwrite_cancel",
            "overwrite_continue"
          )
        } else {
          promise_resolve(TRUE)
        }
      }

      p <- p %...>% {
        saveAndExit()
      }

      # When Cancel is pressed, catch the rejection.
      p <- p %...!% {
        NULL
      }

      # Need to return something other than the promise. Otherwise Shiny will
      # wait for the promise to resolve before processing any further
      # reactivity, including the inputs from the actionButtons, so the app
      # will simply stop responding.
      NULL
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
