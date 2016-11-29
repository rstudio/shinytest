
#' Class to manage a shiny app and a phantom.js headless browser
#'
#' @section Usage:
#' \preformatted{app <- shinyapp$new(path = ".", load_timeout = 5000,
#'               check_names = TRUE, debug = c("none", "all",
#'               shinyapp$debug_log_types))
#' app$stop()
#' app$get_debug_log(type = c("all", shinyapp$debug_log_types))
#'
#' app$get_value(name, iotype = c("auto", "input", "output"))
#' app$set_value(name, value, iotype = c("auto", "input", "output"))
#' app$send_keys(name = NULL, keys)
#'
#' app$get_windows_size()
#' app$set_window_size(width, height)
#'
#' app$get_url()
#' app$go_back()
#' app$refresh()
#' app$get_title()
#' app$get_source()
#' app$take_screenshot(file = NULL)
#'
#' app$find_element(css = NULL, link_text = NULL,
#'      partial_link_text = NULL, xpath = NULL)
#'
#' app$find_elements(css = NULL, link_text = NULL,
#'      partial_link_text = NULL, xpath = NULL)
#'
#' app$wait_for(expr, check_interval = 100, timeout = 3000)
#'
#' app$list_widgets()
#'
#' app$check_unique_widget_names()
#'
#' app$find_widget(name, iotype = c("auto", "input", "output"))
#'
#' app$expect_update(output, ..., timeout = 3000,
#'     iotype = c("auto", "input", "output"))
#' }
#'
#' @section Arguments:
#' \describe{
#'   \item{app}{A \code{shinyapp} instance.}
#'   \item{path}{Path to a directory containing a Shiny app, i.e. a
#'      single \code{app.R} file or a \code{server.R} and \code{ui.R}
#'      pair.}
#'   \item{load_timeout}{How long to wait for the app to load, in ms.
#'      This includes the time to start R.}
#'   \item{check_names}{Whether to check if widget names are unique in the
#'      app.}
#'   \item{debug}{Whether to start the app in debugging mode. In debugging
#'      mode debug messages are printed to the console.}
#'   \item{name}{Name of a shiny widget. For \code{$send_keys} it can
#'      be \code{NULL}, in which case the keys are sent to the active
#'      HTML element.}
#'   \item{iotype}{Type of the Shiny widget. Usually \code{shinytest}
#'      finds the widgets by their name, so this need not be specified,
#'      but Shiny allows input and output widgets with identical names.}
#'   \item{keys}{Keys to send to the widget or the app. See the
#'      \code{send_keys} method of the \code{webdriver} package.}
#'   \item{width}{Scalar integer, the desired width of the browser window.}
#'   \item{height}{Scalar integer, the desired height of the browser
#'      window.}
#'   \item{file}{File name to save the screenshot to. If \code{NULL}, then
#'     it will be shown on the R graphics device.}
#'   \item{css}{CSS selector to find an HTML element.}
#'   \item{link_text}{Find \code{<a>} HTML elements based on their
#'     \code{innerText}.}
#'   \item{partial_link_text}{Find \code{<a>} HTML elements based on their
#'     \code{innerText}. It uses partial matching.}
#'   \item{xpath}{Find HTML elements using XPath expressions.}
#'   \item{expr}{A string scalar containing JavaScript code that
#'     evaluates to the condition to wait for.}
#'   \item{check_interval}{How often to check for the condition, in
#'     milliseconds.}
#'   \item{timeout}{Timeout for the condition, in milliseconds.}
#'   \item{output}{Character vector, the name(s) of the Shiny output
#'     widgets that should be updated.}
#'   \item{...}{For \code{expect_update} these can be named arguments.
#'     The argument names correspond to Shiny input widgets: each input
#'     widget will be set to the specified value.}
#' }
#'
#' @section Details:
#'
#' \code{shinyapp$new()} function creates a \code{shinyapp} object. It starts
#' the Shiny app in a new R session, and it also starts a \code{phantomjs}
#' headless browser that connects to the app. It waits until the app is
#' ready to use. It waits at most \code{load_timeout} milliseconds, and if
#' the app is not ready, then it throws an error. You can increase
#' \code{load_timeout} for slow loading apps. Currently it supports apps
#' that are defined in a single \code{app.R} file, or in a \code{server.R}
#' and \code{ui.R} pair.
#'
#' \code{app$stop()} stops the app, i.e. the external R process that runs
#' the app, and also the phantomjs instance.
#'
#' \code{app$get_debug_log()} queries one or more of the debug logs:
#' \code{shiny_console}, \code{browser} or \code{shinytest}.
#'
#' \code{app$get_value()} finds a widget and queries its value. See
#' the \code{get_value} method of the \code{\link{widget}} class.
#'
#' \code{app$set_inputs()} sets the value of inputs. The arguments must all
#' be named; an input with each name will be assigned the given value.
#'
#' \code{app$upload_file()} uploads a file to a file input. The argument must
#' be named and the value must be the path to a local file; that file will be
#' uploaded to a file input with that name.
#'
#' \code{app$get_all_values()} returns a named list of all inputs, outputs,
#' and error values.
#'
#' \code{app$set_value()} finds a widget and sets its value. See the
#' \code{set_value} method of the \code{\link{widget}} class.
#'
#' \code{app$send_keys} sends the specified keys to the HTML element of the
#' widget.
#'
#' \code{app$get_window_size()} returns the current size of the browser
#' window, in a list of two integer scalars named \sQuote{width} and
#' \sQuote{height}.
#'
#' \code{app$set_window_size()} sets the size of the browser window to the
#' specified width and height.
#'
#' \code{app$get_url()} returns the current URL.
#'
#' \code{app$go_back()} \dQuote{presses} the browser's \sQuote{back}
#' button.
#'
#' \code{app$refresh()} \dQuote{presses} the browser's \sQuote{refresh}
#' button.
#'
#' \code{app$get_title()} returns the title of the page. (More precisely
#' the document title.)
#'
#' \code{app$get_source()} returns the complete HTML source of the current
#' page, in a character scalar.
#'
#' \code{app$take_screenshot()} takes a screenshot of the current page
#' and writes it to a file, or (if \code{file} is \code{NULL}) shows it
#' on the R graphics device. The output file has PNG format.
#'
#' \code{app$find_element()} find an HTML element on the page, using a
#' CSS selector or an XPath expression. The return value is an
#' \code{\link[webdriver]{element}} object from the \code{webdriver}
#' package.
#'
#' \code{app$find_elements()} finds potentially multiple HTML elements,
#' and returns them in a list of \code{\link[webdriver]{element}} objects
#' from the \code{webdriver} package.
#'
#' \code{app$wait_for()} waits until a JavaScript expression evaluates
#' to \code{true}, or a timeout happens. It returns \code{TRUE} is the
#' expression evaluated to \code{true}, possible after some waiting.
#'
#' \code{app$list_widgets()} lists the names of all input and output
#' widgets. It returns a list of two character vectors, named \code{input}
#' and \code{output}.
#'
#' \code{app$check_unique_widget_names()} checks if Shiny widget names
#' are unique.
#'
#' \code{app$find_widget()} finds the corresponding HTML element of a Shiny
#' widget. It returns a \code{\link{widget}} object.
#'
#' \code{expect_update()} is one of the main functions to test Shiny apps.
#' It performs one or more update operations via the browser, and then
#' waits for the specified output widgets to update. The test succeeds if
#' all specified output widgets are updated before the timeout. For
#' updates that involve a lot of computation, you increase the timeout.
#'
#' @name shinyapp
#' @examples
#' \dontrun{
#' ## https://github.com/rstudio/shiny-examples/tree/master/050-kmeans-example
#' app <- shinyapp$new("050-kmeans-example")
#' expect_update(app, xcol = "Sepal.Width", output = "plot1")
#' expect_update(app, ycol = "Petal.Width", output = "plot1")
#' expect_update(app, clusters = 4, output = "plot1")
#' }
NULL

