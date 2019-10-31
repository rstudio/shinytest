
context("Find tests")

test_that("Finds test files", {
  expect_equal(findTests("example_test_dirs/simple/tests"), c("testa.r", "testb.R"))

  # No files is empty
  expect_equal(findTests("example_test_dirs/"), character(0))
})

test_that("Filters out based on given test names", {
  expect_equal(findTests("example_test_dirs/simple/tests", "testa"), c("testa.r"))

  # Accepts with or without file extension
  expect_equal(findTests("example_test_dirs/simple/tests", "testb.r"), c("testb.R"))

  # Non-existant file filter errors
  expect_error(findTests("example_test_dirs/simple/tests", "i don't exist"))
})

test_that("findTestsDir works", {
  expect_match(suppressMessages(findTestsDir(test_path("example_test_dirs/simple/"))), "/tests$")
  expect_message(findTestsDir(test_path("example_test_dirs/simple/"), quiet=FALSE), "deprecated in the future")
  expect_match(findTestsDir(test_path("example_test_dirs/nested/")), "/shinytests$")

  # Use shinytests if it exists -- even if it's empty
  endir <- expect_warning(findTestsDir(test_path("example_test_dirs/empty-nested/"), quiet=FALSE), "there are some shinytests in")
  expect_match(endir, "/shinytests$")

  # Empty top-level recommends non-existant nested dir if top-level doesn't contain any shinytests
  expect_match(suppressMessages(findTestsDir(test_path("example_test_dirs/empty-toplevel/"), mustExist=FALSE)), "/tests/shinytests$")
  # Empty top-level with mustExist=TRUE errors
  expect_error(findTestsDir(test_path("example_test_dirs/empty-toplevel/"), mustExist=TRUE), "should be placed in tests/shinytests")

  # Non-shinytest files in the top-level dir cause an error
  expect_error(findTestsDir(test_path("example_test_dirs/mixed-toplevel/")))

  # Unless must-exist is false, in which case it gives us the nested dir optimistically
  expect_match(findTestsDir(test_path("example_test_dirs/"), mustExist=FALSE), "/shinytests$")

  expect_match(findTestsDir(test_path("example_test_dirs/nested/tests"), mustExist=FALSE), "/nested/tests/shinytests$")
})

test_that("isShinyTest works", {
  expect_false(isShinyTest("blah"))
  expect_true(isShinyTest("app<-ShinyDriver$new()"))
  expect_true(isShinyTest(c("blah", "app<-ShinyDriver$new()")))

  # Not sensitive to spacing
  expect_true(isShinyTest("app\t<-      ShinyDriver$new("))
})
