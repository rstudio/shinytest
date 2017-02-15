
#' @importFrom assertthat assert_that on_failure<-

is_string <- function(x) {
  is.character(x) && length(x) == 1 && !is.na(x)
}

on_failure(is_string) <- function(call, env) {
  paste0(deparse(call$x), " is not a string (length 1 character)")
}

is_host <- function(x) {
  assert_that(is_string(x))
}

on_failure(is_host) <- function(call, env) {
  paste0(deparse(call$x), " does not look like a host name")
}

is_count <- function(x) {
  is.numeric(x) && length(x) == 1 && as.integer(x) == x
}

on_failure(is_count) <- function(call, env) {
  paste0(deparse(call$x), " is not a count (length 1 integer)")
}

is_port <- function(x) {
  assert_that(is_count(x))
}

on_failure(is_port) <- function(call, env) {
  paste0(deparse(call$x), " is not a port number")
}

is_url_path <- function(x) {
  assert_that(is_string(x) && grepl("^/", x))
}

on_failure(is_url_path) <- function(call, env) {
  paste0(deparse(call$x), " is not a path for a URL")
}

is_all_named <- function(x) {
  length(names(x)) == length(x) && all(names(x) != "")
}

on_failure(is_all_named) <- function(call, env) {
  paste0(deparse(call$x), " has entries without names")
}

is_date <- function(x) {
  inherits(x, "Date")
}

on_failure(is_date) <- function(call, env) {
  paste0(deparse(call$x), " is not a date or vector of dates")
}

is_date_range <- function(x) {
  assert_that(is_date(x))
  length(x) == 2
}

on_failure(is_date_range) <- function(call, env) {
  paste0(deparse(call$x), " is not a date range (length 2 date vector)")
}

is_scalar_number <- function(x) {
  is.numeric(x) && length(x) == 1 && ! is.na(x)
}

on_failure(is_scalar_number) <- function(call, env) {
  paste0(deparse(call$x), " is not a scalar number")
}

is_numeric <- function(x, .length = 1) {
  is.numeric(x) && length(x) == .length &&  all(! is.na(x))
}

on_failure(is_numeric) <- function(call, env) {
  paste0(
    deparse(call$x),
    " is not length ", env$.length, " numeric or has missing values"
  )
}

as_debug <- function(x) {
  assert_that(is.character(x))
  x <- unique(x)

  miss <- ! x %in% c(ShinyDriver$debugLogTypes, c("all", "none"))

  if (any(miss)) {
    stop("Unknown debug types: ", paste(x[miss], collapse = ", "))
  }

  if ("all" %in% x) x <- ShinyDriver$debugLogTypes
  if ("none" %in% x) x <- character()

  x
}
