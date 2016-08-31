
context("widget$get_value")

test_that("widget$get_value for all input widgets", {

  app <- shinyapp$new("apps/081-widgets-gallery")

  ## checkboxInput
  expect_identical(
    app$find_widget("checkbox")$get_value(),
    TRUE
  )

  ## checkboxGroupInput
  expect_identical(
    app$find_widget("checkGroup")$get_value(),
    "1"
  )

  ## dateInput
  expect_identical(
    app$find_widget("date")$get_value(),
    as.Date("2014-01-01")
  )

  ## dateRangeInput
  expect_identical(
    app$find_widget("dates")$get_value(),
    c(Sys.Date(), Sys.Date())
  )

  ## fileInput, TODO

  ## numericInput
  expect_identical(
    app$find_widget("num")$get_value(),
    1
  )

  ## radioButtons
  expect_identical(
    app$find_widget("radio")$get_value(),
    "1"
  )

  ## selectInput
  expect_identical(
    app$find_widget("select")$get_value(),
    "1"
  )

  ## sliderInput
  expect_identical(
    app$find_widget("slider1")$get_value(),
    50
  )

  ## sliderInput, range
  expect_identical(
    app$find_widget("slider2")$get_value(),
    c(25, 75)
  )

  ## textInput
  expect_identical(
    app$find_widget("text")$get_value(),
    "Enter text..."
  )

  ## passwordInput

})

test_that("widget$get_value for all output widgets", {

  app <- shinyapp$new("apps/outputs")

  ## htmlOutput
  expect_identical(
    app$find_widget("html")$get_value(),
    "<div><p>This is a paragraph.</p></div>"
  )
  expect_update(app, select = "h2", output = "html")
  expect_identical(
    app$find_widget("html")$get_value(),
    "<div><h2>This is a heading</h2></div>"
  )

  ## verbatimTextOutput
  expect_identical(
    app$find_widget("verbatim")$get_value(),
    "<b>This is verbatim, too</b>"
  )
  expect_update(app, select = "p", output = "verbatim")
  expect_identical(
    app$find_widget("verbatim")$get_value(),
    "This is verbatim, really. <div></div>"
  )

  ## textOutput
  expect_identical(
    app$find_widget("text")$get_value(),
    "This is text. <div></div>"
  )
  expect_update(app, select = "h2", output = "text")
  expect_identical(
    app$find_widget("text")$get_value(),
    "<b>This, too</b>"
  )

})
