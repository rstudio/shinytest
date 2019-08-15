
context("Find tests")

test_that("Finds test files", {
  expect_equal(findTests("example_test_dirs/simple"), c("testa.r", "testb.R"))
})

test_that("Filters out based on given test names", {
  expect_equal(findTests("example_test_dirs/simple", "testa"), c("testa.r"))

  # Accepts with or without file extension
  expect_equal(findTests("example_test_dirs/simple", "testb.r"), c("testb.R"))

  # No files is empty
  expect_equal(findTests("example_test_dirs/"), character(0))

  # Non-existant file filter errors
  expect_error(findTests("example_test_dirs/simple", "i don't exist"))
})
