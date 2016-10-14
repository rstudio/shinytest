app_get_all_values <- function(self, private) {
  "!DEBUG app_get_all_values"
  res <- private$web$execute_script(
    "return shinytest.getAllValues();"
  )

  if (!is.null(res$inputs)) {
    # Use Shiny's applyInputHandlers function. Note that the R process running
    # Shiny is not the same as this one, and there are two possible drawbacks to
    # doing this.
    #
    # (1) It's possible for a package to register an input handler in the Shiny
    # R process that isn't available in this process
    #
    # (2) It's hypothetically possible for the version of Shiny that's being
    # tested to differ from the version of Shiny that's available in this
    # process, and the input handlers could be different between the versions.
    # This is very unlikely to happen in actual testing scenarios, though.
    res$inputs <- shiny::applyInputHandlers(res$inputs)
  }

  res
}
