
context("mapping")

test_that("input widgets", {

  app <- ShinyDriver$new(test_path("apps/081-widgets-gallery"))

  expect_equal(app$findWidget("action")$get_type(),     "actionButton")
  expect_equal(app$findWidget("checkbox")$get_type(),   "checkboxInput")
  expect_equal(app$findWidget("checkGroup")$get_type(), "checkboxGroupInput")
  expect_equal(app$findWidget("date")$get_type(),       "dateInput")
  expect_equal(app$findWidget("dates")$get_type(),      "dateRangeInput")
  expect_equal(app$findWidget("file")$get_type(),       "fileInput")
  expect_equal(app$findWidget("num")$get_type(),        "numericInput")
  expect_equal(app$findWidget("radio")$get_type(),      "radioButtons")
  expect_equal(app$findWidget("select")$get_type(),     "selectInput")
  expect_equal(app$findWidget("slider1")$get_type(),    "sliderInput")
  expect_equal(app$findWidget("slider2")$get_type(),    "sliderInput")
  expect_equal(app$findWidget("text")$get_type(),       "textInput")
  
})

test_that("output widgets with the same name", {

  app <- ShinyDriver$new(test_path("apps/081-widgets-gallery"))

  names <- c(
    "actionOut", "checkboxOut", "checkGroupOut", "dateOut", "datesOut",
    "fileOut", "numOut", "radioOut", "selectOut", "slider1Out",
    "slider2Out", "textOut"
  )

  for (n in names) {
    expect_equal(
      app$findWidget(n, "output")$get_type(),
      "verbatimTextOutput",
      info = n
    )
  }

})
