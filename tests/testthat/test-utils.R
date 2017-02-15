context("utils")

test_that("rel_path works", {
  # Basic tests
  expect_identical(rel_path("/a/b/c", "/a/b"), "c")
  expect_identical(rel_path("c", "/a/b"), "c")
  expect_identical(rel_path("/a/b/c", "/a/b/c"), ".")

  # Make sure repeating paths aren't removed
  expect_identical(rel_path("/a/b/a/b", "/a/b"), "a/b")
  expect_identical(rel_path("/a/a", "/a"), "a")

  # Normalizing paths
  expect_identical(
    rel_path(file.path(getwd(), "..", basename(getwd())), getwd()),
    "."
  )
  # Normalization doesn't work for nonexistent files. It would be nice if path
  # normalization worked in these cases, but it doesn't.
  expect_identical(
    rel_path(file.path(getwd(), "..", basename(getwd()), "a"), getwd()),
    file.path("..", basename(getwd()), "a")
  )
})



test_that("parse_url", {
  expect_identical(
    parse_url("http://a.b.com"),
    list(protocol = "http", host = "a.b.com", port = "", path = "")
  )
  expect_identical(
    parse_url("https://a.b.com/"),
    list(protocol = "https", host = "a.b.com", port = "", path = "/")
  )
  expect_identical(
    parse_url("http://a.b.com:1020"),
    list(protocol = "http", host = "a.b.com", port = "1020", path = "")
  )
  expect_identical(
    parse_url("http://a.b.com:1020/"),
    list(protocol = "http", host = "a.b.com", port = "1020", path = "/")
  )
  expect_identical(
    parse_url("http://a.b.com:1020/abc"),
    list(protocol = "http", host = "a.b.com", port = "1020", path = "/abc")
  )
  expect_identical(
    parse_url("http://a.b.com:1020/abc/"),
    list(protocol = "http", host = "a.b.com", port = "1020", path = "/abc/")
  )
  expect_identical(
    parse_url("http://a.b.com/abc/"),
    list(protocol = "http", host = "a.b.com", port = "", path = "/abc/")
  )
  expect_identical(
    parse_url("http://a.b.com/abc/"),
    list(protocol = "http", host = "a.b.com", port = "", path = "/abc/")
  )

  # Malformed URLs, or non-http/https protocol
  expect_error(parse_url("http:/a.b.com/"))
  expect_error(parse_url("http://a.b.com:12ab/"))
  expect_error(parse_url("ftp://a.b.com/"))
})
