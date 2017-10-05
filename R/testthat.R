#' Expectation: shinytest object passed snapshot tests
#'
#' This returns an testthat expectation object.
#'
#' @param object The results returned by \code{\link{testApp}}.
#' @param info Extra information to be included in the message  (useful when writing tests in loops).
#'
#' @examples
#' \dontrun{
#' expect_pass(testApp("path/to/app/"))
#' }
#'
#' @export
expect_pass <- function(object, info = NULL) {
  if (!inherits(object, "shinytest.results")) {
    testthat::expect(
      FALSE,
      "expect_pass requires results from shinytest::testApp()."
    )
  }

  pass_idx <- vapply(object$results, `[[`, "pass", FUN.VALUE = FALSE)
  fail_names <- vapply(object$results[!pass_idx], `[[`, "name", FUN.VALUE = "")

  all_pass <- all(pass_idx)
  diff_txt <- ""

  if (!all_pass) {
    diff_txt <- lapply(object$results[!pass_idx], function(result) {
      current_dir  <- file.path(result$appDir, "tests", paste0(result$name, "-current"))
      expected_dir <- file.path(result$appDir, "tests", paste0(result$name, "-expected"))


      if (result$images) {
        filter_fun <- NULL
      } else {
        # If we're not using images, then delete PNG files and remove the
        # hashes from JSON.
        filter_fun <- remove_image_hashes_and_files
      }

      paste0(
        "==== ", result$name, " ====\n",
        diff_files(expected_dir, current_dir, filter_fun)
      )
    })

    diff_txt <- paste(diff_txt, collapse = "\n")
  }

  testthat::expect(
    all_pass,
    sprintf(
      "Not all shinytest scripts passed for %s: %s\n\nDiff output:\n%s",
      object$appDir,
      paste(fail_names, collapse = ", "),
      diff_txt
    ),
    info = info
  )
  invisible(object)
}
