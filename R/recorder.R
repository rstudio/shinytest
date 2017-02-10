#' Launch test event recorder for a Shiny app
#'
#' @param app A \code{\link{ShinyDriver}} object, or path to a Shiny application.
#' @param save_dir A directory to save stuff.
#' @param load_test A boolean that determines whether or not the resulting test script will be used for load testing
#' @export
recordTest <- function(app = ".", save_dir = NULL, load_test = FALSE) {

  # Get the URL for the app. Depending on what type of object `app` is, it may
  # require starting an app.
  if (inherits(app, "ShinyDriver")) {
    url <- app$getUrl()
  } else if (is.character(app)) {
    if (grepl("^http(s?)://", app)) {
      stop("Recording tests for remote apps is not yet supported.")
    } else {
      # It's a path to an app; start the app
      app <- ShinyDriver$new(app)
      on.exit({
        rm(app)
        gc()
      })
      url <- app$getUrl()
    }
  } else if (inherits(app, "shiny.appobj")) {
    stop("Recording tests for shiny.appobj objects is not supported.")
  } else {
    stop("Unknown object type to record tests for.")
  }

  # Create directory if needed
  if (is.null(save_dir)) {
    save_dir <- file.path(app$getAppDir(), "tests")
    if (!dir_exists(save_dir)) {
      dir.create(save_dir)
    }
    save_dir <- normalizePath(save_dir)
  }

  # Use options to pass value to recorder app
  withr::with_options(
    list(
      shinytest.recorder.url = url,
      shinytest.app.dir = app$getAppDir(),
      shinytest.load.test = load_test
    ),
    res <- shiny::runApp(system.file("recorder", package = "shinytest"))
  )

  # Run the test script
  if (isTRUE(res$run)) {
    message("Saving baseline...")
    dest <- suppressMessages({
      testApp(rel_path(res$appDir), res$file)
      snapshotUpdate(tools::file_path_sans_ext(res$file), rel_path(res$appDir))
    })
    message("Saved baseline to ", dest)
  }

  invisible(res$file)
}


# Evaluates an expression (like `runApp()`) with the shiny.http.response.filter
# option set to a function which rewrites the <head> to include recorder.js.
with_shinyrecorder <- function(expr) {
  shiny::addResourcePath(
    "shinytest",
    system.file("js", package = "shinytest")
  )

  filter <- function(request, response) {
    if (response$status < 200 || response$status > 300) return(response)

    # Don't break responses that use httpuv's file-based bodies.
    if ('file' %in% names(response$content))
      return(response)

    if (!grepl("^text/html\\b", response$content_type, perl=T))
      return(response)

    # HTML files served from static handler are raw. Convert to char so we
    # can inject our head content.
    if (is.raw(response$content))
      response$content <- rawToChar(response$content)

    # Modify the <head> to load shinytest.js
    response$content <- sub(
      "</head>",
      "<script src=\"shared/jqueryui/jquery-ui.min.js\"></script>
      <script src=\"shinytest/recorder.js\"></script>\n</head>",
      response$content,
      ignore.case = TRUE
    )

    return(response)
  }

  if (!is.null(getOption("shiny.http.response.filter"))) {
    # If there's an existing filter, create a wrapper function that first runs
    # the old filter and then the new one on the request.
    old_filter <- getOption("shiny.http.response.filter")

    wrapper_filter <- function(request, response) {
      filter(old_filter(request, response))
    }

    withr::with_options(
      list(shiny.http.response.filter = wrapper_filter, shiny.testmode = TRUE),
      expr
    )

  } else {
    withr::with_options(
      list(shiny.http.response.filter = filter, shiny.testmode = TRUE),
      expr
    )
  }
}