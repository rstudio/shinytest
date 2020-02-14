shinytest (development version)
==========

* Also display the massage about where to find the diff when de diff viewer was opened but the diffs were not accepted. ([#131](https://github.com/rstudio/shinytest/issues/131))

* Recommend that tests be placed in `tests/shinytests/` instead of directly in the tests directory. Users with their tests in the `tests/` directory will now see a message about this change. Storing shinytests directly in `tests/` will be deprecated in the future.

* Added new `suffix` option, which allows adding a suffix to an expected results directory. This makes it possible to store multiple sets of results, which can be useful, for example, if you run tests on multiple platforms. ([#295](https://github.com/rstudio/shinytest/pull/295))

* Previously, on Windows, the reported resolution of screenshots depended on the actual screen resolution. For example, on one Windows machine, it might report a screenshot to be 96 ppi, while on another machine, it might report it to be 240 ppi, even though the image data is exactly the same from the two machines. This caused problems when expected results were generated on one machine and the tests were run on another machine. Now, the screenshots are modified so that they always report 72 ppi resolution, which is the same as on Mac and Linux. ([#297](https://github.com/rstudio/shinytest/pull/297))

* Added new `ShinyDriver` method `app$waitForValue()` which will wait until the current application's `input` (or `output`) value is not one of the supplied invalid values.  ([#304](https://github.com/rstudio/shinytest/pull/304))

shinytest 1.3.1
=======

## New features

* Added support for setting inputs that do not have an input binding (#232); furthermore, inputs set with event priority (e.g., `Shiny.setInputValue('key', 'value', {priority: 'event'})`) are also supported (#239).

* Added support for triggering snapshots from the keyboard (by pressing Ctrl-Shift-S or Command-Shift-S) while recording tests with `recordTest()` (#240).

* `recordTest()` gains a `debug` argument for displaying (`"shiny_console"`, `"browser"`, and/or `"shinytest`) logs into the R console (#146). When these logs are displayed, they use `format.shinytest_logs()` with `short = TRUE` which suppress the timestamp and level.

## Bug fixes

* Recording a test that produces an input value with an escape character, '\', no longer results in error (#241).

## Improvements

* `ShinyDriver` now passes the current `RNGkind()` to the background R process that serves up the app being tested. This allows for better control over randomness across mutliple versions of R with different `RNGkind()` defaults (e.g., 3.5 and 3.6)

shinytest 1.3.0
=====

* First public release
