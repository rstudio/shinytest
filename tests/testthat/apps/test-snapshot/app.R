
shinyApp(
  ui = basicPage(
    h4("Snapshot URL: "),
    uiOutput("snapshotUrl"),
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

    onTestSnapshot(x = vals$x, y = y())

    output$values <- renderText({
      paste0("vals$x: ", vals$x, "\ny: ", y())
    })

    # Print the URL
    cd <- session$clientData
    baseUrl <- reactive({
      paste0(
        cd$url_protocol, "//", cd$url_hostname,
        if (nzchar(cd$url_port)) paste0(":", cd$url_port),
        cd$url_pathname,
        "session/",
        URLencode(session$token, TRUE),
        "/dataobj/shinytest?w=", shiny:::workerId()
      )
    })
    output$snapshotUrl <- renderUI({
      url <- paste0(baseUrl(), "&snapshot=1&inputs=1&outputs=1&format=json")
      a(href = url, url)
    })
  }
)