library(shiny)
ui <- fluidPage(
  textInput("name", "What is your name?"),
  actionButton("greet", "Greet"),
  textOutput("greeting")
)
server <- function(input, output, session) {
  output$greeting <- renderText({
    req(input$greet)
    paste0("Hello ", isolate(input$name), "!")
  })
}
shinyApp(ui, server)
