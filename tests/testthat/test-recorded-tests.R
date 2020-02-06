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
      if (grepl("^rmd", basename(app_dir))) {
        if (!requireNamespace("rmarkdown", quietly = TRUE)) {
          # rmarkdown is not installed... skip app!
          next
        }
      }
      if (basename(app_dir) == "rmd") {
        # https://github.com/rstudio/rmarkdown/blob/7f51e232c98b2f7db40b40cd593385fe76b3189b/R/html_dependencies.R#L317-L328
        if (!rmarkdown::pandoc_available('2.9')) {
          next
        }
      }
      # If the dir contains an .Rmd, add that to the path
      path <- append_rmd(app_dir)
      test_that(basename(path), {
        shinytest::expect_pass(shinytest::testApp(path, compareImages = FALSE))
      })
    }
  }
}
