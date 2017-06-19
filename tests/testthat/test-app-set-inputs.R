context("app$setInputs")

app <- ShinyDriver$new(test_path("apps/081-widgets-gallery"))

test_that("app$setInputs for all input widgets", {
  # Check initial values
  x <- app$getAllValues()
  expect_identical(
    x$input$action,
    structure(0L, class = c("integer", "shinyActionButtonValue"))
  )
  expect_identical(x$input$checkbox, TRUE)
  expect_identical(x$input$checkGroup, "1")
  expect_identical(x$input$date, as.Date("2014-01-01"))
  expect_identical(x$input$dates, as.Date(c("2014-01-01", "2015-01-01")))
  expect_identical(x$input$num, 1L)
  expect_identical(x$input$radio, "1")
  expect_identical(x$input$select, "1")
  expect_identical(x$input$slider1, 50L)
  expect_identical(x$input$slider2, c(25L, 75L))
  expect_identical(x$input$text, "Enter text...")

  # Set inputs
  x <- app$setInputs(
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
    x$input$action,
    structure(1L, class = c("integer", "shinyActionButtonValue"))
  )
  expect_identical(
    '[1] 1\nattr(,"class")\n[1] "integer"                "shinyActionButtonValue"',
    x$output$actionOut
  )
  expect_identical(x$input$checkbox, FALSE)
  expect_identical(x$output$checkboxOut, "[1] FALSE")
  expect_identical(x$input$checkGroup, c("2", "3"))
  expect_identical(x$output$checkGroupOut, '[1] "2" "3"')
  expect_identical(x$input$date, as.Date("2016-01-01"))
  expect_identical(x$output$dateOut, '[1] "2016-01-01"')
  expect_identical(x$input$dates, as.Date(c("2016-01-01", "2016-12-31")))
  expect_identical(x$output$datesOut, '[1] "2016-01-01" "2016-12-31"')
  expect_identical(x$input$num, 42L)
  expect_identical(x$output$numOut, "[1] 42")
  expect_identical(x$input$radio, "2")
  expect_identical(x$output$radioOut, '[1] "2"')
  expect_identical(x$input$select, "2")
  expect_identical(x$output$selectOut, '[1] "2"')
  expect_identical(x$input$slider1, 80L)
  expect_identical(x$output$slider1Out, "[1] 80")
  expect_identical(x$input$slider2, c(10L, 90L))
  expect_identical(x$output$slider2Out, "[1] 10 90")
  expect_identical(x$input$text, "Hello")
  expect_identical(x$output$textOut, '[1] "Hello"')
})


test_that("app$uploadFile for file inputs", {
  x <- app$uploadFile(file = test_path("apps/081-widgets-gallery/DESCRIPTION"))
  expect_true(grepl("DESCRIPTION", x$output$fileOut))
})
