context("recorded-tests")

# If a directory has an .Rmd file, return the path with the .Rmd file appended;
# otherwise return the path unchanged. If there is more than one .Rmd, throw an
# error.
append_rmd <- function(path) {
  files <- dir(path, pattern = ".*\\.Rmd$", full.names = TRUE, ignore.case = TRUE)
  if (length(files) == 0) {
    path
  } else if (length(files) == 1) {
    files
  } else {
    stop("There must be 0 or 1 .Rmd files in dir '", path, "' but there are ",
      length(files)
    )
  }
}

test_that("prerecorded tests return expected results", {
  skip_on_os("windows")

  app_dirs <- Filter(dir.exists, dir(test_path("recorded_tests"), full.names = TRUE))
  if (length(app_dirs) == 0) {
    skip("No pre-recorded tests found")
  }
  for (app_dir in app_dirs) {
    path <- append_rmd(app_dir)
    shinytest::expect_pass(shinytest::testApp(path, compareImages = FALSE))
  }
})
