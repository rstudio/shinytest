
context("widget$set_value")

test_that("widget$set_value for all input widgets", {

  app <- ShinyDriver$new("apps/081-widgets-gallery")

  ## numericInput
  expect_identical(
    app$find_widget("num")$set_value(42)$get_value(),
    42L
  )

  ## selectInput
  expect_identical(
    app$find_widget("select")$set_value(2)$get_value(),
    "2"
  )

  ## checkboxInput
  expect_true(
    app$find_widget("checkbox")$set_value(TRUE)$get_value()
  )
  expect_false(
    app$find_widget("checkbox")$set_value(FALSE)$get_value()
  )

  ## checkboxGroupInput
  expect_equal(
    app$find_widget("checkGroup")$set_value(c("1", "2"))$get_value(),
    c("1", "2")
  )
  expect_equal(
    app$find_widget("checkGroup")$set_value(c("3"))$get_value(),
    "3"
  )
  expect_equal(
    app$find_widget("checkGroup")$set_value(character())$get_value(),
    character()
  )

  ## dateInput
  expect_equal(
    app$find_widget("date")$set_value(Sys.Date())$get_value(),
    Sys.Date()
  )
  expect_equal(
    app$find_widget("date")$set_value(as.Date("2012-06-30"))$get_value(),
    as.Date("2012-06-30")
  )

  ## dateRangeInput
  v <- as.Date(c("2012-06-30", "2015-01-21"))
  expect_equal(
    as.character(app$find_widget("dates")$set_value(v)$get_value()),
    as.character(v)
  )

  ## radioButtons
  expect_equal(app$find_widget("radio")$set_value("1")$get_value(), "1")
  expect_equal(app$find_widget("radio")$set_value("2")$get_value(), "2")
  expect_equal(app$find_widget("radio")$set_value("3")$get_value(), "3")

  ## sliderInput, single
  expect_equal(app$find_widget("slider1")$set_value(42)$get_value(), 42)
  expect_equal(app$find_widget("slider1")$set_value(100)$get_value(), 100)
  expect_equal(app$find_widget("slider1")$set_value(0)$get_value(), 0)

  ## sliderInput double
  expect_equal(
    app$find_widget("slider2")$set_value(c(42, 42))$get_value(),
    c(42, 42)
  )
  expect_equal(
    app$find_widget("slider2")$set_value(c(0, 100))$get_value(),
    c(0,100)
  )
  expect_equal(
    app$find_widget("slider2")$set_value(c(1, 4))$get_value(),
    c(1, 4)
  )

  ## textInput
  expect_equal(
    app$find_widget("text")$set_value("Hello world!")$get_value(),
    "Hello world!"
  )

  ## passwordInput, TODO, this app does not have one
})
