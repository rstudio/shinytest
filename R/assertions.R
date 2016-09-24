
assert_string <- function(x) {
  stopifnot(
    is.character(x),
    length(x) == 1,
    !is.na(x)
  )
  x
}

assert_host <- assert_string

assert_integerish <- function(x) {
  stopifnot(
    is.numeric(x),
    length(x) == 1,
    as.integer(x) == x
  )
  x
}

assert_port <- assert_integerish

assert_count <- assert_integerish

assert_character <- function(x) {
  stopifnot(is.character(x))
}

assert_all_named <- function(x) {
  stopifnot(
    !is.null(names(x)),
    all(names(x) != "")
  )
}

assert_date <- function(x) {
  stopifnot(inherits(x, "Date"))
}

assert_date_range <- function(x) {
  assert_date(x)
  stopifnot(length(x) == 2)
}

assert_scalar_number <- function(x) {
  stopifnot(
    is.numeric(x),
    length(x) == 1,
    ! is.na(x)
  )
}

assert_numeric <- function(x, .length = 1) {
  stopifnot(
    is.numeric(x),
    length(x) == .length,
    all(! is.na(x))
  )
}

assert_debug <- function(x) {
  assert_character(x)
  x <- unique(x)

  miss <- ! x %in% c(shinyapp$debug_log_types, c("all", "none"))

  if (any(miss)) {
    stop("Unknown debug types: ", paste(x[miss], collapse = ", "))
  }

  if ("all" %in% x) x <- shinyapp$debug_log_types
  if ("none" %in% x) x <- character()

  x
}
