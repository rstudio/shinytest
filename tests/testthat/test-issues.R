
context("Issues are fixed")

test_that("numeric input recovers from receiving bad input", {

  app <- shinyapp$new("apps/issue-24")
  expect_equal(
    app$find_widget("num")$set_value("bogus")$set_value(8)$get_value(),
    8
  )
})
