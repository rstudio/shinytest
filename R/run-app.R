
#' @importFrom shiny runApp as.shiny.appobj

run_app <- function(path) {
  suppressMessages(
    trace(shiny:::uiHttpHandler, shinytest:::ui_tracer, print = FALSE)
  )
  runApp(path)
}

#' @importFrom htmltools htmlDependency attachDependencies
#' @importFrom utils packageName

ui_tracer <- function() {

  ## Find the caller we need to patch, in the stack
  uicallframe <- find_parent(quote(uiHttpHandler))

  ## No uiHttpHandler? Not really possibly currently, but just in case
  if (is.na(uicallframe)) {
    warning("Cannot monkey-patch Shiny UI to include the shinytest tracer")
    return()
  }

  get_obj <- function(x) get(x, envir = sys.frame(uicallframe))
  set_obj <- function(x, v) assign(x, v, envir = sys.frame(uicallframe))

  ui <- get_obj("ui")

  dep <- htmlDependency(
    name = "shinytest",
    version = package_version(),
    src = system.file(package = packageName(), "js"),
    script = "shiny-tracer.js",
    all_files = FALSE
  )

  ui <- attachDependencies(ui, dep, append = TRUE)
  set_obj("ui", ui)

  invisible()
}

find_parent <- function(name) {
  calls <- sys.calls()
  for (i in seq_along(calls)) {
    if (identical(calls[[i]][[1]], name)) return(i)
  }
  NA_integer_
}
