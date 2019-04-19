
context("list widgets")

test_that("list input & output widgets", {
  app <- ShinyDriver$new(test_path("apps/081-widgets-gallery"))
  widgets <- app$listWidgets()
  inputs <- widgets$input

  expect_equal(
    sort(inputs),
    sort(c("action", "checkbox", "checkGroup", "date", "dates", "file",
           "num", "radio", "select", "select-selectized", "slider1", "slider2", "text"))
  )

  outputs <- widgets$output
  expect_equal(
    sort(outputs),
    sort(c("actionOut", "checkboxOut", "checkGroupOut", "dateOut",
           "datesOut", "fileOut", "numOut", "radioOut", "selectOut",
           "slider1Out", "slider2Out", "textOut"))
  )
})

test_that("warn for multiple widgets sharing an ID", {
  expect_warning(
    ShinyDriver$new(test_path("apps/id-conflicts-1")),
    "Possible duplicate input widget ids: select"
  )

  ## Actually apps, with duplicate output widget ids do not load currently
  expect_error(
    ShinyDriver$new(test_path("apps/id-conflicts-2"), loadTimeout = 1000),
    "Shiny app did not load"
  )

  expect_warning(
    ShinyDriver$new(test_path("apps/id-conflicts-3")),
    "Widget ids both for input and output: widget"
  )
})
