
context("widget$setValue")

test_that("widget$setValue for all input widgets", {

  app <- ShinyDriver$new(test_path("apps/081-widgets-gallery"))

  ## numericInput
  expect_identical(
    app$find_widget("num")$setValue(42)$getValue(),
    42L
  )

  ## selectInput
  expect_identical(
    app$find_widget("select")$setValue(2)$getValue(),
    "2"
  )

  ## checkboxInput
  expect_true(
    app$find_widget("checkbox")$setValue(TRUE)$getValue()
  )
  expect_false(
    app$find_widget("checkbox")$setValue(FALSE)$getValue()
  )

  ## checkboxGroupInput
  expect_equal(
    app$find_widget("checkGroup")$setValue(c("1", "2"))$getValue(),
    c("1", "2")
  )
  expect_equal(
    app$find_widget("checkGroup")$setValue(c("3"))$getValue(),
    "3"
  )
  expect_equal(
    app$find_widget("checkGroup")$setValue(character())$getValue(),
    character()
  )

  ## dateInput
  expect_equal(
    app$find_widget("date")$setValue(Sys.Date())$getValue(),
    Sys.Date()
  )
  expect_equal(
    app$find_widget("date")$setValue(as.Date("2012-06-30"))$getValue(),
    as.Date("2012-06-30")
  )

  ## dateRangeInput
  v <- as.Date(c("2012-06-30", "2015-01-21"))
  expect_equal(
    as.character(app$find_widget("dates")$setValue(v)$getValue()),
    as.character(v)
  )

  ## radioButtons
  expect_equal(app$find_widget("radio")$setValue("1")$getValue(), "1")
  expect_equal(app$find_widget("radio")$setValue("2")$getValue(), "2")
  expect_equal(app$find_widget("radio")$setValue("3")$getValue(), "3")

  ## sliderInput, single
  expect_equal(app$find_widget("slider1")$setValue(42)$getValue(), 42)
  expect_equal(app$find_widget("slider1")$setValue(100)$getValue(), 100)
  expect_equal(app$find_widget("slider1")$setValue(0)$getValue(), 0)

  ## sliderInput double
  expect_equal(
    app$find_widget("slider2")$setValue(c(42, 42))$getValue(),
    c(42, 42)
  )
  expect_equal(
    app$find_widget("slider2")$setValue(c(0, 100))$getValue(),
    c(0,100)
  )
  expect_equal(
    app$find_widget("slider2")$setValue(c(1, 4))$getValue(),
    c(1, 4)
  )

  ## textInput
  expect_equal(
    app$find_widget("text")$setValue("Hello world!")$getValue(),
    "Hello world!"
  )

  ## passwordInput, TODO, this app does not have one
})
