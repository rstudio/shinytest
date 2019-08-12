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

if (dir.exists("recorded_tests")) {
  app_dirs <- Filter(dir.exists, dir("recorded_tests", full.names = TRUE))
  if (length(app_dirs) > 0) {
    for (app_dir in app_dirs) {
      print(app_dir)
      # If the dir contains an .Rmd, add that to the path
      path <- append_rmd(app_dir)
      test_that(basename(path), {
        shinytest::expect_pass(shinytest::testApp(path, compareImages = FALSE, normalizeContent = T))
      })
    }
  }
}
