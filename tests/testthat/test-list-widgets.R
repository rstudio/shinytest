
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

})

test_that("warn if input ID is the same as an output ID", {

})

