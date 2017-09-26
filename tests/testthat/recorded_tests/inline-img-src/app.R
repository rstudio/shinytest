# This app tests the filtering of img src data that is hard-coded, as opposed
# to data provided via renderPlot().

shinyApp(
  fluidPage(
    htmlOutput("image"),
    plotOutput("plot1", height=30, width=30),
    plotOutput("plot2", height=30, width=30)
  ),
  function(input, output) {
    output$image <- renderUI({
      img(src = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAJ0lEQVQoU2Ps6Oj4z4AGXFxc0IUYGIeCwjNnzmB4Zs+ePZieGQIKAZKhLO1oE8Z/AAAAAElFTkSuQmCC")
    })

    output$plot1 <- renderPlot({
      par(mar= c(0,0,0,0))
      plot(1:5, 1:5)
    })

    output$plot2 <- renderPlot({
      par(mar= c(0,0,0,0))
      plot(5:1, 1:5)
    })
  }
)
