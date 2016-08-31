
shinyApp(

  ui = shinyUI(pageWithSidebar(
    headerPanel("Testing Shiny output widgets"),
    sidebarPanel(
      selectInput("select", "Just a dummy selector", c("p", "h2"))
    ),
    mainPanel(
      wellPanel(htmlOutput("html")),
      wellPanel(verbatimTextOutput("verbatim")),
      wellPanel(textOutput("text"))
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

    output$verbatim <- renderText(
      if (input$select == "p") {
        "This is verbatim, really. <div></div>"
      } else {
        "<b>This is verbatim, too</b>"
      }
    )

    output$text <- renderText(
      if (input$select == "p") {
        "This is text. <div></div>"
      } else {
        "<b>This, too</b>"
      }
    )
  }
)
