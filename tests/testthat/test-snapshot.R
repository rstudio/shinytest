context("Snapshots from server")

app <- shinyapp$new(test_path("apps/test-snapshot/"))

test_that("app$get_snapshot", {
  x <- app$get_snapshot()
  expect_identical(x$x, 1)
  expect_identical(x$y, 2)

  app$set_inputs(inc = "click")
  app$set_inputs(inc = "click")

  x <- app$get_snapshot()
  expect_identical(x$x, 3)
  expect_identical(x$y, 4)
})
