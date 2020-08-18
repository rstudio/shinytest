test_that("specify url", {

  # Start shiny in one subprocess
  server <- ShinyDriver$new(test_path("apps/click-me"))
  server$waitForShiny()

  # Access from another (use a different path to prevent shinytest from trying to double-remove )
  client <- ShinyDriver$new(test_path("apps/outputs"),
                            url = server$getUrl()
                            )

  w <- client$findWidget("click")
  w$click()
  w$click()

  client$waitForShiny()
  expect_equal(client$getValue("i"), "2")

  client$stop()
  server$stop()
})
