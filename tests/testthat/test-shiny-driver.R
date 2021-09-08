sleep_on_ci()
app <- ShinyDriver$new(test_path("apps/081-widgets-gallery"))

test_that("getValue", {
  expect_true(app$waitForShiny())

  expect_true(app$getValue("checkbox"))
  expect_identical(app$getValue("checkGroup"), "1")
  expect_identical(app$getValue("date"), as.Date("2014-01-01"))
  expect_identical(app$getValue("dates"), as.Date(c("2014-01-01", "2015-01-01")))
  expect_identical(app$getValue("num"), 1L)
  expect_identical(app$getValue("radio"), "1")
  expect_identical(app$getValue("select"), "1")
  expect_identical(app$getValue("slider1"), 50)
  expect_identical(app$getValue("slider2"), c(25, 75))
  expect_identical(app$getValue("text"), "Enter text...")
  ## TODO: fileInput, passwordInput
})

test_that("can take screenshot of element", {
  skip_on_os(c("linux", "windows"))

  app$takeScreenshot(test_path("test-shiny-driver-num.png"), id = "num")
  app$takeScreenshot(test_path("test-shiny-driver-num-parent.png"), id = "num", parent = TRUE)

  # Requires manual check —
  # should switch to testthat::expect_snapshot_image() when available
  succeed()
})

test_that("window size", {
  app$setWindowSize(1200, 800)
  expect_identical(app$getWindowSize(), list(width = 1200L, height = 800L))
})

test_that("can change pass render_args to rmarkdown::run()", {
  sleep_on_ci()
  doc <- ShinyDriver$new(
    test_path("apps/render-args/doc.Rmd"),
    renderArgs = list(params = list(name = "Mary"))
  )
  # Wait for value to appear as there are a couple of ticks
  # to wait for when displaying on an Rmd file
  doc$waitForValue("test")
  expect_equal(doc$getValue("test"), "Mary")
})

test_that("useful error message if app terminated", {
  skip_on_os("windows") # errors with "Empty reply from server"

  sleep_on_ci()
  app <- ShinyDriver$new(test_path("apps/stopApp"))
  app$findWidget("quit")$click()
  expect_error(app$getAllValues(), "no longer running")
})

test_that("can test app object", {
  ui <- fluidPage(textInput("x", "x", "value"))
  server <- function(input, output, session) {}

  sleep_on_ci()
  app <- ShinyDriver$new(shinyApp(ui, server))
  expect_equal(app$getValue("x"), "value")
})
