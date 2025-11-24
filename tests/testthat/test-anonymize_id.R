test_that("anonymize_id works with character vectors", {
  ids <- c("P001", "P002", "P003")
  result <- anonymize_id(ids, seed = 123)
  expect_type(result, "character")
  expect_length(result, 3)
  expect_false(any(result == ids))
})

test_that("anonymize_id maintains referential integrity", {
  ids <- c("P001", "P002", "P001", "P003")
  result <- anonymize_id(ids, seed = 123)
  # Same original IDs should map to same anonymized IDs
  expect_equal(result[1], result[3])
  expect_false(result[1] == result[2])
})

test_that("anonymize_id handles NA values", {
  ids <- c("P001", NA, "P002", "P001")
  result <- anonymize_id(ids, seed = 123)
  expect_true(is.na(result[2]))
  expect_equal(result[1], result[4])
})

test_that("anonymize_id works with numeric vectors", {
  ids <- c(1, 2, 3, 1)
  result <- anonymize_id(ids, seed = 123)
  expect_type(result, "character")
  expect_equal(result[1], result[4])
})

test_that("anonymize_id respects prefix parameter", {
  ids <- c("P001", "P002")
  result <- anonymize_id(ids, prefix = "PAT", seed = 123)
  expect_true(all(grepl("^PAT", result)))
})

