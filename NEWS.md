1.3.0.9001
==========

## New features

* Added support for setting inputs that do not have an input binding (#232); furthermore, inputs set with event priority (e.g., `Shiny.setInputValue('key', 'value', {priority: 'event'})`) are also supported (#239).

## Bug fixes

* Recording a test that produces an input value with an escape character, '\', no longer results in error (#241).

1.3.0
=====

* First public release
