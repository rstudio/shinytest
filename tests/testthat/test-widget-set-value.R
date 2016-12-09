
context("Widget$setValue")

test_that("Widget$setValue for all input widgets", {

  app <- ShinyDriver$new(test_path("apps/081-widgets-gallery"))

  ## numericInput
  expect_identical(
    app$findWidget("num")$setValue(42)$getValue(),
    42L
  )

  ## selectInput
  expect_identical(
    app$findWidget("select")$setValue(2)$getValue(),
    "2"
  )

  ## checkboxInput
  expect_true(
    app$findWidget("checkbox")$setValue(TRUE)$getValue()
  )
  expect_false(
    app$findWidget("checkbox")$setValue(FALSE)$getValue()
  )

  ## checkboxGroupInput
  expect_equal(
    app$findWidget("checkGroup")$setValue(c("1", "2"))$getValue(),
    c("1", "2")
  )
  expect_equal(
    app$findWidget("checkGroup")$setValue(c("3"))$getValue(),
    "3"
  )
  expect_equal(
    app$findWidget("checkGroup")$setValue(character())$getValue(),
    character()
  )

  ## dateInput
  expect_equal(
    app$findWidget("date")$setValue(Sys.Date())$getValue(),
    Sys.Date()
  )
  expect_equal(
    app$findWidget("date")$setValue(as.Date("2012-06-30"))$getValue(),
    as.Date("2012-06-30")
  )

  ## dateRangeInput
  v <- as.Date(c("2012-06-30", "2015-01-21"))
  expect_equal(
    as.character(app$findWidget("dates")$setValue(v)$getValue()),
    as.character(v)
  )

  ## radioButtons
  expect_equal(app$findWidget("radio")$setValue("1")$getValue(), "1")
  expect_equal(app$findWidget("radio")$setValue("2")$getValue(), "2")
  expect_equal(app$findWidget("radio")$setValue("3")$getValue(), "3")

  ## sliderInput, single
  expect_equal(app$findWidget("slider1")$setValue(42)$getValue(), 42)
  expect_equal(app$findWidget("slider1")$setValue(100)$getValue(), 100)
  expect_equal(app$findWidget("slider1")$setValue(0)$getValue(), 0)

  ## sliderInput double
  expect_equal(
    app$findWidget("slider2")$setValue(c(42, 42))$getValue(),
    c(42, 42)
  )
  expect_equal(
    app$findWidget("slider2")$setValue(c(0, 100))$getValue(),
    c(0,100)
  )
  expect_equal(
    app$findWidget("slider2")$setValue(c(1, 4))$getValue(),
    c(1, 4)
  )

  ## textInput
  expect_equal(
    app$findWidget("text")$setValue("Hello world!")$getValue(),
    "Hello world!"
  )

  ## passwordInput, TODO, this app does not have one
})
