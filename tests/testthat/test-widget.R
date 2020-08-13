test_that("can click buttons", {
  app <- ShinyDriver$new(test_path("apps/click-me"))

  w <- app$findWidget("click")
  w$click()
  w$click()
  expect_equal(app$getValue("i"), "2")
})
