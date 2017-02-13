sd_setInputs <- function(self, private, ..., wait_ = TRUE, values_ = TRUE,
                         timeout_ = 3000, timing_ = FALSE) {
  if (values_ && !wait_) {
    stop("values_=TRUE and wait_=FALSE are not compatible.",
      "Can't return all values without waiting for update.")
  }
  if (timing_ && !wait_) {
    stop("timing_=TRUE and wait_=FALSE are not compatible.",
      "Can't return timing information without waiting for update.")
  }

  if (timing_) time_start <- Sys.time()

  private$queueInputs(...)
  res <- private$flushInputs(wait_, timeout_)

  if (timing_) time_end <- Sys.time()

  if (isTRUE(res$timedOut)) {
    message("setInputs: Server did not update any output values within ",
      format(timeout_/1000, digits = 2),
      " seconds. If this is expected, use `wait_=FALSE, values_=FALSE`, or increase the value of timeout_.")
  }


  values <- NULL
  if (values_) {
    values <- self$getAllValues()
  }

  if (timing_) {
    if (is.null(values))
      values <- list()

    inputs <- list(...)

    values$timing <- data.frame(stringsAsFactors = FALSE,
                                event    = "setInputs",
                                actions  = sapply(seq_along(inputs), function(i) paste0(names(inputs)[[i]], ": ", inputs[[i]])),
                                start    = time_start,
                                end      = time_end,
                                duration = as.numeric(time_end - time_start, units = "secs"),
                                timedout = res$timedOut
    )
  }

  invisible(values)
}

sd_queueInputs <- function(self, private, ...) {
  inputs <- list(...)
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

  private$web$executeScript(
    "var timeout = arguments[0];
    shinytest.outputValuesWaiter.start(timeout);",
    timeout_
  )

  self$findWidget(names(inputs)[1])$uploadFile(inputs[[1]])

  res <- private$web$executeScriptAsync(
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
