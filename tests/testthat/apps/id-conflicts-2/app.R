
shinyApp(

  ui = shinyUI(pageWithSidebar(
    headerPanel("Testing Conflicting Widget IDs"),
    sidebarPanel(
      selectInput("select", "Just a selector", c("p", "h2"))
    ),
    mainPanel(
      wellPanel(htmlOutput("html")),
      wellPanel(textOutput("html"))
    )
  )),

  server = function(input, output, session) {

    output$html <- renderText(
     if (input$select == "p") {
        HTML("<div><p>This is a paragraph.</p></div>")
      } else {
        HTML("<div><h2>This is a heading</h2></div>")
      }
    )
  }
)
