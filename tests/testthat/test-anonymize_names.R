test_that("anonymize_names works with character vectors", {
  names <- c("John Doe", "Jane Smith", "Bob Johnson")
  result <- anonymize_names(names, seed = 123)
  expect_type(result, "character")
  expect_length(result, 3)
  expect_false(any(result == names))
})

test_that("anonymize_names maintains referential integrity", {
  names <- c("John Doe", "Jane Smith", "John Doe")
  result <- anonymize_names(names, seed = 123)
  expect_equal(result[1], result[3])
})

test_that("anonymize_names handles NA values", {
  names <- c("John Doe", NA, "Jane Smith")
  result <- anonymize_names(names, seed = 123)
  expect_true(is.na(result[2]))
})

test_that("anonymize_names respects prefix parameter", {
  names <- c("John Doe", "Jane Smith")
  result <- anonymize_names(names, prefix = "PAT", seed = 123)
  expect_true(all(grepl("^PAT", result)))
})

