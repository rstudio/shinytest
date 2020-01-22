
#' Class to manage a shiny app and a phantom.js headless browser
#'
#' @section Usage:
#' \preformatted{app <- ShinyDriver$new(path = ".", loadTimeout = 5000,
#'               checkNames = TRUE, debug = c("none", "all",
#'               ShinyDriver$debugLogTypes), phantomTimeout = 5000,
#'               seed = NULL, cleanLogs = TRUE, shinyOptions = list()))
#' app$stop()
#' app$getDebugLog(type = c("all", ShinyDriver$debugLogTypes))
#'
#' app$getValue(name, iotype = c("auto", "input", "output"))
#' app$setValue(name, value, iotype = c("auto", "input", "output"))
#' app$sendKeys(name = NULL, keys)
#'
#' app$getWindowSize()
#' app$setWindowSize(width, height)
#'
#' app$getUrl()
#' app$goBack()
#' app$refresh()
#' app$getTitle()
#' app$getSource()
#' app$takeScreenshot(file = NULL)
#'
#' app$findElement(css = NULL, linkText = NULL,
#'      partialLinkText = NULL, xpath = NULL)
#'
#' app$findElements(css = NULL, linkText = NULL,
#'      partialLinkText = NULL, xpath = NULL)
#'
#' app$waitFor(expr, checkInterval = 100, timeout = 3000)
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
#'   \item{loadTimeout}{How long to wait for the app to load, in ms.
#'      This includes the time to start R.}
#'   \item{phantomTimeout}{How long to wait when connecting to phantomJS
#'      process, in ms.}
#'   \item{checkNames}{Whether to check if widget names are unique in the
#'      app.}
#'   \item{debug}{Whether to start the app in debugging mode. In debugging
#'      mode debug messages are printed to the console.}
#'   \item{seed}{An optional random seed to use before starting the
#'      application. For apps that use R's random number generator, this
#'      can make their behavior repeatable.}
#'   \item{cleanLogs}{Whether to remove the stdout and stderr logs when the
#'     Shiny process object is garbage collected.}
#'   \item{shinyOptions}{A list of options to pass to \code{runApp()}.}
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
#'   \item{linkText}{Find \code{<a>} HTML elements based on their
#'     \code{innerText}.}
#'   \item{partialLinkText}{Find \code{<a>} HTML elements based on their
#'     \code{innerText}. It uses partial matching.}
#'   \item{xpath}{Find HTML elements using XPath expressions.}
#'   \item{expr}{A string scalar containing JavaScript code that
#'     evaluates to the condition to wait for.}
#'   \item{checkInterval}{How often to check for the condition, in
#'     milliseconds.}
#'   \item{timeout}{Timeout for the condition, in milliseconds.}
#'   \item{output}{Character vector, the name(s) of the Shiny output
#'     widgets that should be updated.}
#'   \item{allowInputNoBinding_}{When setting the value of an input, allow
#'     it to set the value of an input even if that input does not have
#'     an input binding.}
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
#' ready to use. It waits at most \code{loadTimeout} milliseconds, and if
#' the app is not ready, then it throws an error. You can increase
#' \code{loadTimeout} for slow loading apps. Currently it supports apps
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
#' the \code{getValue} method of the \code{\link{Widget}} class.
#'
#' \code{app$setInputs()} sets the value of inputs. The arguments must all
#' be named; an input with each name will be assigned the given value.
#'
#' \code{app$uploadFile()} uploads a file to a file input. The argument must
#' be named and the value must be the path to a local file; that file will be
#' uploaded to a file input with that name.
#'
#' \code{app$getAllValues()} returns a named list of all inputs, outputs,
#' and export values.
#'
#' \code{app$setValue()} finds a widget and sets its value. See the
#' \code{setValue} method of the \code{\link{Widget}} class.
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
#' \code{app$getUrl()} returns the current URL.
#'
#' \code{app$goBack()} \dQuote{presses} the browser's \sQuote{back}
#' button.
#'
#' \code{app$refresh()} \dQuote{presses} the browser's \sQuote{refresh}
#' button.
#'
#' \code{app$getTitle()} returns the title of the page. (More precisely
#' the document title.)
#'
#' \code{app$getSource()} returns the complete HTML source of the current
#' page, in a character scalar.
#'
#' \code{app$takeScreenshot()} takes a screenshot of the current page
#' and writes it to a file, or (if \code{file} is \code{NULL}) shows it
#' on the R graphics device. The output file has PNG format.
#'
#' \code{app$findElement()} find an HTML element on the page, using a
#' CSS selector or an XPath expression. The return value is an
#' \code{\link[webdriver]{Element}} object from the \code{webdriver}
#' package.
#'
#' \code{app$findElements()} finds potentially multiple HTML elements,
#' and returns them in a list of \code{\link[webdriver]{Element}} objects
#' from the \code{webdriver} package.
#'
#' \code{app$waitFor()} waits until a JavaScript expression evaluates
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
#' widget. It returns a \code{\link{Widget}} object.
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

    initialize = function(path = ".", loadTimeout = 5000, checkNames = TRUE,
      debug = c("none", "all", shinytest::ShinyDriver$debugLogTypes),
      phantomTimeout = 5000, seed = NULL, cleanLogs = TRUE,
      shinyOptions = list())
    {
      sd_initialize(self, private, path, loadTimeout, checkNames, debug,
        phantomTimeout = phantomTimeout, seed = seed, cleanLogs = cleanLogs,
        shinyOptions = shinyOptions)
    },

    finalize = function()
      sd_finalize(self, private),

    stop = function()
      sd_stop(self, private),

    getValue = function(name, iotype = c("auto", "input", "output"))
      sd_getValue(self, private, name, match.arg(iotype)),

    setValue = function(name, value, iotype = c("auto", "input", "output"))
      sd_setValue(self, private, name, value, match.arg(iotype)),

    getAllValues = function(input = TRUE, output = TRUE, export = TRUE)
      sd_getAllValues(self, private, input, output, export),

    sendKeys = function(name = NULL, keys)
      sd_sendKeys(self, private, name, keys),

    setWindowSize = function(width, height)
      sd_setWindowSize(self, private, width, height),

    getWindowSize = function()
      sd_getWindowSize(self, private),

    ## Debugging

    getDebugLog = function(type = c("all", ShinyDriver$debugLogTypes))
      sd_getDebugLog(self, private, match.arg(type, several.ok = TRUE)),

    enableDebugLogMessages = function(enable = TRUE)
      sd_enableDebugLogMessages(self, private, enable),

    ## Event logging

    logEvent = function(event, ...)
      sd_logEvent(self, private, event, ...),

    getEventLog = function()
      sd_getEventLog(self, private),

    ## These are just forwarded to the webdriver session

    getUrl = function()
      sd_getUrl(self, private),

    goBack = function()
      sd_goBack(self, private),

    refresh = function()
      sd_refresh(self, private),

    getTitle = function()
      sd_getTitle(self, private),

    getSource = function()
      sd_getSource(self, private),

    takeScreenshot = function(file = NULL)
      sd_takeScreenshot(self, private, file),

    findElement = function(css = NULL, linkText = NULL,
      partialLinkText = NULL, xpath = NULL)
      sd_findElement(self, private, css, linkText, partialLinkText,
                     xpath),

    findElements = function(css = NULL, linkText = NULL,
      partialLinkText = NULL, xpath = NULL)
      sd_findElements(self, private, css, linkText, partialLinkText,
                      xpath),

    waitFor = function(expr, checkInterval = 100, timeout = 3000)
      sd_waitFor(self, private, expr, checkInterval, timeout),


    listWidgets = function()
      sd_listWidgets(self, private),

    checkUniqueWidgetNames = function()
      sd_checkUniqueWidgetNames(self, private),

    executeScript = function(script, ...)
      sd_executeScript(self, private, script, ...),

    executeScriptAsync = function(script, ...)
      sd_executeScriptAsync(self, private, script, ...),

    ## Main methods

    findWidget = function(name, iotype = c("auto", "input", "output"))
      sd_findWidget(self, private, name, match.arg(iotype)),

    expectUpdate = function(output, ..., timeout = 3000,
      iotype = c("auto", "input", "output"))
      sd_expectUpdate(self, private, output, ..., timeout = timeout,
                       iotype = match.arg(iotype)),

    setInputs = function(..., wait_ = TRUE, values_ = TRUE, timeout_ = 3000,
      allowInputNoBinding_ = FALSE, priority_ = c("input", "event")) {
      sd_setInputs(self, private, ..., wait_ = wait_, values_ = values_,
                   timeout_ = timeout_, allowInputNoBinding_ = allowInputNoBinding_,
                   priority_ = priority_)
    },

    uploadFile = function(..., wait_ = TRUE, values_ = TRUE, timeout_ = 3000)
      sd_uploadFile(self, private, ..., wait_ = wait_, values_ = values_,
                     timeout_ = timeout_),

    snapshotDownload = function(id, filename = NULL)
      sd_snapshotDownload(self, private, id, filename),

    snapshot = function(items = NULL,
                        filename = NULL,
                        screenshot = NULL)
      sd_snapshot(self, private, items, filename, screenshot),

    getAppDir = function()
      sd_getAppDir(self, private),

    getTestsDir = function()
      sd_getTestsDir(self, private),

    getRelativePathToApp = function()
      sd_getRelativePathToApp(self, private),

    getSnapshotDir = function()
      sd_getSnapshotDir(self, private),

    snapshotInit = function(path, screenshot = TRUE)
      sd_snapshotInit(self, private, path, screenshot),

    snapshotCompare = function(autoremove = TRUE)
      sd_snapshotCompare(self, private, autoremove),

    isRmd = function()
      sd_isRmd(self, private),

    getAppFilename = function()
      sd_getAppFilename(self, private)
  ),

  private = list(

    state = "stopped",                  # stopped or running
    path = NULL,                        # Full path to app (including filename if it's a .Rmd)
    shinyUrlProtocol = NULL,            # "http" or "https"
    shinyUrlHost = NULL,                # usually 127.0.0.1
    shinyUrlPort = NULL,
    shinyUrlPath = NULL,
    shinyProcess = NULL,                # process object
    phantomPort = NULL,
    web = NULL,                         # webdriver session
    afterId = NULL,
    shinyTestSnapshotBaseUrl = NULL,   # URL for shiny's test API
    snapshotDir = "snapshot",          # Directory for storing test artifacts
    snapshotCount = 0,
    snapshotScreenshot = TRUE,         # Whether to take screenshots for each snapshot
    shinyWorkerId = NA_character_,
    eventLog = list(),
    cleanLogs = TRUE,                  # Whether to clean logs when GC'd

    startShiny = function(path, seed = NULL, loadTimeout = 10000,
                          shinyOptions = list())
      sd_startShiny(self, private, path, seed, loadTimeout, shinyOptions),

    getShinyUrl = function()
      sd_getShinyUrl(self, private),

    setShinyUrl = function(url)
      sd_setShinyUrl(self, private, url),

    setupDebugging = function(debug)
      sd_setupDebugging(self, private, debug),

    queueInputs = function(...)
      sd_queueInputs(self, private, ...),

    flushInputs = function(wait = TRUE, timeout = 1000)
      sd_flushInputs(self, private, wait, timeout),

    getTestSnapshotUrl = function(input = TRUE, output = TRUE,
      export = TRUE, format = "json")
    {
      sd_getTestSnapshotUrl(self, private, input, output, export,
        format)
    }
  )
)

