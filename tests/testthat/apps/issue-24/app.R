
library(shiny)
ui <- fluidPage(
  numericInput('num', "num", "5")
)

server <- function(input, output, session) {
  observe(cat(input$num))
}

shinyApp(ui = ui, server = server)
