
context("updates")

test_that("updates for all widget in the gallery", {

  app <- shinyapp$new("apps/081-widgets-gallery")

  expect_update(app, checkbox = FALSE, output = "checkbox")
  expect_equal(app$get_value("checkbox", "output"), "[1] FALSE")
  expect_update(app, checkbox = TRUE, output = "checkbox")
  expect_equal(app$get_value("checkbox", "output"), "[1] TRUE")

  expect_update(app, checkGroup = c("1", "3"), output = "checkGroup")
  expect_equal(app$get_value("checkGroup"), c("1", "3"))
  expect_update(app, checkGroup = c("2"), output = "checkGroup")
  expect_equal(app$get_value("checkGroup"), c("2"))

  expect_update(app, date = as.Date("2015-01-21"), output = "date")
  expect_equal(app$get_value("date", "output"), "[1] \"2015-01-21\"")

  ## We only change the start, because that already triggers an
  ## update. The end date would trigger another one, but possibly
  ## later than us checking the value here. Then we change the end date
  ## in another test
  v <- c(as.Date("2012-06-30"), Sys.Date())
  expect_update(app, dates = v, output = "dates")
  expect_equal(app$get_value("dates", "output"), capture.output(print(v)))

  v <- as.Date(c("2012-06-30", "2015-01-21"))
  expect_update(app, dates = v, output = "dates")
  expect_equal(app$get_value("dates", "output"), capture.output(print(v)))

  ## We cannot check the value of the output easily, because
  ## set_value() is not atomic for the input widget, and the output
  ## watcher finishes before its final value is set
  expect_update(app, num = 42, output = "num")
  expect_true(
    app$wait_for("$('#num.shiny-bound-output').text() == '[1] 42'")
  )
  expect_equal(app$get_value("num", "output"), "[1] 42")

  expect_update(app, radio = "2", output = "radio")
  expect_equal(app$get_value("radio"), "2")

  expect_update(app, select = "2", output = "select")
  expect_equal(app$get_value("select"), "2")

  expect_update(app, slider1 = 42, output = "slider1")
  expect_equal(app$get_value("slider1"), 42)

  expect_update(app, slider2 = c(0, 100), output = "slider2")
  expect_equal(app$get_value("slider2"), c(0, 100))

  expect_update(app, text = "foobar", output = "text")
  expect_true(
    app$wait_for("$('#text.shiny-bound-output').text() == '[1] \"foobar\"'")
  )
  expect_equal(app$get_value("text", "output"), "[1] \"foobar\"")
})

test_that("simple updates", {

  app <- shinyapp$new("apps/050-kmeans-example")

  expect_update(app, xcol = "Sepal.Width", output = "plot1")
  expect_update(app, ycol = "Petal.Width", output = "plot1")
  expect_update(app, clusters = 4, output = "plot1")
})
