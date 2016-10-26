context("Snapshot values")

app <- shinyapp$new(test_path("apps/test-snapshot/"))

test_that("Snapshot values", {
  x <- app$get_all_values()
  expect_identical(x$snapshot$x, 1)
  expect_identical(x$snapshot$y, 2)

  app$set_inputs(inc = "click")
  app$set_inputs(inc = "click")

  x <- app$get_all_values()
  expect_identical(x$snapshot$x, 3)
  expect_identical(x$snapshot$y, 4)
})