ShinyDriver$debugLogTypes <- c(
  "shiny_console",
  "browser",
  "shinytest"
)

sd_getValue <- function(self, private, name, iotype) {
  "!DEBUG sd_getValue `name` (`iotype`)"
  self$findWidget(name, iotype)$getValue()
}

sd_setValue <- function(self, private, name, value, iotype) {
  "!DEBUG sd_setValue `name`"
  self$findWidget(name, iotype)$setValue(value)
  invisible(self)
}

sd_sendKeys <- function(self, private, name, keys) {
  "!DEBUG sd_sendKeys `name`"
  self$findWidget(name)$sendKeys(keys)
  invisible(self)
}

sd_getWindowSize <- function(self, private) {
  "!DEBUG sd_getWindowSize"
  private$web$getWindow()$getSize()
}

sd_setWindowSize <- function(self, private, width, height) {
  "!DEBUG sd_setWindowSize `width`x`height`"
  private$web$getWindow()$setSize(width, height)
  invisible(self)
}

sd_stop <- function(self, private) {
  "!DEBUG sd_stop"

  if (private$state == "stopped")
    return(invisible(self))

  self$logEvent("Closing PhantomJS session")
  private$web$delete()

  # If the app is being hosted locally, kill the process.
  if (!is.null(private$shinyProcess)) {
    self$logEvent("Ending Shiny process")

    # Attempt soft-kill before hard-kill. This is a workaround for
    # https://github.com/r-lib/processx/issues/95
    # SIGINT quits the Shiny application, SIGTERM tells R to quit.
    # Unfortunately, SIGTERM isn't quite the same as `q()`, because
    # finalizers with onexit=TRUE don't seem to run.
    private$shinyProcess$signal(tools::SIGINT)
    private$shinyProcess$wait(500)
    private$shinyProcess$signal(tools::SIGTERM)
    private$shinyProcess$wait(250)
    private$shinyProcess$kill()
  }

  private$state <- "stopped"
  invisible(self)
}

