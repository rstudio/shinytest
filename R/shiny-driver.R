
#' Class to manage a shiny app and a phantom.js headless browser
#'
#' @section Usage:
#' \preformatted{app <- ShinyDriver$new(path = ".", load_timeout = 5000,
#'               check_names = TRUE, debug = c("none", "all",
#'               ShinyDriver$debugLogTypes))
#' app$stop()
#' app$getDebugLog(type = c("all", ShinyDriver$debugLogTypes))
#'
#' app$getValue(name, iotype = c("auto", "input", "output"))
#' app$setValue(name, value, iotype = c("auto", "input", "output"))
#' app$sendKeys(name = NULL, keys)
#'
#' app$get_windows_size()
#' app$setWindowSize(width, height)
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
#' app$listWidgets()
#'
#' app$checkUniqueWidgetNames()
#'
#' app$findWidget(name, iotype = c("auto", "input", "output"))
#'
#' app$expectUpdate(output, ..., timeout = 3000,
#'     iotype = c("auto", "input", "output"))
#' }
#'
#' @section Arguments:
#' \describe{
#'   \item{app}{A \code{ShinyDriver} instance.}
#'   \item{path}{Path to a directory containing a Shiny app, i.e. a
#'      single \code{app.R} file or a \code{server.R} and \code{ui.R}
#'      pair.}
#'   \item{load_timeout}{How long to wait for the app to load, in ms.
#'      This includes the time to start R.}
#'   \item{check_names}{Whether to check if widget names are unique in the
#'      app.}
#'   \item{debug}{Whether to start the app in debugging mode. In debugging
#'      mode debug messages are printed to the console.}
#'   \item{name}{Name of a shiny widget. For \code{$sendKeys} it can
#'      be \code{NULL}, in which case the keys are sent to the active
#'      HTML element.}
#'   \item{iotype}{Type of the Shiny widget. Usually \code{shinytest}
#'      finds the widgets by their name, so this need not be specified,
#'      but Shiny allows input and output widgets with identical names.}
#'   \item{keys}{Keys to send to the widget or the app. See the
#'      \code{sendKeys} method of the \code{webdriver} package.}
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
#'   \item{...}{For \code{expectUpdate} these can be named arguments.
#'     The argument names correspond to Shiny input widgets: each input
#'     widget will be set to the specified value.}
#' }
#'
#' @section Details:
#'
#' \code{ShinyDriver$new()} function creates a \code{ShinyDriver} object. It starts
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
#' \code{app$getDebugLog()} queries one or more of the debug logs:
#' \code{shiny_console}, \code{browser} or \code{shinytest}.
#'
#' \code{app$getValue()} finds a widget and queries its value. See
#' the \code{getValue} method of the \code{\link{widget}} class.
#'
#' \code{app$setInputs()} sets the value of inputs. The arguments must all
#' be named; an input with each name will be assigned the given value.
#'
#' \code{app$uploadFile()} uploads a file to a file input. The argument must
#' be named and the value must be the path to a local file; that file will be
#' uploaded to a file input with that name.
#'
#' \code{app$getAllValues()} returns a named list of all inputs, outputs,
#' and error values.
#'
#' \code{app$setValue()} finds a widget and sets its value. See the
#' \code{setValue} method of the \code{\link{widget}} class.
#'
#' \code{app$sendKeys} sends the specified keys to the HTML element of the
#' widget.
#'
#' \code{app$getWindowSize()} returns the current size of the browser
#' window, in a list of two integer scalars named \sQuote{width} and
#' \sQuote{height}.
#'
#' \code{app$setWindowSize()} sets the size of the browser window to the
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
#' \code{app$listWidgets()} lists the names of all input and output
#' widgets. It returns a list of two character vectors, named \code{input}
#' and \code{output}.
#'
#' \code{app$checkUniqueWidgetNames()} checks if Shiny widget names
#' are unique.
#'
#' \code{app$findWidget()} finds the corresponding HTML element of a Shiny
#' widget. It returns a \code{\link{widget}} object.
#'
#' \code{expectUpdate()} is one of the main functions to test Shiny apps.
#' It performs one or more update operations via the browser, and then
#' waits for the specified output widgets to update. The test succeeds if
#' all specified output widgets are updated before the timeout. For
#' updates that involve a lot of computation, you increase the timeout.
#'
#' @name ShinyDriver
#' @examples
#' \dontrun{
#' ## https://github.com/rstudio/shiny-examples/tree/master/050-kmeans-example
#' app <- ShinyDriver$new("050-kmeans-example")
#' expectUpdate(app, xcol = "Sepal.Width", output = "plot1")
#' expectUpdate(app, ycol = "Petal.Width", output = "plot1")
#' expectUpdate(app, clusters = 4, output = "plot1")
#' }
NULL

#' @importFrom R6 R6Class
#' @export

