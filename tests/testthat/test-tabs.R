
context("tabs")

test_that("tabs are found, names are good", {
  app <- shinyapp$new("apps/embedded-tabs")

  expect_equal(app$find_widget("tabset1")$list_tabs(), c("tab1", "tab2"))
  expect_equal(
    app$find_widget("tabset11")$list_tabs(),
    c("tab11", "tab12", "tab13")
  )
  expect_equal(
    app$find_widget("tabset12")$list_tabs(),
    c("xxx", "tab22", "tab23", "tab24")
  )
})

test_that("getting and setting active tab", {
  app <- shinyapp$new("apps/embedded-tabs")

  expect_equal(app$find_widget("tabset1")$get_value(), "tab1")
  expect_equal(app$find_widget("tabset11")$get_value(), "tab11")
  ## Invisible tabset still has an active tab
  expect_equal(app$find_widget("tabset12")$get_value(), "xxx")

  t1 <- app$find_widget("tabset1")
  t2 <- app$find_widget("tabset11")
  t3 <- app$find_widget("tabset12")

  t1$set_value("tab1")
  expect_equal(t1$get_value(), "tab1")
  expect_equal(t2$get_value(), "tab11")
  expect_equal(t3$get_value(), "xxx")

  t1$set_value("tab2")
  expect_equal(t1$get_value(), "tab2")
  expect_equal(t2$get_value(), "tab11")
  expect_equal(t3$get_value(), "xxx")

  t3$set_value("tab22")
  expect_equal(t1$get_value(), "tab2")
  expect_equal(t2$get_value(), "tab11")
  expect_equal(t3$get_value(), "tab22")

  t3$set_value("xxx")
  expect_equal(t1$get_value(), "tab2")
  expect_equal(t2$get_value(), "tab11")
  expect_equal(t3$get_value(), "xxx")

  t1$set_value("tab1")
  expect_equal(t1$get_value(), "tab1")
  expect_equal(t2$get_value(), "tab11")
  expect_equal(t3$get_value(), "xxx")
})

test_that("tabs in expect_update", {
  app <- shinyapp$new("apps/006-tabsets-id")

  expect_update(app, dist = "unif", output = "plot")
  expect_update(app, tabs = "Summary", output = "summary")
})