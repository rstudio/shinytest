
#' \code{testthat} expectation for a Shiny update
#'
#' @param app A \code{\link{shinyapp}} object.
#' @param output Character vector, the name(s) of the output widgets
#'   that are required to update for the test to succeed.
#' @param ... Named arguments specifying updates for Shiny input
#'   widgets.
#' @param timeout Timeout for the update to happen, in milliseconds.
#' @param iotype Type of the widget(s) to change. These are normally
#'   input widgets.
#'
#' @export
#' @importFrom testthat expectation expect_that
#' @importFrom utils compareVersion
#' @examples
#' \dontrun{
#' ## https://github.com/rstudio/shiny-examples/tree/master/050-kmeans-example
#' app <- shinyapp$new("050-kmeans-example")
#' expect_update(app, xcol = "Sepal.Width", output = "plot1")
#' expect_update(app, ycol = "Petal.Width", output = "plot1")
#' expect_update(app, clusters = 4, output = "plot1")
#' }

expect_update <- function(app, output, ..., timeout = 3000,
                          iotype = c("auto", "input", "output")) {
  app$expect_update(
    output,
    ...,
    timeout = timeout,
    iotype = match.arg(iotype)
  )
}

app_expect_update <- function(self, private, output, ..., timeout,
                              iotype) {

  assert_character(output)
  assert_all_named(inputs <- list(...))
  assert_count(timeout)
  assert_string(iotype)

  ## Make note of the expected updates. They will be ticked off
  ## one by one by the JS event handler in shiny-tracer.js
  js <- paste0(
    "window.shinytest.updating.push('", output, "');",
    collapse = "\n"
  )
  private$web$execute_script(js)
  on.exit(
    private$web$execute_script("window.shinytest.updating = [];"),
    add = TRUE
  )

  ## Do the changes to the inputs
  for (n in names(inputs)) {
    self$find_widget(n, iotype = iotype)$set_value(inputs[[n]])
  }

  ## Wait for all the updates to happen, or a timeout
  res <- private$web$wait_for(
    "window.shinytest.updating.length == 0",
    timeout = timeout
  )

  expect_old <- function() {

    condition <- function(result) {

      failure_msg <- strwrap(sprintf(
        paste0(
          "Updating %s did not update %s, or it is taking longer ",
          "than %i ms."),
        paste(sQuote(names(inputs)), collapse = ", "),
        paste(sQuote(output), collapse = ", "),
        timeout
      ))

      success_msg <- strwrap(sprintf(
        "Changing %s updated %s before the %i ms timeout",
        paste(sQuote(names(inputs)), collapse = ", "),
        paste(sQuote(output), collapse = ", "),
        timeout
      ))

      expectation(
        passed = result,
        failure_msg = failure_msg,
        success_msg = success_msg
      )
    }

    expect_that(res, condition)
  }

  expect_new <- function() {
    testthat::expect(
      res,
      sprintf(
        strwrap(paste0(
          "Updating %s did not update %s, or it is taking longer ",
          "than %i ms.")),
        paste(sQuote(names(inputs)), collapse = ", "),
        paste(sQuote(output), collapse = ", "),
        timeout
      )
    )
  }

  if (compareVersion(package_version("testthat"), "1.0.0") >= 0) {
    expect_new()
  } else {
    expect_old()
  }

  ## "updating" is cleaned up automatically by on.exit()
}
