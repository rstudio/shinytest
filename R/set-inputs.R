app_set_inputs <- function(self, private, ...) {
  app_queue_inputs(self, private, ...)
  app_flush_inputs(self, private)
}

app_queue_inputs <- function(self, private, ...) {
  inputs <- list(...)
  assert_that(is_all_named(inputs))

  private$web$execute_script(
    "shinytest.inputQueue.add(arguments[0]);",
    inputs
  )
}

app_flush_inputs <- function(self, private) {
  private$web$execute_script("shinytest.inputQueue.flush();")
}