#' @importFrom R6 R6Class
#' @export

shinyapp <- R6Class(
  "shinyapp",

  public = list(

    initialize = function(path = ".", load_timeout = 5000,
      check_names = TRUE,
      debug = c("none", "all", shinyapp$debug_log_types))
      app_initialize(self, private, path, load_timeout, check_names,
                     match.arg(debug, several.ok = TRUE)),

    stop = function()
      app_stop(self, private),

    get_value = function(name, iotype = c("auto", "input", "output"))
      app_get_value(self, private, name, match.arg(iotype)),

    set_value = function(name, value, iotype = c("auto", "input", "output"))
      app_set_value(self, private, name, value, match.arg(iotype)),

    get_all_values = function(input = TRUE, output = TRUE, export = TRUE)
      app_get_all_values(self, private, input, output, export),

    send_keys = function(name = NULL, keys)
      app_send_keys(self, private, name, keys),

    set_window_size = function(width, height)
      app_set_window_size(self, private, width, height),

    get_window_size = function()
      app_get_window_size(self, private),

    ## Debugging

    get_debug_log = function(type = c("all", shinyapp$debug_log_types))
      app_get_debug_log(self, private, match.arg(type, several.ok = TRUE)),

    enable_debug_log_messages = function(enable = TRUE)
      app_enable_debug_log_messages(self, private, enable),

    ## These are just forwarded to the webdriver session

    get_url = function()
      app_get_url(self, private),

    go_back = function()
      app_go_back(self, private),

    refresh = function()
      app_refresh(self, private),

    get_title = function()
      app_get_title(self, private),

    get_source = function()
      app_get_source(self, private),

    take_screenshot = function(file = NULL)
      app_take_screenshot(self, private, file),

    find_element = function(css = NULL, link_text = NULL,
      partial_link_text = NULL, xpath = NULL)
      app_find_element(self, private, css, link_text, partial_link_text,
                       xpath),

    find_elements = function(css = NULL, link_text = NULL,
      partial_link_text = NULL, xpath = NULL)
      app_find_elements(self, private, css, link_text, partial_link_text,
                        xpath),

    wait_for = function(expr, check_interval = 100, timeout = 3000)
      app_wait_for(self, private, expr, check_interval, timeout),

    list_widgets = function()
      app_list_widgets(self, private),

    check_unique_widget_names = function()
      app_check_unique_widget_names(self, private),

    ## Main methods

    find_widget = function(name, iotype = c("auto", "input", "output"))
      app_find_widget(self, private, name, match.arg(iotype)),

    expect_update = function(output, ..., timeout = 3000,
      iotype = c("auto", "input", "output"))
      app_expect_update(self, private, output, ..., timeout = timeout,
                        iotype = match.arg(iotype)),

    set_inputs = function(..., wait_ = TRUE, values_ = TRUE, timeout_ = 3000)
      app_set_inputs(self, private, ..., wait_ = wait_, values_ = values_,
                     timeout_ = timeout_),

    upload_file = function(..., wait_ = TRUE, values_ = TRUE, timeout_ = 3000)
      app_upload_file(self, private, ..., wait_ = wait_, values_ = values_,
                      timeout_ = timeout_),

    snapshot = function(filename = private$next_snapshot_name(),
                        dir = self$get_tests_dir(),
                        items = list(input = TRUE, output = TRUE, export = TRUE),
                        screenshot = TRUE)
      app_snapshot(self, private, filename, dir, items, screenshot),

    get_tests_dir = function()
      app_get_tests_dir(self, private),

    set_tests_dir = function(path)
      app_set_tests_dir(self, private, path)
  ),

  private = list(

    state = "stopped",                  # stopped or running
    path = NULL,                        # Shiny app path
    shiny_host = NULL,                  # usually 127.0.0.1
    shiny_port = NULL,
    shiny_process = NULL,               # process object
    phantom_port = NULL,
    web = NULL,                         # webdriver session
    after_id = NULL,
    shiny_test_snapshot_base_url = NULL, # URL for shiny's test API
    tests_dir = NULL,                   # Directory for storing test artifacts
    snapshot_count = 0,

    start_shiny = function(path)
      app_start_shiny(self, private, path),

    get_shiny_url = function()
      app_get_shiny_url(self, private),

    setup_debugging = function(debug)
      app_setup_debugging(self, private, debug),

    queue_inputs = function(...)
      app_queue_inputs(self, private, ...),

    flush_inputs = function(wait = TRUE, timeout = 1000)
      app_flush_inputs(self, private, wait, timeout),

    get_test_snapshot_url = function(input = TRUE, output = TRUE,
      export = TRUE, format = "json")
      app_get_test_snapshot_url(self, private, input, output, export,
                                format),

    next_snapshot_name = function()
      app_next_snapshot_name(self, private)

  )
)

