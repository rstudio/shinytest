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
      list(shiny.http.response.filter = wrapper_filter),
      expr
    )

  } else {
    withr::with_options(
      list(shiny.http.response.filter = filter),
      expr
    )
  }
}