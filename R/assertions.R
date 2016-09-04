
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
