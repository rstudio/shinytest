app_set_inputs <- function(self, private, ..., wait_ = TRUE, values_ = TRUE,
                           timeout_ = 3000) {
  if (values_ && !wait_) {
    stop("values_=TRUE and wait_=FALSE are not compatible.",
      "Can't return all values without waiting for update.")
  }

  private$queue_inputs(...)
  vals <- private$flush_inputs(wait_, values_, timeout_)
  return(vals)
}

app_queue_inputs <- function(self, private, ...) {
  inputs <- list(...)
  assert_that(is_all_named(inputs))

  private$web$execute_script(
    "shinytest.inputQueue.add(arguments[0]);",
    inputs
  )
}

app_flush_inputs <- function(self, private, wait, returnValues, timeout) {
  res <- private$web$execute_script_async(
    "var wait = arguments[0];
    var returnValues = arguments[1];
    var timeout = arguments[2];
    var callback = arguments[3];
    shinytest.inputQueue.flushAndReturnValuesAsync(wait, returnValues, timeout, callback);",
    wait,
    returnValues,
    timeout
  )

  # Treatmeent of res$inputs here is the same as in app_get_all_values. We don't
  # call that function to get the values because it involves a separate
  # execute_script_async call, which may introduce timing problems.
  if (!is.null(res$inputs)) {
    res$inputs <- shiny::applyInputHandlers(res$inputs)
  }

  res
}
