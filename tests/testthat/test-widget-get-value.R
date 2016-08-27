
context("widget$get_value")

test_that("widget$get_value for all widgets", {

  app <- shinyapp$new("apps/081-widgets-gallery")

  ## textInput
  expect_equal(
    app$find_widget("text", "input")$get_value(),
    "Enter text..."
  )

})
