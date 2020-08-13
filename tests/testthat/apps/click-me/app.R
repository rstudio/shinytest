library(shiny)
ui <- fluidPage(
  actionButton("click", "Click me!"),
  textOutput("i")
)
server <- function(input, output, session) {
  i <- reactiveVal(0)

  observeEvent(input$click, {
    i(i() + 1)
  })

  output$i <- renderText(i())
}
shinyApp(ui, server)