sd_setInputs <- function(self, private, ..., wait_ = TRUE, values_ = TRUE,
                         timeout_ = 3000, allowInputNoBinding_ = FALSE, priority_ = c("input", "event")) {
  if (values_ && !wait_) {
    stop("values_=TRUE and wait_=FALSE are not compatible.",
      "Can't return all values without waiting for update.")
  }

  priority_ <- match.arg(priority_)

  input_values <- lapply(list(...), function(value) {
    list(
      value = value,
      allowInputNoBinding = allowInputNoBinding_,
      priority = priority_
    )
  })

  self$logEvent("Setting inputs",
    input = paste(names(input_values), collapse = ",")
  )

  private$queueInputs(input_values)
  res <- private$flushInputs(wait_, timeout_)

  if (isTRUE(res$timedOut)) {
    # Get the text from one call back, like "app$setInputs(a=1, b=2)"
    calls <- sys.calls()
    call_text <- deparse(calls[[length(calls) - 1]])

    message(
      "setInputs(",
      call_text,
      "): Server did not update any output values within ",
      format(timeout_/1000, digits = 2),
      " seconds. If this is expected, use `wait_=FALSE, values_=FALSE`, or increase the value of timeout_.")
  }

  self$logEvent("Finished setting inputs", timedout = res$timedOut)

  values <- NULL
  if (values_) {
    values <- self$getAllValues()
  }


  invisible(values)
}



sd_queueInputs <- function(self, private, inputs) {
  assert_that(is_all_named(inputs))

  private$web$executeScript(
    "shinytest.inputQueue.add(arguments[0]);",
    inputs
  )
}

sd_flushInputs <- function(self, private, wait, timeout) {
  private$web$executeScriptAsync(
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

sd_uploadFile <- function(self, private, ..., wait_ = TRUE, values_ = TRUE,
                          timeout_ = 3000) {
  if (values_ && !wait_) {
    stop("values_=TRUE and wait_=FALSE are not compatible.",
      "Can't return all values without waiting for update.")
  }

  inputs <- list(...)
  if (length(inputs) != 1 || !is_all_named(inputs)) {
    stop("Can only upload file to exactly one input, and input must be named")
  }

  # Wait for two messages by calling `.start(timeout, 2)`. This is because
  # uploading a file will result in two messages before the file is successfully
  # uploaded.
  private$web$executeScript(
    "var timeout = arguments[0];
    shinytest.outputValuesWaiter.start(timeout, 2);",
    timeout_
  )

  self$logEvent("Uploading file", input = inputs[[1]])

  self$findWidget(names(inputs)[1])$uploadFile(inputs[[1]])

  res <- private$web$executeScriptAsync(
    "var wait = arguments[0];
    var callback = arguments[1];
    shinytest.outputValuesWaiter.finish(wait, callback);",
    wait_
  )

  # Need to wait for the progress bar's CSS transition to complete. The
  # transition is 0.6s, so this will ensure that it's done.
  Sys.sleep(0.6)

  self$logEvent("Finished uploading file")

  if (values_)
    invisible(self$getAllValues())
  else
    invisible()
}
