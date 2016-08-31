
context("updates")

test_that("simple updates", {

  app <- shinyapp$new("apps/050-kmeans-example")

  expect_update(app, xcol = "Sepal.Width", output = "plot1")
  expect_update(app, ycol = "Petal.Width", output = "plot1")
  expect_update(app, clusters = 4, output = "plot1")
})
