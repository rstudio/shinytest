
context("Widget$getValue")

test_that("Widget$getValue for all input widgets", {

  app <- ShinyDriver$new(test_path("apps/081-widgets-gallery"))

  ## checkboxInput
  expect_identical(
    app$findWidget("checkbox")$getValue(),
    TRUE
  )

  ## checkboxGroupInput
  expect_identical(
    app$findWidget("checkGroup")$getValue(),
    "1"
  )

  ## dateInput
  expect_identical(
    app$findWidget("date")$getValue(),
    as.Date("2014-01-01")
  )

  ## dateRangeInput
  expect_identical(
    app$findWidget("dates")$getValue(),
    as.Date(c("2014-01-01", "2015-01-01"))
  )

  ## fileInput, TODO

  ## numericInput
  expect_identical(
    app$findWidget("num")$getValue(),
    1L
  )

  ## radioButtons
  expect_identical(
    app$findWidget("radio")$getValue(),
    "1"
  )

  ## selectInput
  expect_identical(
    app$findWidget("select")$getValue(),
    "1"
  )

  ## sliderInput
  expect_identical(
    app$findWidget("slider1")$getValue(),
    50
  )

  ## sliderInput, range
  expect_identical(
    app$findWidget("slider2")$getValue(),
    c(25, 75)
  )

  ## textInput
  expect_identical(
    app$findWidget("text")$getValue(),
    "Enter text..."
  )

  ## passwordInput

})

test_that("Widget$getValue for all output widgets", {

  app <- ShinyDriver$new(test_path("apps/outputs"))

  ## htmlOutput
  expect_identical(
    app$findWidget("html")$getValue(),
    "<div><p>This is a paragraph.</p></div>"
  )
  expectUpdate(app, select = "h2", output = "html")
  expect_identical(
    app$findWidget("html")$getValue(),
    "<div><h2>This is a heading</h2></div>"
  )

  ## verbatimTextOutput
  expect_identical(
    app$findWidget("verbatim")$getValue(),
    "<b>This is verbatim, too</b>"
  )
  expectUpdate(app, select = "p", output = "verbatim")
  expect_identical(
    app$findWidget("verbatim")$getValue(),
    "This is verbatim, really. <div></div>"
  )

  ## textOutput
  expect_identical(
    app$findWidget("text")$getValue(),
    "This is text. <div></div>"
  )
  expectUpdate(app, select = "h2", output = "text")
  expect_identical(
    app$findWidget("text")$getValue(),
    "<b>This, too</b>"
  )

})
