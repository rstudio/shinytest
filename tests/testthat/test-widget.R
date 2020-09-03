test_that("can find value of input controls", {
  app <- ShinyDriver$new(test_path("apps/081-widgets-gallery"))
  expect_identical(app$getValue("checkbox"), TRUE)
  expect_identical(app$getValue("checkGroup"), "1")
  expect_identical(app$getValue("date"), as.Date("2014-01-01"))
  expect_identical(app$getValue("dates"), as.Date(c("2014-01-01", "2015-01-01")))
  expect_identical(app$getValue("num"), 1L)
  expect_identical(app$getValue("radio"), "1")
  expect_identical(app$getValue("select"), "1")
  expect_identical(app$getValue("slider1"), 50)
  expect_identical(app$getValue("slider2"), c(25, 75))
  expect_identical(app$getValue("text"), "Enter text...")
})

test_that("can set values of all input controls", {
  app <- ShinyDriver$new(test_path("apps/081-widgets-gallery"))

  roundtrip <- function(app, name, value) {
    app$findWidget(name)$setValue(value)$getValue()
  }

  expect_identical(roundtrip(app, "num", 42), 42L)
  expect_identical(roundtrip(app, "select", 2), "2")

  ## checkboxInput
  expect_true(roundtrip(app, "checkbox", TRUE))
  expect_false(roundtrip(app, "checkbox", FALSE))

  ## checkboxGroupInput
  expect_equal(roundtrip(app, "checkGroup", c("1", "2")), c("1", "2"))
  expect_equal(roundtrip(app, "checkGroup", "3"), "3")
  expect_equal(roundtrip(app, "checkGroup", character()), character())

  ## dateInput
  date <- as.Date("2012-06-30")
  expect_equal(roundtrip(app, "date", date), date)

  ## dateRangeInput
  dates <- as.Date(c("2012-06-30", "2015-01-21"))
  expect_equal(roundtrip(app, "dates", dates), dates)

  ## radioButtons
  expect_equal(roundtrip(app, "radio", "1"), "1")
  expect_equal(roundtrip(app, "radio", "2"), "2")
  expect_equal(roundtrip(app, "radio", "3"), "3")

  ## sliderInput, single
  expect_equal(roundtrip(app, "slider1", 42), 42)
  expect_equal(roundtrip(app, "slider1", 100), 100)
  expect_equal(roundtrip(app, "slider1", 0), 0)

  ## sliderInput double
  expect_equal(roundtrip(app, "slider2", c(42, 42)), c(42, 42))
  expect_equal(roundtrip(app, "slider2", c(0, 100)), c(0,100))
  expect_equal(roundtrip(app, "slider2", c(1, 4)), c(1, 4))

  ## textInput
  expect_equal(roundtrip(app, "text", "Hello world!"), "Hello world!")

  ## passwordInput, TODO, this app does not have one
})

test_that("can find value of output controls", {
  app <- ShinyDriver$new(test_path("apps/outputs"))
  expect_identical(app$getValue("html"), "<div><p>This is a paragraph.</p></div>")
  expect_identical(app$getValue("verbatim"),"This is verbatim, really. <div></div>")
  expect_identical(app$getValue("text"), "This is text. <div></div>")

  app$setInputs(select = "h2")
  expect_identical(app$getValue("html"), "<div><h2>This is a heading</h2></div>")
  expect_identical(app$getValue("verbatim"), "<b>This is verbatim, too</b>")
  expect_identical(app$getValue("text"), "<b>This, too</b>")
})

test_that("can click buttons", {
  app <- ShinyDriver$new(test_path("apps/click-me"))

  w <- app$findWidget("click")
  w$click()
  w$click()

  app$waitForShiny()
  expect_equal(app$getValue("i"), "2")
})

test_that("can retrieve widget metadata", {
  app <- ShinyDriver$new(test_path("apps/click-me"))
  w <- app$findWidget("click")
  expect_match(w$getHtml(), "<button")
})
