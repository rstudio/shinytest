
context("mapping")

test_that("input widgets", {

  app <- shinyapp$new("apps/081-widgets-gallery")

  expect_equal(app$find_widget("action")$get_type(),     "actionButton")
  expect_equal(app$find_widget("checkbox")$get_type(),   "checkboxInput")
  expect_equal(app$find_widget("checkGroup")$get_type(), "checkboxGroupInput")
  expect_equal(app$find_widget("date")$get_type(),       "dateInput")
  expect_equal(app$find_widget("dates")$get_type(),      "dateRangeInput")
  expect_equal(app$find_widget("file")$get_type(),       "fileInput")
  expect_equal(app$find_widget("num")$get_type(),        "numericInput")
  expect_equal(app$find_widget("radio")$get_type(),      "radioButtons")
  expect_equal(app$find_widget("select")$get_type(),     "selectInput")
  expect_equal(app$find_widget("slider1")$get_type(),    "sliderInput")
  expect_equal(app$find_widget("slider2")$get_type(),    "sliderInput")
  expect_equal(app$find_widget("text")$get_type(),       "textInput")
  
})

test_that("output widgets with the same name", {

  app <- shinyapp$new("apps/081-widgets-gallery")

  names <- c(
    "action", "checkbox", "checkGroup", "date", "dates", "file", "num",
    "radio", "select", "slider1", "slider2", "text"
  )

  for (n in names) {
    expect_equal(
      app$find_widget(n, "output")$get_type(),
      "verbatimTextOutput",
      info = n
    )
  }

})
