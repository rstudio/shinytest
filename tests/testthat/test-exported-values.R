context("Exported values")

app <- ShinyDriver$new(test_path("apps/test-exports/"))

test_that("Exported values", {
  x <- app$getAllValues()
  expect_identical(x$export$x, 1)
  expect_identical(x$export$y, 2)

  app$setInputs(inc = "click")
  app$setInputs(inc = "click")

  x <- app$getAllValues()
  expect_identical(x$export$x, 3)
  expect_identical(x$export$y, 4)
})
