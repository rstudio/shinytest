test_that("can click buttons", {
  app <- ShinyDriver$new(test_path("apps/click-me"))

  w <- app$findWidget("click")
  w$click()
  w$click()

  app$waitForShiny()
  expect_equal(app$getValue("i"), "2")
})
