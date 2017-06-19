
context("ShinyDriver")

test_that("able to initialize ShinyDriver", {
  #Very basic check to make sure that we can actually create a ShinyDriver
  expect_error(ShinyDriver$new(test_path("apps/081-widgets-gallery")), NA)
})

test_that("getValue", {

  app <- ShinyDriver$new(test_path("apps/081-widgets-gallery"))

  expect_true(app$getValue("checkbox"))
  expect_identical(app$getValue("checkGroup"), "1")
  expect_identical(app$getValue("date"), as.Date("2014-01-01"))
  expect_identical(app$getValue("dates"), as.Date(c("2014-01-01", "2015-01-01")))

  ## fileInput, TODO

  expect_identical(app$getValue("num"), 1L)
  expect_identical(app$getValue("radio"), "1")
  expect_identical(app$getValue("select"), "1")
  expect_identical(app$getValue("slider1"), 50)
  expect_identical(app$getValue("slider2"), c(25, 75))
  expect_identical(app$getValue("text"), "Enter text...")

  ## passwordInput, TODO
})

test_that("window size", {

  app <- ShinyDriver$new(test_path("apps/081-widgets-gallery"))

  app$setWindowSize(1200, 800);
  expect_identical(
    app$getWindowSize(),
    list(width = 1200L, height = 800L)
  )
})
