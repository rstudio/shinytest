
context("widget$set_value")

test_that("widget$set_value for all input widgets", {

  app <- shinyapp$new("apps/081-widgets-gallery")

  ## numericInput
  expect_identical(
    app$find_widget("num")$set_value(42)$get_value(),
    42
  )

  ## selectInput
  expect_identical(
    app$find_widget("select")$set_value(2)$get_value(),
    "2"
  )
})
