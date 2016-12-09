
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
#' expectUpdate(app, xcol = "Sepal.Width", output = "plot1")
#' expectUpdate(app, ycol = "Petal.Width", output = "plot1")
#' expectUpdate(app, clusters = 4, output = "plot1")
#' }

expectUpdate <- function(app, output, ..., timeout = 3000,
                         iotype = c("auto", "input", "output")) {
  app$expectUpdate(
    output,
    ...,
    timeout = timeout,
    iotype = match.arg(iotype)
  )
}

sd_expectUpdate <- function(self, private, output, ..., timeout,
                            iotype) {
  "!DEBUG sd_expectUpdate `paste(output, collapse = ', ')`"

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
  private$web$executeScript(js)
  on.exit(
    private$web$executeScript("window.shinytest.updating = [];"),
    add = TRUE
  )

  ## Do the changes to the inputs
  for (n in names(inputs)) {
    self$findWidget(n, iotype = iotype)$setValue(inputs[[n]])
  }

  "!DEBUG waiting for update"
  ## Wait for all the updates to happen, or a timeout
  res <- private$web$waitFor(
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
