
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
      div(class="shiny-recorder-code", pre())
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
  }
)
