
context("ShinyDriver")

test_that("getValue", {

  app <- ShinyDriver$new(test_path("apps/081-widgets-gallery"))

  expect_true(app$getValue("checkbox"))
  expect_identical(app$getValue("checkGroup"), "1")
  expect_identical(app$getValue("date"), as.Date("2014-01-01"))
  expect_identical(app$getValue("dates"), c(Sys.Date(), Sys.Date()))

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

  app$set_window_size(1200, 800);
  expect_identical(
    app$get_window_size(),
    list(width = 1200L, height = 800L)
  )
})
