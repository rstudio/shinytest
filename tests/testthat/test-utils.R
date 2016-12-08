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