shinyapp$debug_log_types <- c(
  "shiny_console",
  "browser",
  "shinytest"
)

app_get_value <- function(self, private, name, iotype) {
  "!DEBUG app_get_value `name` (`iotype`)"
  self$find_widget(name, iotype)$get_value()
}

app_set_value <- function(self, private, name, value, iotype) {
  "!DEBUG app_set_value `name`"
  self$find_widget(name, iotype)$set_value(value)
  invisible(self)
}

app_send_keys <- function(self, private, name, keys) {
  "!DEBUG app_send_keys `name`"
  self$find_widget(name)$send_keys(keys)
  invisible(self)
}

app_get_window_size <- function(self, private) {
  "!DEBUG app_get_window_size"
  private$web$get_window()$get_size()
}

app_set_window_size <- function(self, private, width, height) {
  "!DEBUG app_set_window_size `width`x`height`"
  private$web$get_window()$set_size(width, height)
  invisible(self)
}

app_stop <- function(self, private) {
  "!DEBUG app_stop"
  private$shiny_process$kill()
  private$state <- "stopped"
  invisible(self)
}

app_wait_for <- function(self, private, expr, check_interval, timeout) {
  "!DEBUG app_wait_for"
  private$web$wait_for(expr, check_interval, timeout)
}

app_list_widgets <- function(self, private) {
  "!DEBUG app_list_widgets"
  res <- private$web$execute_script("return shinytest.listWidgets();")
  res$input <- unlist(res$input)
  res$output <- unlist(res$output)
  res
}

