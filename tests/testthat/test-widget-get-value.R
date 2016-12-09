
context("widget$getValue")

test_that("widget$getValue for all input widgets", {

  app <- ShinyDriver$new(test_path("apps/081-widgets-gallery"))

  ## checkboxInput
  expect_identical(
    app$find_widget("checkbox")$getValue(),
    TRUE
  )

  ## checkboxGroupInput
  expect_identical(
    app$find_widget("checkGroup")$getValue(),
    "1"
  )

  ## dateInput
  expect_identical(
    app$find_widget("date")$getValue(),
    as.Date("2014-01-01")
  )

  ## dateRangeInput
  expect_identical(
    app$find_widget("dates")$getValue(),
    c(Sys.Date(), Sys.Date())
  )

  ## fileInput, TODO

  ## numericInput
  expect_identical(
    app$find_widget("num")$getValue(),
    1L
  )

  ## radioButtons
  expect_identical(
    app$find_widget("radio")$getValue(),
    "1"
  )

  ## selectInput
  expect_identical(
    app$find_widget("select")$getValue(),
    "1"
  )

  ## sliderInput
  expect_identical(
    app$find_widget("slider1")$getValue(),
    50
  )

  ## sliderInput, range
  expect_identical(
    app$find_widget("slider2")$getValue(),
    c(25, 75)
  )

  ## textInput
  expect_identical(
    app$find_widget("text")$getValue(),
    "Enter text..."
  )

  ## passwordInput

})

test_that("widget$getValue for all output widgets", {

  app <- ShinyDriver$new(test_path("apps/outputs"))

  ## htmlOutput
  expect_identical(
    app$find_widget("html")$getValue(),
    "<div><p>This is a paragraph.</p></div>"
  )
  expect_update(app, select = "h2", output = "html")
  expect_identical(
    app$find_widget("html")$getValue(),
    "<div><h2>This is a heading</h2></div>"
  )

  ## verbatimTextOutput
  expect_identical(
    app$find_widget("verbatim")$getValue(),
    "<b>This is verbatim, too</b>"
  )
  expect_update(app, select = "p", output = "verbatim")
  expect_identical(
    app$find_widget("verbatim")$getValue(),
    "This is verbatim, really. <div></div>"
  )

  ## textOutput
  expect_identical(
    app$find_widget("text")$getValue(),
    "This is text. <div></div>"
  )
  expect_update(app, select = "h2", output = "text")
  expect_identical(
    app$find_widget("text")$getValue(),
    "<b>This, too</b>"
  )

})
