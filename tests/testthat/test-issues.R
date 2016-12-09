
context("Issues are fixed")

test_that("numeric input recovers from receiving bad input", {

  app <- ShinyDriver$new(test_path("apps/issue-24"))
  expect_equal(
    app$find_widget("num")$set_value("bogus")$set_value(8)$getValue(),
    8
  )
})
