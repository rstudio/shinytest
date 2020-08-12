apps <- dir(test_path("recorded_tests"), full.names = TRUE)

for (app in apps) {
  test_that(paste0("Pre-rendered app '", basename(app), "' works"), {
    skip_on_os("windows")
    shinytest::expect_pass(shinytest::testApp(app, compareImages = FALSE))
  })
}
