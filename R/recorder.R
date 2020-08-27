#' Launch test event recorder for a Shiny app
#'
#' @param app A [ShinyDriver()] object, or path to a Shiny
#'   application.
#' @param save_dir A directory to save stuff.
#' @param load_mode A boolean that determines whether or not the resulting test
#'   script should be appropriate for load testing.
#' @param seed A random seed to set before running the app. This seed will also
#'   be used in the test script.
#' @param loadTimeout Maximum time to wait for the Shiny application to load, in
#'   milliseconds. If a value is provided, it will be saved in the test script.
#' @param debug start the underlying [ShinyDriver()] in `debug`
#'   mode and print those debug logs to the R console once recording is
#'   finished. The default, `'shiny_console'`, captures and prints R
#'   console output from the recorded R shiny process. Any value that the
#'   `debug` argument in [ShinyDriver()] accepts may be used
#'   (e.g., `'none'` may be used to completely suppress the driver logs).
#' @param shinyOptions A list of options to pass to `runApp()`. If a value
#'   is provided, it will be saved in the test script.
#' @export
recordTest <- function(app = ".", save_dir = NULL, load_mode = FALSE, seed = NULL,
  loadTimeout = 10000, debug = "shiny_console", shinyOptions = list()) {

  # Get the URL for the app. Depending on what type of object `app` is, it may
  # require starting an app.
  if (inherits(app, "ShinyDriver")) {
    url <- app$getUrl()
  } else if (is.character(app)) {
    if (grepl("^http(s?)://", app)) {
      abort("Recording tests for remote apps is not yet supported.")
    } else {
      path <- app_path(app, "app")$app

      # Rmds need a random seed
      if (is_rmd(path) && is.null(seed)) {
        seed <- floor(stats::runif(1, min = 0, max = 1e5))
      }

      app <- ShinyDriver$new(path, seed = seed, loadTimeout = loadTimeout, shinyOptions = shinyOptions)
      on.exit({
        rm(app)
        gc()
      })
      url <- app$getUrl()
    }
  } else if (inherits(app, "shiny.appobj")) {
    abort("Recording tests for shiny.appobj objects is not supported.")
  } else {
    abort("Unknown object type to record tests for.")
  }

  # Create directory if needed
  if (is.null(save_dir)) {
    save_dir <- findTestsDir(app$getAppDir(), mustExist=FALSE, quiet=FALSE)
    if (!dir_exists(save_dir)) {
      dir.create(save_dir, recursive=TRUE)

      # findTestsDir would return the nested shinytest/ directory if the dir didn't exist,
      # so since we're creating the nested structure, we should leave behind the top-
      # level runner, too.
      runner <- paste0("library(shinytest)\nshinytest::testApp(\"../\")\n")
      writeLines(runner, file.path(save_dir, "..", "shinytest.R"))
    }
    save_dir <- normalizePath(save_dir)
  }

  # Are we running in RStudio? If so, we might need to fix up the URL so that
  # it's externally accessible.
  if (rstudioapi::isAvailable()) {
    if (rstudioapi::hasFun("translateLocalUrl")) {
      # If the RStudio API knows how to translate URLs, call it.
      url <- rstudioapi::translateLocalUrl(url, absolute = TRUE)
    } else if (identical(rstudioapi::versionInfo()$mode, "server")) {
      # Older versions of the RStudio API don't know how to translate URLs, so
      # we'll need to do it ourselves if we're in server mode. For example,
      # http://localhost:1234/ is translated to ../../p/1234/.
      url <- paste0("../../p/", gsub(".*:([0-9]+)\\/?", "\\1", url), "/")
    }
  }

  # Use options to pass value to recorder app
  withr::with_options(
    list(
      shinytest.recorder.url  = url,
      shinytest.app           = app,
      shinytest.debug         = debug,
      shinytest.load.mode     = load_mode,
      shinytest.load.timeout  = if (!missing(loadTimeout)) loadTimeout,
      shinytest.seed          = seed,
      shinytest.shiny.options = shinyOptions
    ),
    res <- shiny::runApp(system.file("recorder", package = "shinytest"))
  )

  if (is.null(res$appDir)) {
    # Quit without saving

  } else if (isTRUE(res$run)) {

    # Before running the test, sometimes we need to make sure the previous run
    # of the app is shut down. For example, if a port is specified in
    # shinyOptions, it needs to be freed up before starting the app again.
    gc()

    # Run the test script
    testApp(rel_path(res$appDir), res$file)

  } else {
    if (length(res$dont_run_reasons) > 0) {
      inform(c("Not running test script because", res$dont_run_reasons))
    }

    inform(sprintf(
      'After making changes to the test script, run it with:\n  testApp("%s", "%s")',
      rel_path(res$appDir), res$file
    ))
  }

  invisible(res$file)
}


#' Register an input processor for the test recorder
#'
#' @description
#' `registerInputProcessor()` registers an input processor which will be used by
#' the test recorder. The input processor function should take one parameter,
#' `value`, and return a string of R code which returns the desired value.
#'
#' `getInputProcessors()` returns a named list of all registered input processor
#' functions.
#'
#' @param inputType The name of an input type, for example,
#'   `"mypkg.numberinput"`.
#' @param processor An input processor function.
#' @export
#' @keywords internal
registerInputProcessor <- function(inputType, processor) {
  if (!is.function(processor) || !identical(names(formals(processor)), "value")) {
    abort("`processor` must be a function that takes one parameter, `value`")
  }
  recorder_input_processors[[inputType]] <- processor
}

#' @rdname registerInputProcessor
#' @export
getInputProcessors <- function() {
  as.list(recorder_input_processors)
}

# This environment holds input processors registered by other packages on load.
recorder_input_processors <- new.env(parent = emptyenv())
