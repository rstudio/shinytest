
context("updates")

test_that("simple updates", {

  app <- shinyapp$new("apps/050-kmeans-example")

  ## Not a real expectation yet
  expect_true(
    app$expect_update(xcol = "Sepal.Width", output = "plot1")
  )
  expect_true(
    app$expect_update(ycol = "Petal.Width", output = "plot1")
  )
  expect_true(
    app$expect_update(clusters = 4, output = "plot1")
  )
})
