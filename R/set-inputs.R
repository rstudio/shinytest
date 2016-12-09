app_setInputs <- function(self, private, ..., wait_ = TRUE, values_ = TRUE,
                           timeout_ = 3000) {
  if (values_ && !wait_) {
    stop("values_=TRUE and wait_=FALSE are not compatible.",
      "Can't return all values without waiting for update.")
  }

  private$queue_inputs(...)
  res <- private$flush_inputs(wait_, timeout_)

  if (isTRUE(res$timedOut)) {
    message("setInputs: Server did not update any output values within ",
      format(timeout_/1000, digits = 2),
      " seconds. If this is expected, use `wait_=FALSE, values_=FALSE`, or increase the value of timeout_.")
  }

  if (values_)
    invisible(self$getAllValues())
  else
    invisible()
}

app_queue_inputs <- function(self, private, ...) {
  inputs <- list(...)
  assert_that(is_all_named(inputs))

  private$web$execute_script(
    "shinytest.inputQueue.add(arguments[0]);",
    inputs
  )
}

app_flush_inputs <- function(self, private, wait, timeout) {
  private$web$execute_script_async(
    "var wait = arguments[0];
    var timeout = arguments[1];
    var callback = arguments[2];
    shinytest.outputValuesWaiter.start(timeout);
    shinytest.inputQueue.flush();
    shinytest.outputValuesWaiter.finish(wait, callback);",
    wait,
    timeout
  )
}

app_uploadFile <- function(self, private, ..., wait_ = TRUE, values_ = TRUE,
                           timeout_ = 3000) {
  if (values_ && !wait_) {
    stop("values_=TRUE and wait_=FALSE are not compatible.",
      "Can't return all values without waiting for update.")
  }

  inputs <- list(...)
  if (length(inputs) != 1 || !is_all_named(inputs)) {
    stop("Can only upload file to exactly one input, and input must be named")
  }

  private$web$execute_script(
    "var timeout = arguments[0];
    shinytest.outputValuesWaiter.start(timeout);",
    timeout_
  )

  self$findWidget(names(inputs)[1])$uploadFile(inputs[[1]])

  res <- private$web$execute_script_async(
    "var wait = arguments[0];
    var callback = arguments[1];
    shinytest.outputValuesWaiter.finish(wait, callback);",
    wait_
  )

  if (values_)
    self$getAllValues()
  else
    invisible()
}
