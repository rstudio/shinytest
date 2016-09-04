
context("shinyapp")

test_that("get_value", {

  app <- shinyapp$new("apps/081-widgets-gallery")

  expect_true(app$get_value("checkbox"))
  expect_identical(app$get_value("checkGroup"), "1")
  expect_identical(app$get_value("date"), as.Date("2014-01-01"))
  expect_identical(app$get_value("dates"), c(Sys.Date(), Sys.Date()))

  ## fileInput, TODO

  expect_identical(app$get_value("num"), 1)
  expect_identical(app$get_value("radio"), "1")
  expect_identical(app$get_value("select"), "1")
  expect_identical(app$get_value("slider1"), 50)
  expect_identical(app$get_value("slider2"), c(25, 75))
  expect_identical(app$get_value("text"), "Enter text...")

  ## passwordInput, TODO
})
