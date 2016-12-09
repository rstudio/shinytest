
#' \code{testthat} expectation for a Shiny update
#'
#' @param app A \code{\link{ShinyDriver}} object.
#' @param output Character vector, the name(s) of the output widgets
#'   that are required to update for the test to succeed.
#' @param ... Named arguments specifying updates for Shiny input
#'   widgets.
#' @param timeout Timeout for the update to happen, in milliseconds.
#' @param iotype Type of the widget(s) to change. These are normally
#'   input widgets.
#'
#' @export
#' @importFrom testthat expect
#' @importFrom utils compareVersion
#' @examples
#' \dontrun{
#' ## https://github.com/rstudio/shiny-examples/tree/master/050-kmeans-example
#' app <- ShinyDriver$new("050-kmeans-example")
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
  "!DEBUG app_expect_update `paste(output, collapse = ', ')`"

  assert_that(is.character(output))
  assert_that(is_all_named(inputs <- list(...)))
  assert_that(is_count(timeout))
  assert_that(is_string(iotype))

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
    self$findWidget(n, iotype = iotype)$setValue(inputs[[n]])
  }

  "!DEBUG waiting for update"
  ## Wait for all the updates to happen, or a timeout
  res <- private$web$wait_for(
    "window.shinytest.updating.length == 0",
    timeout = timeout
  )
  "!DEBUG update done (`if (res) 'done' else 'timeout'`)"

  expect(
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

  ## "updating" is cleaned up automatically by on.exit()
}
