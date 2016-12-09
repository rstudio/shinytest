
context("widget$set_value")

test_that("widget$set_value for all input widgets", {

  app <- ShinyDriver$new(test_path("apps/081-widgets-gallery"))

  ## numericInput
  expect_identical(
    app$find_widget("num")$set_value(42)$getValue(),
    42L
  )

  ## selectInput
  expect_identical(
    app$find_widget("select")$set_value(2)$getValue(),
    "2"
  )

  ## checkboxInput
  expect_true(
    app$find_widget("checkbox")$set_value(TRUE)$getValue()
  )
  expect_false(
    app$find_widget("checkbox")$set_value(FALSE)$getValue()
  )

  ## checkboxGroupInput
  expect_equal(
    app$find_widget("checkGroup")$set_value(c("1", "2"))$getValue(),
    c("1", "2")
  )
  expect_equal(
    app$find_widget("checkGroup")$set_value(c("3"))$getValue(),
    "3"
  )
  expect_equal(
    app$find_widget("checkGroup")$set_value(character())$getValue(),
    character()
  )

  ## dateInput
  expect_equal(
    app$find_widget("date")$set_value(Sys.Date())$getValue(),
    Sys.Date()
  )
  expect_equal(
    app$find_widget("date")$set_value(as.Date("2012-06-30"))$getValue(),
    as.Date("2012-06-30")
  )

  ## dateRangeInput
  v <- as.Date(c("2012-06-30", "2015-01-21"))
  expect_equal(
    as.character(app$find_widget("dates")$set_value(v)$getValue()),
    as.character(v)
  )

  ## radioButtons
  expect_equal(app$find_widget("radio")$set_value("1")$getValue(), "1")
  expect_equal(app$find_widget("radio")$set_value("2")$getValue(), "2")
  expect_equal(app$find_widget("radio")$set_value("3")$getValue(), "3")

  ## sliderInput, single
  expect_equal(app$find_widget("slider1")$set_value(42)$getValue(), 42)
  expect_equal(app$find_widget("slider1")$set_value(100)$getValue(), 100)
  expect_equal(app$find_widget("slider1")$set_value(0)$getValue(), 0)

  ## sliderInput double
  expect_equal(
    app$find_widget("slider2")$set_value(c(42, 42))$getValue(),
    c(42, 42)
  )
  expect_equal(
    app$find_widget("slider2")$set_value(c(0, 100))$getValue(),
    c(0,100)
  )
  expect_equal(
    app$find_widget("slider2")$set_value(c(1, 4))$getValue(),
    c(1, 4)
  )

  ## textInput
  expect_equal(
    app$find_widget("text")$set_value("Hello world!")$getValue(),
    "Hello world!"
  )

  ## passwordInput, TODO, this app does not have one
})
