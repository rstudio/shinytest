
context("Issues are fixed")

test_that("numeric input recovers from receiving bad input", {

  app <- ShinyDriver$new(test_path("apps/issue-24"))
  expect_equal(
    app$findWidget("num")$setValue("bogus")$setValue(8)$getValue(),
    8
  )
})
