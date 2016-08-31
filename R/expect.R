
#' @export
#' @importFrom testthat expect

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

  expect(
    res,
    sprintf(
      paste0("Updating %s did not update %s, or it is taking longer",
             "than %i ms."),
      paste(names(inputs), collapse = ", "),
      paste(output, collapse = ", "),
      timeout
    )
  )

  ## "updating" is cleaned up automatically by on.exit()
}
