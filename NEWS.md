# shinytest 1.5.4

* Updated contact information in DESCRIPTION file. (#436)

# shinytest 1.5.3

* The `tryInvokeRestart()` function (used in shinytest 1.5.2) was added in R 4.0. This version replaces it with code that will work in older versions of R.

# shinytest 1.5.2

* Messages emitted at load time are now converted to `packageStartupMessage`s so that they can be suppressed with `suppressPackageStartupMessages()`.

# shinytest 1.5.1

* `ShinyDriver$initialize()` now waits for the browser to navigate to the page before it injects the JavaScript testing code. This is needed when using phantomjs 2.5.0-beta. (#388)

* The diffviewer widget previously ignored some very minor pixel differences, but now it will show every difference in red. (#391)

* Added support for displaying text differences for files with a `.txt` extension. Files that do not display text differences will now display a hash of the file contents (#407)

# shinytest 1.5.0

* `ShinyDriver$takeSnapshot()` gains ability to take a snapshot of a single
  element (#260).

* New `Widget$getHtml()` returns the complete HTML of the selected widget
  (#347).

* Add new `osName()` function, which returns the name of the operating system.
  (#368)

* `ShinyDriver$intialize()` gains two new arguments:
    * `renderArgs`: a list of arguments to `rmarkdown::run()`, making it possible to set parameters for parameterised `runtime: shiny` Rmd documents (#249).
    * `options`: a list of arguments to `base::options()`, making it possible to set options in the child process which runs the application (#373).

* `ShinyDriver$getAllValues()`, `ShinyDriver$snapshot()`, and
  `ShinyDriver$snapshotDownload()` give clear errors messages if the Shiny
  app is no longer running (e.g. because you've trigged a `stopApp()`) (#192).

* `ShinyDriver$snapshotDownload()` gives a clear error message if the
  `fileInput()` does not exist (#191)

* New `Widget$click()` method to click buttons (#325).

* New `ShinyDriver$waitForShiny()` that waits until Shiny is done computing
  on the reactive graph (#327).

* `testApp()` can now take a path to a directory containing a single
  interactive `.Rmd` (#334).

* Fixed [#206](https://github.com/rstudio/shinytest/issues/206): On Windows, non-ASCII characters in JSON snapshots were written using the native encoding, instead of UTF-8. ([#318](https://github.com/rstudio/shinytest/pull/318), [#320](https://github.com/rstudio/shinytest/pull/320))

* Added `registerInputProcessor()`, which allows other packages to control how code is generated when recording input values from input bindings from that package. ([#321])

# shinytest 1.4.0

* Recommend that tests be placed in `tests/shinytest/` instead of directly in the tests directory. Users with their tests in the `tests/` directory will now see a message about this change. Storing shinytests directly in `tests/` will be deprecated in the future. The new function `migrateShinytestDir()` will migrate from the old to the new directory layout.

* Also display the message about where to find the diff when the diff viewer was opened but the diffs were not accepted. ([#131](https://github.com/rstudio/shinytest/issues/131))

* Added new `suffix` option, which allows adding a suffix to an expected results directory. This makes it possible to store multiple sets of results, which can be useful, for example, if you run tests on multiple platforms. ([#295](https://github.com/rstudio/shinytest/pull/295))

* Previously, on Windows, the reported resolution of screenshots depended on the actual screen resolution. For example, on one Windows machine, it might report a screenshot to be 96 ppi, while on another machine, it might report it to be 240 ppi, even though the image data is exactly the same from the two machines. This caused problems when expected results were generated on one machine and the tests were run on another machine. Now, the screenshots are modified so that they always report 72 ppi resolution, which is the same as on Mac and Linux. ([#297](https://github.com/rstudio/shinytest/pull/297))

* Added new `ShinyDriver` method `app$waitForValue()` which will wait until the current application's `input` (or `output`) value is not one of the supplied invalid values.  ([#304](https://github.com/rstudio/shinytest/pull/304))

# shinytest 1.3.1

## New features

* Added support for setting inputs that do not have an input binding (#232); furthermore, inputs set with event priority (e.g., `Shiny.setInputValue('key', 'value', {priority: 'event'})`) are also supported (#239).

* Added support for triggering snapshots from the keyboard (by pressing Ctrl-Shift-S or Command-Shift-S) while recording tests with `recordTest()` (#240).

* `recordTest()` gains a `debug` argument for displaying (`"shiny_console"`, `"browser"`, and/or `"shinytest`) logs into the R console (#146). When these logs are displayed, they use `format.shinytest_logs()` with `short = TRUE` which suppress the timestamp and level.

## Bug fixes

* Recording a test that produces an input value with an escape character, '\', no longer results in error (#241).

## Improvements

* `ShinyDriver` now passes the current `RNGkind()` to the background R process that serves up the app being tested. This allows for better control over randomness across mutliple versions of R with different `RNGkind()` defaults (e.g., 3.5 and 3.6)

# shinytest 1.3.0

* First public release
