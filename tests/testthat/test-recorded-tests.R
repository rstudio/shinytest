apps <- dir(test_path("recorded_tests"), full.names = TRUE)

for (app in apps) {
  test_that(paste0("Pre-rendered app '", basename(app), "' works"), {
    skip_on_os("windows")
    expect_pass(testApp(app, compareImages = FALSE, interactive = FALSE))
  })
}
