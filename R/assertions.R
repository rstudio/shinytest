
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
