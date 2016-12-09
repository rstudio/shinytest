
context("mapping")

test_that("input widgets", {

  app <- ShinyDriver$new(test_path("apps/081-widgets-gallery"))

  expect_equal(app$findWidget("action")$getType(),     "actionButton")
  expect_equal(app$findWidget("checkbox")$getType(),   "checkboxInput")
  expect_equal(app$findWidget("checkGroup")$getType(), "checkboxGroupInput")
  expect_equal(app$findWidget("date")$getType(),       "dateInput")
  expect_equal(app$findWidget("dates")$getType(),      "dateRangeInput")
  expect_equal(app$findWidget("file")$getType(),       "fileInput")
  expect_equal(app$findWidget("num")$getType(),        "numericInput")
  expect_equal(app$findWidget("radio")$getType(),      "radioButtons")
  expect_equal(app$findWidget("select")$getType(),     "selectInput")
  expect_equal(app$findWidget("slider1")$getType(),    "sliderInput")
  expect_equal(app$findWidget("slider2")$getType(),    "sliderInput")
  expect_equal(app$findWidget("text")$getType(),       "textInput")
  
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
      app$findWidget(n, "output")$getType(),
      "verbatimTextOutput",
      info = n
    )
  }

})
