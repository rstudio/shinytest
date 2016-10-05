
context("tabs")

test_that("tabs are found, names are good", {
  app <- shinyapp$new("apps/embedded-tabs")

  tab22 <- app$get_tabset("tab22")
  expect_true(inherits(tab22, "tabset"))

  tabsets <- app$get_tabsets()
  expect_equal(length(tabsets), 3)
  expect_true(inherits(tabsets[[1]], "tabset"))
  expect_true(inherits(tabsets[[2]], "tabset"))
  expect_true(inherits(tabsets[[2]], "tabset"))

  expect_equal(
    tab22$list_tabs(),
    c("xxx", "tab22", "tab23", "tab24")
  )

  expect_equal(tabsets[[1]]$list_tabs(), c("tab1", "tab2"))
  expect_equal(tabsets[[2]]$list_tabs(), c("tab11", "tab12", "tab13"))
  expect_equal(
    tabsets[[3]]$list_tabs(),
    c("xxx", "tab22", "tab23", "tab24")
  )
})

test_that("getting and setting active tab", {
  app <- shinyapp$new("apps/embedded-tabs")

  tabsets <- app$get_tabsets()
  expect_equal(tabsets[[1]]$get_value(), "tab1")
  expect_equal(tabsets[[2]]$get_value(), "tab11")
  ## Invisible tabset still has an active tab
  expect_equal(tabsets[[3]]$get_value(), "xxx")

  tabsets[[1]]$set_value("tab1")
  expect_equal(tabsets[[1]]$get_value(), "tab1")
  expect_equal(tabsets[[2]]$get_value(), "tab11")
  expect_equal(tabsets[[3]]$get_value(), "xxx")

  tabsets[[1]]$set_value("tab2")
  expect_equal(tabsets[[1]]$get_value(), "tab2")
  expect_equal(tabsets[[2]]$get_value(), "tab11")
  expect_equal(tabsets[[3]]$get_value(), "xxx")

  tabsets[[3]]$set_value("tab22")
  expect_equal(tabsets[[1]]$get_value(), "tab2")
  expect_equal(tabsets[[2]]$get_value(), "tab11")
  expect_equal(tabsets[[3]]$get_value(), "tab22")

  tabsets[[3]]$set_value("xxx")
  expect_equal(tabsets[[1]]$get_value(), "tab2")
  expect_equal(tabsets[[2]]$get_value(), "tab11")
  expect_equal(tabsets[[3]]$get_value(), "xxx")

  tabsets[[1]]$set_value("tab1")
  expect_equal(tabsets[[1]]$get_value(), "tab1")
  expect_equal(tabsets[[2]]$get_value(), "tab11")
  expect_equal(tabsets[[3]]$get_value(), "xxx")
})