ShinyDriver <- R6Class(
  "ShinyDriver",

  public = list(

    initialize = function(path = ".", load_timeout = 5000,
      check_names = TRUE,
      debug = c("none", "all", ShinyDriver$debugLogTypes))
      app_initialize(self, private, path, load_timeout, check_names,
                     match.arg(debug, several.ok = TRUE)),

    stop = function()
      app_stop(self, private),

    getValue = function(name, iotype = c("auto", "input", "output"))
      app_getValue(self, private, name, match.arg(iotype)),

    setValue = function(name, value, iotype = c("auto", "input", "output"))
      app_setValue(self, private, name, value, match.arg(iotype)),

    getAllValues = function(input = TRUE, output = TRUE, export = TRUE)
      app_getAllValues(self, private, input, output, export),

    sendKeys = function(name = NULL, keys)
      app_sendKeys(self, private, name, keys),

    setWindowSize = function(width, height)
      app_setWindowSize(self, private, width, height),

    getWindowSize = function()
      app_getWindowSize(self, private),

    ## Debugging

    getDebugLog = function(type = c("all", ShinyDriver$debugLogTypes))
      app_getDebugLog(self, private, match.arg(type, several.ok = TRUE)),

    enableDebugLogMessages = function(enable = TRUE)
      app_enableDebugLogMessages(self, private, enable),

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


    listWidgets = function()
      app_listWidgets(self, private),

    checkUniqueWidgetNames = function()
      app_checkUniqueWidgetNames(self, private),

    ## Main methods

    findWidget = function(name, iotype = c("auto", "input", "output"))
      app_findWidget(self, private, name, match.arg(iotype)),

    expectUpdate = function(output, ..., timeout = 3000,
      iotype = c("auto", "input", "output"))
      app_expectUpdate(self, private, output, ..., timeout = timeout,
                       iotype = match.arg(iotype)),

    setInputs = function(..., wait_ = TRUE, values_ = TRUE, timeout_ = 3000)
      app_setInputs(self, private, ..., wait_ = wait_, values_ = values_,
                    timeout_ = timeout_),

    uploadFile = function(..., wait_ = TRUE, values_ = TRUE, timeout_ = 3000)
      app_uploadFile(self, private, ..., wait_ = wait_, values_ = values_,
                     timeout_ = timeout_),

    snapshot = function(items = NULL,
                        filename = NULL,
                        screenshot = NULL)
      app_snapshot(self, private, items, filename, screenshot),

    getTestsDir = function()
      app_getTestsDir(self, private),

    setTestsDir = function(path)
      app_setTestsDir(self, private, path),

    getSnapshotDir = function()
      app_getSnapshotDir(self, private),

    snapshotInit = function(path)
      app_snapshotInit(self, private, path),

    snapshotCompare = function(autoremove = TRUE)
      app_snapshotCompare(self, private, autoremove)
  ),

  private = list(

    state = "stopped",                  # stopped or running
    path = NULL,                        # Shiny app path
    shinyHost = NULL,                   # usually 127.0.0.1
    shinyPort = NULL,
    shinyProcess = NULL,                # process object
    phantomPort = NULL,
    web = NULL,                         # webdriver session
    afterId = NULL,
    shinyTestSnapshotBaseUrl = NULL, # URL for shiny's test API
    testsDir = "tests",                # Directory for test scripts
    snapshotDir = "snapshot",          # Directory for storing test artifacts
    snapshotCount = 0,

    startShiny = function(path)
      app_startShiny(self, private, path),

    getShinyUrl = function()
      app_getShinyUrl(self, private),

    setupDebugging = function(debug)
      app_setupDebugging(self, private, debug),

    queueInputs = function(...)
      app_queueInputs(self, private, ...),

    flushInputs = function(wait = TRUE, timeout = 1000)
      app_flushInputs(self, private, wait, timeout),

    getTestSnapshotUrl = function(input = TRUE, output = TRUE,
      export = TRUE, format = "json")
      app_getTestSnapshotUrl(self, private, input, output, export,
                                format)

  )
)

ShinyDriver$debugLogTypes <- c(
  "shiny_console",
  "browser",
  "shinytest"
)

app_getValue <- function(self, private, name, iotype) {
  "!DEBUG app_getValue `name` (`iotype`)"
  self$findWidget(name, iotype)$getValue()
}

app_setValue <- function(self, private, name, value, iotype) {
  "!DEBUG app_setValue `name`"
  self$findWidget(name, iotype)$setValue(value)
  invisible(self)
}

app_sendKeys <- function(self, private, name, keys) {
  "!DEBUG app_sendKeys `name`"
  self$findWidget(name)$sendKeys(keys)
  invisible(self)
}

app_getWindowSize <- function(self, private) {
  "!DEBUG app_getWindowSize"
  private$web$get_window()$get_size()
}

app_setWindowSize <- function(self, private, width, height) {
  "!DEBUG app_setWindowSize `width`x`height`"
  private$web$get_window()$set_size(width, height)
  invisible(self)
}

app_stop <- function(self, private) {
  "!DEBUG app_stop"
  private$shinyProcess$kill()
  private$state <- "stopped"
  invisible(self)
}

app_wait_for <- function(self, private, expr, check_interval, timeout) {
  "!DEBUG app_wait_for"
  private$web$wait_for(expr, check_interval, timeout)
}

app_listWidgets <- function(self, private) {
  "!DEBUG app_listWidgets"
  res <- private$web$execute_script("return shinytest.listWidgets();")
  res$input <- unlist(res$input)
  res$output <- unlist(res$output)
  res
}

app_checkUniqueWidgetNames <- function(self, private) {
  "!DEBUG app_checkUniqueWidgetNames"
  widgets <- self$listWidgets()
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


app_getTestSnapshotUrl = function(self, private, input, output, export,
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
    private$shinyTestSnapshotBaseUrl,
    reqString("input", input),
    reqString("output", output),
    reqString("export", export),
    paste0("format=", format),
    sep = "&"
  )
}

app_getTestsDir <- function(self, private) {
  file.path(private$path, "tests")
}

app_setTestsDir <- function(self, private, path) {
  if (grepl("^/", path)) {
    stop("Tests dir must be a relative path.")
  }
  private$testsDir <- path
}

app_getSnapshotDir <- function(self, private) {
  file.path(self$getTestsDir(), private$snapshotDir)
}

app_snapshotInit <- function(self, private, path) {
  if (grepl("^/", path)) {
    stop("Snapshot dir must be a relative path.")
  }

  # Strip off trailing slash if present
  path <- sub("/$", "", path)

  private$snapshotCount <- 0
  private$snapshotDir <- path
}
