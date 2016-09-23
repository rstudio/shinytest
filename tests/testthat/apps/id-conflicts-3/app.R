
shinyApp(

  ui = shinyUI(pageWithSidebar(
    headerPanel("Testing Conflicting Widget IDs"),
    sidebarPanel(
      selectInput("widget", "Just a selector", c("p", "h2"))
    ),
    mainPanel(
      wellPanel(htmlOutput("widget"))
    )
  )),

  server = function(input, output, session) {

    output$widget <- renderText(
     if (input$widget == "p") {
        HTML("<div><p>This is a paragraph.</p></div>")
      } else {
        HTML("<div><h2>This is a heading</h2></div>")
      }
    )
  }
)
