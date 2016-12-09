
context("updates")

test_that("updates for all widget in the gallery", {

  app <- ShinyDriver$new(test_path("apps/081-widgets-gallery"))

  expectUpdate(app, checkbox = FALSE, output = "checkboxOut")
  expect_equal(app$getValue("checkboxOut"), "[1] FALSE")
  expectUpdate(app, checkbox = TRUE, output = "checkboxOut")
  expect_equal(app$getValue("checkboxOut"), "[1] TRUE")

  expectUpdate(app, checkGroup = c("1", "3"), output = "checkGroupOut")
  expect_equal(app$getValue("checkGroupOut"), c('[1] "1" "3"'))
  expectUpdate(app, checkGroup = c("2"), output = "checkGroupOut")
  expect_equal(app$getValue("checkGroupOut"), c('[1] "2"'))

  expectUpdate(app, date = as.Date("2015-01-21"), output = "dateOut")
  expect_equal(app$getValue("dateOut"), "[1] \"2015-01-21\"")

  ## We only change the start, because that already triggers an
  ## update. The end date would trigger another one, but possibly
  ## later than us checking the value here. Then we change the end date
  ## in another test
  v <- c(as.Date("2012-06-30"), Sys.Date())
  expectUpdate(app, dates = v, output = "datesOut")
  expect_equal(app$getValue("datesOut"), capture.output(print(v)))

  v <- as.Date(c("2012-06-30", "2015-01-21"))
  expectUpdate(app, dates = v, output = "datesOut")
  expect_equal(app$getValue("datesOut"), capture.output(print(v)))

  ## We cannot check the value of the output easily, because
  ## setValue() is not atomic for the input widget, and the output
  ## watcher finishes before its final value is set
  expectUpdate(app, num = 42, output = "numOut")
  expect_true(
    app$waitFor("$('#numOut.shiny-bound-output').text() == '[1] 42'")
  )
  expect_equal(app$getValue("numOut"), "[1] 42")

  expectUpdate(app, radio = "2", output = "radioOut")
  expect_equal(app$getValue("radioOut"), '[1] "2"')

  expectUpdate(app, select = "2", output = "selectOut")
  expect_equal(app$getValue("selectOut"), '[1] "2"')

  expectUpdate(app, slider1 = 42, output = "slider1Out")
  expect_equal(app$getValue("slider1Out"), '[1] 42')

  expectUpdate(app, slider2 = c(0, 100), output = "slider2Out")
  expect_equal(app$getValue("slider2Out"), '[1]   0 100')

  expectUpdate(app, text = "foobar", output = "textOut")
  expect_true(
    app$waitFor("$('#textOut.shiny-bound-output').text() == '[1] \"foobar\"'")
  )
  expect_equal(app$getValue("textOut"), "[1] \"foobar\"")
})

test_that("simple updates", {

  app <- ShinyDriver$new(test_path("apps/050-kmeans-example"))

  expectUpdate(app, xcol = "Sepal.Width", output = "plot1")
  expectUpdate(app, ycol = "Petal.Width", output = "plot1")
  expectUpdate(app, clusters = 4, output = "plot1")
})
