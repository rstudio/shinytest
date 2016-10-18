context("app$set_inputs")


test_that("app$set_inputs for all input widgets", {
  app <- shinyapp$new(test_path("apps/081-widgets-gallery"))

  # Check initial values
  x <- app$get_all_values()
  expect_identical(
    x$inputs$action,
    structure(0L, class = c("integer", "shinyActionButtonValue"))
  )
  expect_identical(x$inputs$checkbox, TRUE)
  expect_identical(x$inputs$checkGroup, "1")
  expect_identical(x$inputs$date, as.Date("2014-01-01"))
  expect_identical(x$inputs$dates, rep(Sys.Date(), 2))
  expect_identical(x$inputs$num, 1L)
  expect_identical(x$inputs$radio, "1")
  expect_identical(x$inputs$select, "1")
  expect_identical(x$inputs$slider1, 50L)
  expect_identical(x$inputs$slider2, c(25L, 75L))
  expect_identical(x$inputs$text, "Enter text...")

  # Set inputs
  x <- app$set_inputs(
    action = "click",
    checkbox = FALSE,
    checkGroup = c("2", "3"),
    date = as.Date("2016-01-01"),
    dates = c("2016-01-01", "2016-12-31"),
    num = 42,
    radio = "2",
    select = "2",
    slider1 = 80,
    slider2 = c(10, 90),
    text = "Hello"
  )

  expect_identical(
    x$inputs$action,
    structure(1L, class = c("integer", "shinyActionButtonValue"))
  )
  expect_identical(
    '[1] 1\nattr(,"class")\n[1] "integer"                "shinyActionButtonValue"',
    x$outputs$actionOut
  )
  expect_identical(x$inputs$checkbox, FALSE)
  expect_identical(x$outputs$checkboxOut, "[1] FALSE")
  expect_identical(x$inputs$checkGroup, c("2", "3"))
  expect_identical(x$outputs$checkGroupOut, '[1] "2" "3"')
  expect_identical(x$inputs$date, as.Date("2016-01-01"))
  expect_identical(x$outputs$dateOut, '[1] "2016-01-01"')
  expect_identical(x$inputs$dates, as.Date(c("2016-01-01", "2016-12-31")))
  expect_identical(x$outputs$datesOut, '[1] "2016-01-01" "2016-12-31"')
  expect_identical(x$inputs$num, 42L)
  expect_identical(x$outputs$numOut, "[1] 42")
  expect_identical(x$inputs$radio, "2")
  expect_identical(x$outputs$radioOut, '[1] "2"')
  expect_identical(x$inputs$select, "2")
  expect_identical(x$outputs$selectOut, '[1] "2"')
  expect_identical(x$inputs$slider1, 80L)
  expect_identical(x$outputs$slider1Out, "[1] 80")
  expect_identical(x$inputs$slider2, c(10L, 90L))
  expect_identical(x$outputs$slider2Out, "[1] 10 90")
  expect_identical(x$inputs$text, "Hello")
  expect_identical(x$outputs$textOut, '[1] "Hello"')
})
