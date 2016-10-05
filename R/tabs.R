
## We store the <ul> element of the tabset, not the enclosing <div>

app_get_tabset <- function(self, private, id) {
  el <- private$web$find_element(paste0("#", id))
  tabset$new(el, self, private)
}

app_get_tabsets <- function(self, private) {
  els <- private$web$find_elements(".tabbable ul")
  lapply(els, function(e) tabset$new(e, self, private))
}

#' Class to manage tabsets of a Shiny app
#'
#' @section Usage:
#' \preformatted{ts <- app$get_tabset(id)
#' tslist <- app$get_tabsets()
#'
#' ts$list_tabs()
#' ts$get_value()
#' ts$set_value(id)
#' }
#'
#' @section Arguments:
#' \describe{
#'   \item{app}{A \code{\link{shinyapp}} object.}
#'   \item{ts}{A \code{tabset} object.}
#'   \item{tslist}{A list of \code{tabset} objects.}
#'   \item{id}{For \code{app$get_tabset} a string, the id of the
#'     \code{tabsetPanel} in Shiny. For \code{ts$set_value} the value
#'     (or title if value is not given) of the \code{tabPanel} in Shiny.}
#' }
#'
#' @section Details:
#'
#' A \code{tabset} object represents a Shiny \code{tabsetPanel}.
#'
#' \code{app$get_tabset()} creates a single \code{tabset} object and can
#' be used for tabset panels that have an id.
#'
#' \code{app$get_tabsets()} returns all tabset, regardless of whether they
#' have ids or not.
#'
#' \code{ts$list_tabs()} lists all tab values (or titles if no values are
#' given in the Shiny app) of a tabset.
#'
#' \code{ts$get_value()} returns the value (or title if no value was
#' given in the Shiny app) of a tabset.
#'
#' \code{ts$set_value()} sets the active tab to the one specified
#' by a value (or title if no value was given in the Shiny app).
#'
#' @name tabset
NULL

#' @importFrom R6 R6Class

tabset <- R6Class(
  "tabset",

  public = list(

    initialize = function(element, app, app_private)
      tabset_initialize(self, private, element, app, app_private),

    list_tabs = function()
      tabset_list_tabs(self, private),

    get_value = function()
      tabset_get_value(self, private),

    set_value = function(id)
      tabset_set_value(self, private, id)
  ),

  private = list(
    element = NULL,                      # HTML element
    app = NULL,                          # reference to the parent app
    app_private = NULL                   # the private env of the app
  )
)

tabset_initialize <- function(self, private, element, app, app_private) {
  private$element <- element
  private$app <- app
  private$app_private <- app_private
  invisible(self)
}

tabset_list_tabs <- function(self, private) {
  tabs <- private$element$find_elements("li a")
  vapply(tabs, function(t) t$get_data("value"), "")
}

tabset_get_value <- function(self, private) {
  active <- private$element$find_elements("li.active a")
  if (length(active) == 0) {
    NA_character_
  } else if (length(active) > 1) {
    warning("Multiple active tabs for a tabset")
    vapply(active, function(a) a$get_data("value"), "")
  } else {
    active[[1]]$get_data("value")
  }
}

tabset_set_value <- function(self, private, id) {
  css <- paste0('li a[data-value="', id, '"]')
  el <- private$element$find_element(css)
  el$click()
  invisible(self)
}
