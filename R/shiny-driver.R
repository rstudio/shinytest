#' Class to manage a shiny app and a `phantom.js` headless browser.
#'
#' @description
#' This class starts a Shiny app in a new R session, along with a `phantom.js`
#' headless browser that can be used to simulate user actions. This provides
#' a full simulation of a Shiny app so that you can test user interactions
#' with a live app.
#'
#' @param iotype Type of the Shiny widget. Usually shinytest finds the widgets
#'   by their name, so this is only needed if you use the same name for an
#'   input and output widget.
#' @param timeout Amount of time to wait before giving up (milliseconds).
#' @param timeout_ Amount of time to wait before giving up (milliseconds).
#' @param wait_ Wait until all reactive updates have completed?
#' @param name Name of a shiny widget.
#' @param css CSS selector to find an HTML element.
#' @param linkText Find `<a>` HTML elements based on exact `innerText`
#' @param partialLinkText Find `<a>` HTML elements based on partial `innerText`
#' @param xpath Find HTML elements using XPath expressions.
#' @param checkInterval How often to check for the condition, in ms.
#' @importFrom R6 R6Class
#' @export
ShinyDriver <- R6Class(
  "ShinyDriver",

  public = list(

    #' @param path Path to a directory containing a Shiny app, i.e. a
    #'   single `app.R` file or a `server.R`-`ui.R` pair.
    #' @param loadTimeout How long to wait for the app to load, in ms.
    #'   This includes the time to start R. Defaults to 5s when running
    #'   locally and 10s when running on CI.
    #' @param phantomTimeout How long to wait when connecting to phantomJS
    #'  process, in ms
    #' @param checkNames Check if widget names are unique?
    #' @param debug Start the app in debugging mode? In debugging mode debug
    #'   messages are printed to the console.
    #' @param seed An optional random seed to use before starting the application.
    #'   For apps that use R's random number generator, this can make their
    #'   behavior repeatable.
    #' @param cleanLogs Whether to remove the stdout and stderr logs when the
    #'     Shiny process object is garbage collected.
    #' @param shinyOptions A list of options to pass to [shiny::runApp()].
    initialize = function(path = ".", loadTimeout = NULL, checkNames = TRUE,
      debug = c("none", "all", shinytest::ShinyDriver$debugLogTypes),
      phantomTimeout = 5000, seed = NULL, cleanLogs = TRUE,
      shinyOptions = list())
    {
      sd_initialize(self, private, path, loadTimeout, checkNames, debug,
        phantomTimeout = phantomTimeout, seed = seed, cleanLogs = cleanLogs,
        shinyOptions = shinyOptions)
    },

    #' @description Stop app and clean up logs.
    finalize = function()
      sd_finalize(self, private),

    #' @description
    #' Stop the app, the terminate external R process that runs the app and
    #' the phantomjs instance.
    stop = function()
      sd_stop(self, private),

    #' @description
    #' Finds a widget and queries its value. See the `getValue()` method of
    #' [Widget] for more details.
    getValue = function(name, iotype = c("auto", "input", "output"))
      sd_getValue(self, private, name, match.arg(iotype)),

    #' @description
    #' Finds a widget and sets its value. It's a shortcut for `findElement()`
    #' plus `setValue()`; see the [Widget] documentation for more details.
    #'
    #' @param value New value.
    #' @returns Self, invisibly.
    setValue = function(name, value, iotype = c("auto", "input", "output"))
      sd_setValue(self, private, name, value, match.arg(iotype)),

    #' @description
    #' Returns a named list of all inputs, outputs, and export values.
    #'
    #' @param input,output,export Either `TRUE` to return all
    #'   input/output/exported values, or a character vector of specific
    #'   controls.
    getAllValues = function(input = TRUE, output = TRUE, export = TRUE)
      sd_getAllValues(self, private, input, output, export),

    #' @description
    #' Sends the specified keys to specific HTML element. Shortcut for
    #' `findWidget()` plus `sendKeys()`.
    #' @param keys Keys to send to the widget or the app. See [webdriver::key]
    #'   for how to specific special keys.
    #' @returns Self, invisibly.
    sendKeys = function(name, keys)
      sd_sendKeys(self, private, name, keys),

    #' @description
    #' Sets size of the browser window.
    #' @param width,height Height and width of browser, in pixels.
    #' @returns Self, invisibly.
    setWindowSize = function(width, height)
      sd_setWindowSize(self, private, width, height),

    #' @description
    #' Get current size of the browser window, as list of integer scalars
    #'   named `width` and `height`.
    getWindowSize = function()
      sd_getWindowSize(self, private),

    ## Debugging

    #' @description
    #' Query one or more of the debug logs.
    #' @param type Log type: `"all"`, `"shiny_console"`, `"browser"`,
    #'   or `"shinytest"`.
    getDebugLog = function(type = c("all", ShinyDriver$debugLogTypes))
      sd_getDebugLog(self, private, match.arg(type, several.ok = TRUE)),

    #' @description
    #' Enable/disable debugging messages
    #' @param enable New value.
    enableDebugLogMessages = function(enable = TRUE)
      sd_enableDebugLogMessages(self, private, enable),

    ## Event logging

    #' @description Add event to log.
    #' @param event Event name
    #' @param ... Addition data to store for event
    logEvent = function(event, ...)
      sd_logEvent(self, private, event, ...),

    #' @description Retrieve event log.
    getEventLog = function()
      sd_getEventLog(self, private),

    ## These are just forwarded to the webdriver session

    #' @description Get current url
    getUrl = function()
      sd_getUrl(self, private),

    #' @description Get page title
    getTitle = function()
      sd_getTitle(self, private),

    #' @description Get complete source of current page.
    getSource = function()
      sd_getSource(self, private),

    #' @description Return to previous page
    #' @returns Self, invisibly.
    goBack = function()
      sd_goBack(self, private),

    #' @description Refresh the browser
    #' @returns Self, invisibly.
    refresh = function()
      sd_refresh(self, private),

    #' @description
    #' Takes a screenshot of the current page and writes it to a PNG file or
    #' shows on current graphics device.
    #' @param file File name to save the screenshot to. If `NULL`, then
    #'   it will be shown on the R graphics device.
    #' @returns Self, invisibly.
    takeScreenshot = function(file = NULL)
      sd_takeScreenshot(self, private, file),

    #' @description
    #' Find an HTML element on the page, using a CSS selector, XPath expression,
    #' or link text (for `<a>` tags). If multiple elements are matched, only
    #' the first is returned.
    #' @returns A [webdriver::Element].
    findElement = function(css = NULL, linkText = NULL,
      partialLinkText = NULL, xpath = NULL)
      sd_findElement(self, private, css, linkText, partialLinkText,
                     xpath),

    #' @description
    #' Find all elements matching CSS selection, xpath, or link text.
    #' @returns A list of [webdriver::Element]s.
    findElements = function(css = NULL, linkText = NULL,
      partialLinkText = NULL, xpath = NULL)
      sd_findElements(self, private, css, linkText, partialLinkText,
                      xpath),

    #' @description
    #' Waits until a JavaScript `expr`ession evaluates to `true` or the
    #' `timeout` is exceeded.
    #' @param expr A string containing JavaScript code. Will wait until the
    #'   condition returns `true`.
    #' @returns `TRUE` if expression evaluates to `true` without error, before
    #'   timeout. Otherwise returns `NA`.
    waitFor = function(expr, checkInterval = 100, timeout = 3000)
      sd_waitFor(self, private, expr, checkInterval, timeout),

    #' @description
    #' Waits until the `input` or `output` with name `name` is not one of
    #' `ignore`d values, or the timeout is reached.
    #'
    #' This function can be useful in helping determine if an application
    #' has initialized or finished processing a complex reactive situation.
    #' @param ignore List of possible values to ignore when checking for
    #'   updates.
    waitForValue = function(name, ignore = list(NULL, ""), iotype = c("input", "output", "export"), timeout = 10000, checkInterval = 400) {
      sd_waitForValue(self, private, name = name, ignore = ignore, iotype = match.arg(iotype), timeout = timeout, checkInterval = checkInterval)
    },

    #' @description
    #' Lists the names of all input and output widgets
    #' @return A list of two character vectors, named `input` and `output`.
    listWidgets = function()
      sd_listWidgets(self, private),

    #' @description
    #' Check if Shiny widget names are unique.
    checkUniqueWidgetNames = function()
      sd_checkUniqueWidgetNames(self, private),

    #' @description Execute JS code
    #' @param script JS to execute.
    #' @param ... Additional arguments to script.
    #' @returns Self, invisibly.
    executeScript = function(script, ...)
      sd_executeScript(self, private, script, ...),

    #' @description Execute JS code asynchronously.
    #' @param script JS to execute.
    #' @param ... Additional arguments to script.
    #' @returns Self, invisibly.
    executeScriptAsync = function(script, ...)
      sd_executeScriptAsync(self, private, script, ...),

    ## Main methods

    #' @description
    #' Finds the a Shiny input or output control.
    #' @return A [Widget].
    findWidget = function(name, iotype = c("auto", "input", "output"))
      sd_findWidget(self, private, name, match.arg(iotype)),

    #' @description
    #' It performs one or more update operations via the browser, thens
    #' waits for the specified output(s) to update. The test succeeds if
    #' all specified output widgets are updated before the `timeout`.
    #' For updates that involve a lot of computation, increase the timeout.
    #'
    #' @param output Name of output control to check.
    #' @param ... Name-value pairs used to update inputs.
    expectUpdate = function(output, ..., timeout = 3000,
      iotype = c("auto", "input", "output"))
      sd_expectUpdate(self, private, output, ..., timeout = timeout,
                       iotype = match.arg(iotype)),

    #' @description
    #' Sets input values.
    #' @param ... Name-value pairs, `name1 = value1, name2 = value2` etc.
    #'   Enput with name `name1` will be assigned value `value1`.
    #' @param allowInputNoBinding_ When setting the value of an input, allow
    #'   it to set the value of an input even if that input does not have
    #'   an input binding.
    #' @param priority_ Sets the event priority. For expert use only: see
    #'   <https://shiny.rstudio.com/articles/communicating-with-js.html#values-vs-events> for details.
    #' @param values_ If `TRUE`, will return final updated values of inputs.
    #' @return Returns update values, invisibly.
    setInputs = function(..., wait_ = TRUE, values_ = TRUE, timeout_ = 3000,
      allowInputNoBinding_ = FALSE, priority_ = c("input", "event")) {
      sd_setInputs(self, private, ..., wait_ = wait_, values_ = values_,
                   timeout_ = timeout_, allowInputNoBinding_ = allowInputNoBinding_,
                   priority_ = priority_)
    },

    #' @description
    #' Uploads a file to a file input.
    #' @param ... Name-path pairs, e.g. `name1 = path1`. The file located at
    #' `path1` will be uploaded to file input with name `name1`.
    #' @param values_ If `TRUE`, will return final updated values of download
    #'   control.
    uploadFile = function(..., wait_ = TRUE, values_ = TRUE, timeout_ = 3000)
      sd_uploadFile(self, private, ..., wait_ = wait_, values_ = values_,
                     timeout_ = timeout_),

    #' @description
    #' Download a snapshot. Generally, you should not call this function
    #' yourself; it will be generated by [recordTest()] as needed.
    #' @param path Directory to save snapshots.
    #' @param screenshot Take screenshots for each snapshot?
    snapshotInit = function(path, screenshot = TRUE)
      sd_snapshotInit(self, private, path, screenshot),

    #' @description
    #' Take a snapshot. Generally, you should not call this function
    #' yourself; it will be generated by [recordTest()] as needed.
    #' @param items Elements to include in snapshot
    #' @param filename Filename to use
    #' @param screenshot Take a screenshot? Overrides value set by
    #'   `$snapshotInit()`
    snapshot = function(items = NULL,
                        filename = NULL,
                        screenshot = NULL)
      sd_snapshot(self, private, items, filename, screenshot),


    #' @description Deprecated
    #' @param ... Ignored
    snapshotCompare = function(...) {
      message("app$snapshotCompare() no longer used")
    },

    #' @description
    #' Download a snapshot. Generally, you should not call this function
    #' yourself; it will be generated by [recordTest()] as needed.
    #' @param id,filename Internal use only
    snapshotDownload = function(id, filename = NULL)
      sd_snapshotDownload(self, private, id, filename),

    #' @description Directory where app is located
    getAppDir = function()
      sd_getAppDir(self, private),

    #' @description App file name, i.e. `app.R` or `server.R`. `NULL` for Rmds.
    getAppFilename = function()
      sd_getAppFilename(self, private),

    #' @description Directory where tests are located
    getTestsDir = function()
      sd_getTestsDir(self, private),

    #' @description Relative path to app from current directory.
    getRelativePathToApp = function()
      sd_getRelativePathToApp(self, private),

    #' @description Directory where snapshots are located.
    getSnapshotDir = function()
      sd_getSnapshotDir(self, private),

    #' @description Is this app an Shiny Rmd document?
    isRmd = function()
      sd_isRmd(self, private)
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

# Note: This queries the **browser**
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

sd_waitForValue <- function(self, private, name, ignore = list(NULL, ""), iotype = "input", timeout = 10000, checkInterval = 400) {
  "!DEBUG sd_waitForValue"

  timeoutSec <- as.numeric(timeout) / 1000
  if (!is.numeric(timeoutSec) || is.na(timeoutSec) || is.nan(timeoutSec)) {
    stop("timeout must be numeric")
  }
  checkInterval <- as.numeric(checkInterval)
  if (!is.numeric(checkInterval) || is.na(checkInterval) || is.nan(checkInterval)) {
    stop("checkInterval must be numeric")
  }

  now <- function() {
    as.numeric(Sys.time())
  }

  endTime <- now() + timeoutSec

  while (TRUE) {
    value <- try({
      # by default, do not retrieve anything
      args <- list(input = FALSE, output = FALSE, export = FALSE)
      # only retrieve `name` from `iotype`
      args[[iotype]] <- name
      do.call(self$getAllValues, args)[[iotype]][[name]]
    }, silent = TRUE)

    # if no error when trying ot retrieve the value..
    if (!inherits(value, "try-error")) {
      # check against all invalid values
      isInvalid <- vapply(ignore, identical, logical(1), x = value)
      # if no matches, then it's a success!
      if (!any(isInvalid)) {
        return(value)
      }
    }

    # if too much time has elapsed... throw
    if (now() > endTime) {
      stop("timeout reached when waiting for value: ", name)
    }

    # wait a little bit for shiny to do some work
    Sys.sleep(checkInterval / 1000)
  }

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
  invisible(self)
}

sd_executeScriptAsync <- function(self, private, script, ...) {
  "!DEBUG sd_executeScriptAsync"
  private$web$executeScriptAsync(script, ...)
  invisible(self)
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

# Returns the tests/ or tests/shinytest/ dir otherwise, based on
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