app_check_unique_widget_names <- function(self, private) {
  "!DEBUG app_check_unique_widget_names"
  widgets <- self$list_widgets()
  inputs <- widgets$input
  outputs <- widgets$output

  check <- function(what, ids) {
    if (any(duplicated(ids))) {
      dup <- paste(unique(ids[duplicated(ids)]), collapse = ", ")
      warning("Possible duplicate ", what, " widget ids: ", dup)
    }
  }

  if (any(inputs %in% outputs)) {
    dups <- unique(inputs[inputs %in% outputs])
    warning(
      "Widget ids both for input and output: ",
      paste(dups, collapse = ", ")
    )

    ## Otherwise the following checks report it, too
    inputs <- setdiff(inputs, dups)
    outputs <- setdiff(outputs, dups)
  }

  if (length(inputs) > 0) check("input", inputs)
  if (length(outputs) > 0) check("output", outputs)
}


app_get_test_snapshot_url = function(self, private, input, output, export,
                                     format) {
  reqString <- function(group, value) {
    if (isTRUE(value))
      paste0(group, "=1")
    else if (is.character(value))
      paste0(group, "=", paste(value, collapse = ","))
    else
      ""
  }
  paste(
    private$shiny_test_snapshot_base_url,
    reqString("input", input),
    reqString("output", output),
    reqString("export", export),
    paste0("format=", format),
    sep = "&"
  )
}

app_get_tests_dir <- function(self, private) {
  private$tests_dir
}

app_set_tests_dir <- function(self, private, path) {
  private$tests_dir <- path
}
