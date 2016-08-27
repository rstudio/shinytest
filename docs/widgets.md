
# Inputs

## Action button (`actionButton`)

```
<button id="#" type="button" class="shiny-bound-button" ...
```

## Single checkbox (`checkboxInput`)

```
<input id="#" type="checkbox" class="shiny-bound-input" ...
```

## Checkbox group (`checkboxGroupInput`)

```
<div id="#"
     class="shiny-input-container shiny-input-checkboxgroup shiny-bound-input"
  <div class="shiny-options-group">
    <div class="checkbox"><label><input type="checkbox" name="#" id="#1" ...
    <div class="checkbox"><label><input type="checkbox" name="#" id="#2" ...
    <div class="checkbox"><label><input type="checkbox" name="#" id="#3" ...
    ...
```

## Date input (`dateInput`)

```
<div id="#"
     class="shiny-date-input shiny-input-container shiny-bound-input" ...
  <input type="text" class="datepicker" ...
```

## Date range (`dateRangeInput`)

```
<div id="#"
     class="shiny-date-range-input shiny-input-container shiny-bound-input ...
  <div class="input-daterange input-group"
    <input type="text" ...
    <input type="text" ...
```

## File input (`fileInput`)

```
<input id="#" type="file" class="shiny-bound-input" ...
```

## Numeric input (`numericInput`)

```
<input id="#" type="number" class="shiny-bound-input" ...
```

## Radio buttons (`radioButtons`)

```
<div id="#"
     class="shiny-input-radiogroup shiny-input-container shiny-bound-input" ...
  <div class="shiny-options-group">
    <div class="radio"><label><input type="radio" id="#1" ...
    <div class="radio"><label><input type="radio" id="#2" ...
    <div class="radio"><label><input type="radio" id="#3" ...
    ...
```

## Select box (`selectInput`)

Somewhat messy. The id is apparently on the previous element, at least
if selectize is used:

```
<div>
  <select id="#" class="shiny-bound-input" style="display:none;" ...
  <div class="selectize-control">
    <div class="selectize-input">
      <div class="item" data-value="1">Chice 1</dic>
      <input type="text" ...
```

## Submit button (`submitButton`)

This one does not really have an ID. It is just a `<button type="submit">`
within a form.

## Slider (`sliderInput`)

Also a somewhat strange one.

```
<div class="shiny-input-container">
  <span class="irs" ...
    <span class="irs">
      <span class="irs-single" ...>32</span>
    </span>
  </span>
  <input class="js-range-slider" id="#" ...
```

## Slider range (`sliderInput`)

```
<div class="shiny-input-container">
  <span class="irs" ...
    <span class="irs">
	  <span class="irs-from" ...>25</span>
	  <span class="irs-to" ...>75</span>
    </span>
  </span>
  <input class="js-range-slider" id="#"
```

## Text input (`textInput`)

```
<input id="#" type="text" class="shiny-bound-input" ...
```

## Password input (`passwordInput`)

```
<input id="#" type="password" ...
```

# Output

## HTML output (`htmlOutput`)

But it might not be a `<div>`, actually, this can be customized.
The class and the id should still hold.

```
<div id="#" class="shiny-html-output">The HTML is here</div>
```

## Plot output (`plotOutput`)

```
<div id="#" class="shiny-plot-output shiny-bound-output" ...
  <img src="data:image/...
```

## Table output (`tableOutput`)

The table itself is not visible.

```
<div id="#" class="datatables shiny-bound-output"
  <div class="dataTables_wrapper" ...
    ...
    <table class="dataTable"
```

## Text output (`textOutput`)

```
<div id="#" class="shiny-text-output" ...>Text</div>
```

## Verbatim text output (`verbatimTextOutput`)

```
<pre id="#" class="shiny-text-output shiny-bound-output">[1] 0</pre>
```

## Download button

TODO

## Progress bars (Progress, withProgress)

TODO
