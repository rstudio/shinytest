app_dir   <- getOption("shinytest.app.dir")
test_name <- getOption("shinytest.test.name")

shinyApp(
  ui = bootstrapPage(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "diffviewerapp.css")
    ),
    div(class = "header",
      div(class = "title",
        paste0("Differences between expected (old) and current (new) test results for ",
          basename(app_dir), ": ", test_name
        )
      ),
      div(class = "controls",
        actionLink("accept",
          span(
            img(src = "exit-save.png", class = "diffviewer-icon"),
            "Update and quit",
            title = "Replace the expected results with the current results"
          )
        ),
        actionLink("reject",
          span(
            img(src = "exit-nosave.png", class = "diffviewer-icon"),
            "Quit",
            title = "Leave the expected results unchanged"
          )
        )
      )
    ),
    div(
      class = "content",
      shinytest::viewTestDiffWidget(app_dir, test_name)
    )
  ),

  server = function(input, output) {
    server = function(input, output) {
      msg <- reactiveVal()
      observeEvent(input$accept, {
        shinytest::snapshotUpdate(app_dir, test_name)
        msg("accept")
        session$close()
      })
      
      observeEvent(input$reject, {
        msg("reject")
        session$close()
      })
      
      onSessionEnded(function() {
        observe({
          if (is.null(msg())) msg("reject")
          stopApp(msg())
        })
      })
    }
  }
)
