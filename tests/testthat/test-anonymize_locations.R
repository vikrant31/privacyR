test_that("anonymize_locations remove method works", {
  locations <- c("New York, NY", "Los Angeles, CA")
  result <- anonymize_locations(locations, method = "remove", seed = 123)
  expect_true(all(result == "[Location Removed]"))
})

test_that("anonymize_locations generalize method works", {
  locations <- c("New York, NY", "Los Angeles, CA", "Chicago, IL")
  result <- anonymize_locations(locations, method = "generalize", seed = 123)
  expect_type(result, "character")
  expect_length(result, 3)
  expect_false(any(result == locations))
})

test_that("anonymize_locations maintains referential integrity", {
  locations <- c("New York, NY", "Los Angeles, CA", "New York, NY")
  result <- anonymize_locations(locations, method = "generalize", seed = 123)
  expect_equal(result[1], result[3])
})

test_that("anonymize_locations handles NA values", {
  locations <- c("New York, NY", NA, "Los Angeles, CA")
  result <- anonymize_locations(locations, method = "generalize", seed = 123)
  expect_true(is.na(result[2]))
})

