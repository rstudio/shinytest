library(shiny)


ui <- fluidPage(
  checkboxInput("chkbx", "Display Graph?", FALSE),
  uiOutput("dynamic_output")
)

server <- function(input, output) {
  output$dynamic_output <- renderUI({
    if(!input$chkbx) {
      return(NULL)
    }
    tagList(
      sliderInput(inputId = "bins", label = "Number of bins:", min = 1, max = 50, value = 30),
      plotOutput(outputId = "distPlot")
    )
  })

  observe({
    str(reactiveValuesToList(input))
  })

  # will not execute until `input$bins` is available
  # `input$bins` is not available until `chkbx` is checked
  output$distPlot <- renderPlot({
    Sys.sleep(5)

    x    <- faithful$waiting
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    hist(x, breaks = bins, col = "#75AADB", border = "white",
         xlab = "Waiting time to next eruption (in mins)",
         main = "Histogram of waiting times")
  })
}

shinyApp(ui = ui, server = server)
