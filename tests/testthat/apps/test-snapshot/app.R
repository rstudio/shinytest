shinyApp(
  ui = basicPage(
    verbatimTextOutput("url"),
    verbatimTextOutput("values"),
    actionButton("inc", "Increment x")
  ),
  
  server = function(input, output, session) {
    vals <- reactiveValues(x = 1)
    y <- reactive({ vals$x + 1 })

    onTestSnapshot(x = vals$x, y = y())

    # Increment x when button is pressed
    observeEvent(input$inc, {
      vals$x <<- vals$x + 1
    })

    output$values <- renderText({
      paste0("vals$x: ", vals$x, "\ny: ", y())
    })

    # Print the URL
    cd <- session$clientData
    output$url <- renderText({
      paste0(
        cd$url_protocol, "//", cd$url_hostname,
        if (nzchar(cd$url_port)) paste0(":", cd$url_port),
        cd$url_pathname,
        "session/",
        URLencode(session$token, TRUE),
        "/dataobj/shinyTestSnapshot?w=", shiny:::workerId()
      )
    })    
  }
)