sd_waitFor <- function(self, private, expr, checkInterval, timeout) {
  "!DEBUG sd_waitFor"
  private$web$waitFor(expr, checkInterval, timeout)
}

sd_listWidgets <- function(self, private) {
  "!DEBUG sd_listWidgets"
  res <- private$web$executeScript("return shinytest.listWidgets();")
  res$input <- unlist(res$input)
  res$output <- unlist(res$output)
  res
}

sd_checkUniqueWidgetNames <- function(self, private) {
  "!DEBUG sd_checkUniqueWidgetNames"
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

sd_executeScript <- function(self, private, script, ...) {
  "!DEBUG sd_executeScript"
  private$web$executeScript(script, ...)
}

sd_executeScriptAsync <- function(self, private, script, ...) {
  "!DEBUG sd_executeScriptAsync"
  private$web$executeScriptAsync(script, ...)
}

sd_getTestSnapshotUrl = function(self, private, input, output, export,
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

sd_getAppDir <- function(self, private) {
  # private$path can be a directory (for a normal Shiny app) or path to a .Rmd
  # file.
  if (self$isRmd())
    dirname(private$path)
  else
    private$path
}

# Returns the tests/ or tests/shinytests/ dir otherwise, based on
# what it finds in each dir.
sd_getTestsDir <- function(self, private) {
  # private$path can be a directory (for a normal Shiny app) or path to a .Rmd
  # file.
  path <- private$path
  if (self$isRmd()) {
    path <- dirname(private$path)
  }
  findTestsDir(path, quiet=TRUE)
}

# Get the relative path from the test directory to the parent. Since there are currently
# only two supported test dir options, we can just cheat rather than doing a real path computation
# between the two paths.
sd_getRelativePathToApp <- function(self, private) {
  td <- self$getTestsDir()
  if (grepl("[/\\\\]shinytest[/\\\\]?", td, perl=TRUE)) {
    return(file.path("..", ".."))
  } else {
    return(file.path(".."))
  }
}

sd_getSnapshotDir <- function(self, private) {
  testDir <- findTestsDir(self$getAppDir(), quiet=TRUE)
  file.path(testDir, private$snapshotDir)
}

sd_snapshotInit <- function(self, private, path, screenshot) {
  if (grepl("^/", path)) {
    stop("Snapshot dir must be a relative path.")
  }

  # Strip off trailing slash if present
  path <- sub("/$", "", path)

  private$snapshotCount <- 0
  private$snapshotDir <- path
  private$snapshotScreenshot <- screenshot
}

sd_isRmd <- function(self, private) {
  is_rmd(private$path)
}

sd_getAppFilename <- function(self, private) {
  if (!self$isRmd()) {
    NULL
  } else {
    basename(private$path)
  }
}
