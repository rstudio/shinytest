
context("tabs")

test_that("tabs are found, names are good", {
  app <- ShinyDriver$new(test_path("apps/embedded-tabs"))

  expect_equal(app$findWidget("tabset1")$listTabs(), c("tab1", "tab2"))
  expect_equal(
    app$findWidget("tabset11")$listTabs(),
    c("tab11", "tab12", "tab13")
  )
  expect_equal(
    app$findWidget("tabset12")$listTabs(),
    c("xxx", "tab22", "tab23", "tab24")
  )
})

test_that("getting and setting active tab", {
  app <- ShinyDriver$new(test_path("apps/embedded-tabs"))

  expect_equal(app$findWidget("tabset1")$getValue(), "tab1")
  expect_equal(app$findWidget("tabset11")$getValue(), "tab11")
  ## Invisible tabset still has an active tab
  expect_equal(app$findWidget("tabset12")$getValue(), "xxx")

  t1 <- app$findWidget("tabset1")
  t2 <- app$findWidget("tabset11")
  t3 <- app$findWidget("tabset12")

  t1$setValue("tab1")
  expect_equal(t1$getValue(), "tab1")
  expect_equal(t2$getValue(), "tab11")
  expect_equal(t3$getValue(), "xxx")

  t1$setValue("tab2")
  expect_equal(t1$getValue(), "tab2")
  expect_equal(t2$getValue(), "tab11")
  expect_equal(t3$getValue(), "xxx")

  t3$setValue("tab22")
  expect_equal(t1$getValue(), "tab2")
  expect_equal(t2$getValue(), "tab11")
  expect_equal(t3$getValue(), "tab22")

  t3$setValue("xxx")
  expect_equal(t1$getValue(), "tab2")
  expect_equal(t2$getValue(), "tab11")
  expect_equal(t3$getValue(), "xxx")

  t1$setValue("tab1")
  expect_equal(t1$getValue(), "tab1")
  expect_equal(t2$getValue(), "tab11")
  expect_equal(t3$getValue(), "xxx")
})

test_that("tabs in expectUpdate", {
  app <- ShinyDriver$new(test_path("apps/006-tabsets-id"))

  expectUpdate(app, dist = "unif", output = "plot")
  expectUpdate(app, tabs = "Summary", output = "summary")
})
