
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
})

test_that("simple updates", {

  app <- shinyapp$new("apps/050-kmeans-example")

  expect_update(app, xcol = "Sepal.Width", output = "plot1")
  expect_update(app, ycol = "Petal.Width", output = "plot1")
  expect_update(app, clusters = 4, output = "plot1")
})
