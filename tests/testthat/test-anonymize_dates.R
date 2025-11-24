test_that("anonymize_dates works with Date objects", {
  dates <- as.Date(c("2020-01-15", "2020-03-20", "2020-06-10"))
  result <- anonymize_dates(dates, method = "shift", seed = 123)
  expect_s3_class(result, "Date")
  expect_length(result, 3)
})

test_that("anonymize_dates shift method preserves relative differences", {
  dates <- as.Date(c("2020-01-15", "2020-01-20"))
  result <- anonymize_dates(dates, method = "shift", seed = 123)
  diff_original <- as.numeric(dates[2] - dates[1])
  diff_anonymized <- as.numeric(result[2] - result[1])
  expect_equal(diff_original, diff_anonymized)
})

test_that("anonymize_dates round method works", {
  dates <- as.Date(c("2020-01-15", "2020-03-20"))
  result <- anonymize_dates(dates, method = "round", granularity = "month", seed = 123)
  expect_s3_class(result, "Date")
  # Check that dates are rounded to first of month
  expect_equal(lubridate::day(result[1]), 1)
  expect_equal(lubridate::day(result[2]), 1)
})

test_that("anonymize_dates works with POSIXct", {
  dates <- as.POSIXct(c("2020-01-15 10:30:00", "2020-03-20 14:45:00"))
  result <- anonymize_dates(dates, method = "shift", seed = 123)
  expect_s3_class(result, "Date")
})

test_that("anonymize_dates works with character dates", {
  dates <- c("2020-01-15", "2020-03-20")
  result <- anonymize_dates(dates, method = "shift", seed = 123)
  expect_s3_class(result, "Date")
})

test_that("anonymize_dates handles invalid granularity", {
  dates <- as.Date(c("2020-01-15", "2020-03-20"))
  expect_error(
    anonymize_dates(dates, method = "round", granularity = "invalid"),
    "granularity must be one of"
  )
})

