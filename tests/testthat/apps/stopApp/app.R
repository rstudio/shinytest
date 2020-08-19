library(shiny)
ui <- fluidPage(
  actionButton("quit", "quit")
)
server <- function(input, output, session) {
  observeEvent(input$quit, stopApp())
}
shinyApp(ui, server)
