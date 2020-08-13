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
