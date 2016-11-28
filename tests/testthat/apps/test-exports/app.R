shinyApp(
  ui = basicPage(
    h4("Snapshot URL: "),
    uiOutput("url"),
    h4("Current values:"),
    verbatimTextOutput("values"),
    actionButton("inc", "Increment x")
  ),

  server = function(input, output, session) {
    vals <- reactiveValues(x = 1)
    y <- reactive({ vals$x + 1 })

    observeEvent(input$inc, {
      vals$x <<- vals$x + 1
    })

    exportTestValues(
      x = vals$x,
      y = y()
    )

    output$url <- renderUI({
      url <- session$getTestSnapshotUrl(format="json")
      a(href = url, url)
    })

    output$values <- renderText({
      paste0("vals$x: ", vals$x, "\ny: ", y())
    })
  }
)
