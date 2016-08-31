
context("updates")

test_that("simple updates", {

  app <- shinyapp$new("apps/050-kmeans-example")

  ## Not a real test yet
  app$expect_update(xcol = "Sepal.Width", output = "plot1")
  app$expect_update(ycol = "Petal.Width", output = "plot1")
  app$expect_update(clusters = 4, output = "plot1")

})
