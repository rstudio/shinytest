
context("mapping")

test_that("input widgets", {

  app <- shinyapp$new("apps/081-widgets-gallery")

  expect_equal(app$find_widget("action")$type,     "actionButton")
  expect_equal(app$find_widget("checkbox")$type,   "checkboxInput")
  expect_equal(app$find_widget("checkGroup")$type, "checkboxGroupInput")
  expect_equal(app$find_widget("date")$type,       "dateInput")
  expect_equal(app$find_widget("dates")$type,      "dateRangeInput")
  expect_equal(app$find_widget("file")$type,       "fileInput")
  expect_equal(app$find_widget("num")$type,        "numericInput")
  expect_equal(app$find_widget("radio")$type,      "radioButtons")
  expect_equal(app$find_widget("select")$type,     "selectInput")
  expect_equal(app$find_widget("slider1")$type,    "sliderInput")
  expect_equal(app$find_widget("slider2")$type,    "sliderInput")
  expect_equal(app$find_widget("text")$type,       "textInput")
  
})
