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

test_that("can find three styles of app", {
  expect_error(app_path(test_path("apps/foofability")), "doesn't exist")

  expect_equal(
    app_path(test_path("apps/click-me")),
    list(
      app = test_path("apps/click-me"),
      dir = test_path("apps/click-me")
    )
  )

  expect_equal(
    app_path(test_path("recorded_tests/rmd")),
    list(
      app = test_path("recorded_tests/rmd/doc.Rmd"),
      dir = test_path("recorded_tests/rmd")
    )
  )

  expect_equal(
    app_path(test_path("recorded_tests/rmd/doc.Rmd")),
    list(
      app = test_path("recorded_tests/rmd/doc.Rmd"),
      dir = test_path("recorded_tests/rmd")
    )
  )

  expect_error(app_path(test_path("apps/two-rmd")), "exactly one")
  expect_error(app_path(test_path("apps/two-rmd/doc1.Rmd")), "only one")

  expect_error(app_path(test_path("apps/user-error")), "boom")
})


test_that("app_path works with trailing slash", {
  expect_error(app_path("apps/stopApp/"), NA)
})
