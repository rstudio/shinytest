#' Class for a client web browser visiting a Shiny app
#'
#' @keywords internal
shinyapp_client <- R6Class("shinyapp_client",
  public = list(
    initialize = function(shiny_url, load_timeout,
      phantom_debug_level = c("INFO", "ERROR", "WARN", "DEBUG"))
      client_initialize(self, private, shiny_url, load_timeout,
                        match.arg(phantom_debug_level)),
    
    get_value = function(name, iotype = c("auto", "input", "output"))
      client_get_value(self, private, name, match.arg(iotype)),

    set_value = function(name, value, iotype = c("auto", "input", "output"))
      client_set_value(self, private, name, value, match.arg(iotype)),

    send_keys = function(name = NULL, keys, client = 1)
      client_send_keys(self, private, name, keys),

    set_window_size = function(width, height, client = 1)
      client_set_window_size(self, private, width, height),

    get_window_size = function(client = 1)
      client_get_window_size(self, private),
    
    ## Debugging

    get_debug_log = function(type = c("all", shinyapp$debug_log_types))
      client_get_debug_log(self, private, match.arg(type, several.ok = TRUE)),

    ## These are just forwarded to the webdriver session

    get_url = function()
      client_get_url(self, private),

    go_back = function()
      client_go_back(self, private),

    refresh = function()
      client_refresh(self, private),

    get_title = function()
      client_get_title(self, private),

    get_source = function()
      client_get_source(self, private),

    take_screenshot = function(file = NULL)
      client_take_screenshot(self, private, file),

    find_element = function(css = NULL, link_text = NULL,
      partial_link_text = NULL, xpath = NULL)
      client_find_element(self, private, css, link_text, partial_link_text,
                          xpath),

    find_elements = function(css = NULL, link_text = NULL,
      partial_link_text = NULL, xpath = NULL)
      client_find_elements(self, private, css, link_text, partial_link_text,
                           xpath),

    wait_for = function(expr, check_interval = 100, timeout = 3000)
      client_wait_for(self, private, expr, check_interval, timeout),

    list_input_widgets = function()
      client_list_input_widgets(self, private),

    list_output_widgets = function()
      client_list_output_widgets(self, private),

    check_unique_widget_names = function()
      client_check_unique_widget_names(self, private),

    ## Main methods

    find_widget = function(name, iotype = c("auto", "input", "output"))
      client_find_widget(self, private, name, match.arg(iotype)),

    expect_update = function(output, ..., timeout = 3000,
      iotype = c("auto", "input", "output"))
      client_expect_update(self, private, output, ..., timeout = timeout,
                           iotype = match.arg(iotype))
  ),
  
  private = list(
    session = NULL,                     # webdriver object
    phantom_port = NULL,
    phantom_process = NULL,             # process object
    
    start_phantomjs = function(debug_level)
      client_start_phantomjs(self, private, debug_level)
  )
)



client_get_value <- function(self, private, name, iotype, client) {
  "!DEBUG client_get_value `name` (`iotype`)"
  self$find_widget(name, iotype)$get_value()
}

client_set_value <- function(self, private, name, value, iotype) {
  "!DEBUG client_set_value `name`"
  self$find_widget(name, iotype)$set_value(value)
  invisible(self)
}

client_send_keys <- function(self, private, name, keys) {
  "!DEBUG client_send_keys `name`"
  self$find_widget(name)$send_keys(keys)
  invisible(self)
}

client_get_window_size <- function(self, private) {
  "!DEBUG client_get_window_size"
  private$session$get_window()$get_size()
}

client_set_window_size <- function(self, private, width, height) {
  "!DEBUG client_set_window_size `width`x`height`"
  private$session$get_window()$set_size(width, height)
  invisible(self)
}

client_stop <- function(self, private) {
  "!DEBUG client_stop"
  private$shiny_process$kill()
  private$phantom_process$kill()
  private$state <- "stopped"
  invisible(self)
}

client_wait_for <- function(self, private, expr, check_interval, timeout) {
  "!DEBUG client_wait_for"
  private$session$wait_for(expr, check_interval, timeout)
}

client_list_input_widgets <- function(self, private) {
  "!DEBUG client_list_input_widgets"
  elements <- self$find_elements(css = ".shiny-bound-input")
  vapply(elements, function(e) e$get_attribute("id"), "")
}

client_list_output_widgets <- function(self, private) {
  "!DEBUG client_list_output_widgets"
  elements <- self$find_elements(css = ".shiny-bound-output")
  vapply(elements, function(e) e$get_attribute("id"), "")
}

client_check_unique_widget_names <- function(self, private) {
  "!DEBUG client_check_unique_widget_names"
  inputs <- self$list_input_widgets()
  outputs <- self$list_output_widgets()

  check <- function(what, ids) {
    sel <- paste0("#", ids, collapse = ",")
    widgets <- private$session$find_elements(css = sel)
    ids <- vapply(widgets, function(e) e$get_attribute("id"), "")
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
