1.3.1
==========

## New features

* Added support for setting inputs that do not have an input binding (#232); furthermore, inputs set with event priority (e.g., `Shiny.setInputValue('key', 'value', {priority: 'event'})`) are also supported (#239).

* Added support for triggering snapshots from the keyboard (by pressing Ctrl-Shift-S or Command-Shift-S) while recording tests with `recordTest()` (#240).

* `recordTest()` gains a `debug` argument for displaying (`"shiny_console"`, `"browser"`, and/or `"shinytest`) logs into the R console (#146). When these logs are displayed, they use `format.shinytest_logs()` with `short = TRUE` which suppress the timestamp and level.

## Bug fixes

* Recording a test that produces an input value with an escape character, '\', no longer results in error (#241).

## Improvements

* `ShinyDriver` now passes the current `RNGkind()` to the background R process that serves up the app being tested. This allows for better control over randomness across mutliple versions of R with different `RNGkind()` defaults (e.g., 3.5 and 3.6)

1.3.0
=====

* First public release
