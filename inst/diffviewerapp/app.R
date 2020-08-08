app_dir   <- getOption("shinytest.app.dir")
test_name <- getOption("shinytest.test.name")
preprocess <- getOption("shinytest.preprocess")
suffix    <- getOption("shinytest.suffix")

msg_suffix <- shinytest:::normalize_suffix(suffix)

shinyApp(
  ui = bootstrapPage(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "diffviewerapp.css")
    ),
    div(class = "header",
      div(class = "title",
        paste0(
          "Differences between expected", msg_suffix,
          " (old) and current (new) test results for ",
          basename(app_dir), ": ", test_name
        )
      ),
      div(class = "controls",
        actionLink("accept",
          span(
            img(src = "exit-save.png", class = "diffviewer-icon"),
            "Update and quit",
            title = paste0(
              "Replace the expected", msg_suffix, " results with the current results"
            )
          )
        ),
        actionLink("reject",
          span(
            img(src = "exit-nosave.png", class = "diffviewer-icon"),
            "Quit",
            title = paste0("Leave the expected", msg_suffix, " results unchanged")
          )
        )
      )
    ),
    div(
      class = "content",
      shinytest::viewTestDiffWidget(app_dir, test_name, preprocess, suffix)
    )
  ),

  server = function(input, output) {
    observeEvent(input$accept, {
      shinytest::snapshotUpdate(app_dir, test_name, suffix = suffix)
      stopApp("accept")
    })

    observeEvent(input$reject, {
      stopApp("reject")
    })

    onSessionEnded(function() {
      # Quit the app if the user closes the window
      stopApp("reject")
    })
  }
)
