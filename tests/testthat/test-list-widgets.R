
context("list widgets")

test_that("list input & output widgets", {
  app <- shinyapp$new("apps/081-widgets-gallery")
  inputs <- app$list_input_widgets()

  expect_equal(
    sort(inputs),
    c("action", "checkbox", "checkGroup", "date", "dates", "file",
      "num", "radio", "select", "slider1", "slider2", "text")
  )

  outputs <- app$list_output_widgets()
  expect_equal(
    sort(outputs),
    c("actionOut", "checkboxOut", "checkGroupOut", "dateOut", "datesOut",
      "fileOut", "numOut", "radioOut", "selectOut", "slider1Out",
      "slider2Out", "textOut")
  )
})

test_that("warn for multiple widgets sharing an ID", {
  expect_warning(
    shinyapp$new("apps/id-conflicts-1"),
    "Possible duplicate input widget ids: select"
  )

  ## Actually apps, with duplicate output widget ids do not load currently
  expect_error(
    shinyapp$new("apps/id-conflicts-2", load_timeout = 1000),
    "Shiny app did not load"
  )

  expect_warning(
    shinyapp$new("apps/id-conflicts-3"),
    "Widget ids both for input and output: widget"
  )
})
