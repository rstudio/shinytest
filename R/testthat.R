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
  pass_idx <- vapply(object$results, `[[`, "pass", FUN.VALUE = FALSE)
  fail_names <- vapply(object$results[!pass_idx], `[[`, "name", FUN.VALUE = "")

  testthat::expect(
    identical(all(pass_idx), TRUE),
    sprintf(
      "Not all shinytest scripts passed for %s: %s",
      object$appDir,
      paste(fail_names, collapse = ", ")
    ),
    info = info
  )
  invisible(object)
}
