
shinyApp(
  ui = fluidPage(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "recorder.css"),
      tags$script(src = "inject-recorder.js")
    ),
    
    div(id = "app-iframe-container",
      tags$iframe(id = "app-iframe", src = app$get_url())
    )
  ),

  server = function(input, output) {
    output$recorder_js <- renderText({
      file <- system.file("js", "recorder.js", package = "shinytest")
      readChar(file, file.info(file)$size, useBytes = TRUE)
    })
    outputOptions(output, "recorder_js", suspendWhenHidden = FALSE)
  }
)
