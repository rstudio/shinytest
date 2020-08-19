#' Expectation: `testApp()` passes snapshot tests
#'
#' This returns an testthat expectation object.
#'
#' @param object The results returned by [testApp()].
#' @param info Extra information to be included in the message (useful when
#'   writing tests in loops).
#'
#' @examples
#' \dontrun{
#' expect_pass(testApp("path/to/app/"))
#' }
#' @export
expect_pass <- function(object, info = NULL) {
  if (!inherits(object, "shinytest.results")) {
    abort("expect_pass() requires results from shinytest::testApp()")
  }

  pass_idx <- vapply(object$results, `[[`, "pass", FUN.VALUE = FALSE)
  fail_names <- vapply(object$results[!pass_idx], `[[`, "name", FUN.VALUE = "")

  all_pass <- all(pass_idx)
  if (!all_pass) {
    diff_txt <- textTestDiff(object$appDir, fail_names, object$images)
    message <- sprintf(
      "Not all shinytest scripts passed for %s: %s\n\nDiff output:\n%s\n%s",
      object$appDir,
      paste(fail_names, collapse = ", "),
      diff_txt,
      paste0("If this is expected, use `snapshotUpdate('", object$appDir, "')` to update")
    )
  } else {
    message <- ""
  }

  testthat::expect(all_pass, message, info = info)
  invisible(object)
}
