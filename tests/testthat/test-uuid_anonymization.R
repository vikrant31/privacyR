test_that("anonymize_id works with UUID", {
  ids <- c("P001", "P002", "P003", "P001")
  result <- anonymize_id(ids, use_uuid = TRUE, seed = 123)
  expect_type(result, "character")
  expect_length(result, 4)
  expect_false(any(result == ids))
  # Referential integrity
  expect_equal(result[1], result[4])
  expect_false(result[1] == result[2])
  # UUID format (should have prefix and random part)
  expect_true(all(grepl("^ID_", result)))
})

test_that("anonymize_names works with UUID", {
  names <- c("John Doe", "Jane Smith", "Bob Johnson")
  result <- anonymize_names(names, use_uuid = TRUE, seed = 123)
  expect_type(result, "character")
  expect_length(result, 3)
  expect_false(any(result == names))
  # UUID format
  expect_true(all(grepl("^Patient_", result)))
})

test_that("anonymize_locations works with UUID", {
  locations <- c("New York, NY", "Los Angeles, CA", "Chicago, IL")
  result <- anonymize_locations(locations, method = "generalize", 
                                use_uuid = TRUE, seed = 123)
  expect_type(result, "character")
  expect_length(result, 3)
  expect_false(any(result == locations))
  # UUID format
  expect_true(all(grepl("^Location_", result)))
})

test_that("anonymize_dataframe works with UUID", {
  patient_data <- data.frame(
    patient_id = c("P001", "P002", "P003"),
    name = c("John Doe", "Jane Smith", "Bob Johnson"),
    dob = as.Date(c("1980-01-15", "1975-03-20", "1990-06-10")),
    location = c("New York, NY", "Los Angeles, CA", "Chicago, IL")
  )
  result <- anonymize_dataframe(patient_data, use_uuid = TRUE, seed = 123)
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 3)
  # IDs should be UUIDs
  expect_true(all(grepl("^ID_", result$patient_id)))
  # Names should be UUIDs
  expect_true(all(grepl("^Patient_", result$name)))
  # Dates should NOT be UUIDs (should be Date objects)
  expect_s3_class(result$dob, "Date")
})

test_that("different datasets get different UUIDs", {
  df1 <- data.frame(id = c("A1", "A2"), name = c("John", "Jane"))
  df2 <- data.frame(id = c("B1", "B2"), name = c("Bob", "Alice"))
  
  anon1 <- anonymize_dataframe(df1, use_uuid = TRUE, seed = 123)
  anon2 <- anonymize_dataframe(df2, use_uuid = TRUE, seed = 123)
  
  # Different datasets should get different UUIDs
  expect_false(all(anon1$id == anon2$id))
  expect_false(all(anon1$name == anon2$name))
})

test_that("dates are not affected by use_uuid parameter", {
  dates_df <- data.frame(
    dob = as.Date(c("2020-01-15", "2020-03-20")),
    patient_id = c("P1", "P2")
  )
  
  # With UUID
  result_uuid <- anonymize_dataframe(dates_df, use_uuid = TRUE,
                                     date_method = "round",
                                     date_granularity = "month_year",
                                     seed = 123)
  
  # Without UUID
  result_no_uuid <- anonymize_dataframe(dates_df, use_uuid = FALSE,
                                       date_method = "round",
                                       date_granularity = "month_year",
                                       seed = 123)
  
  # Dates should be the same regardless of UUID setting
  expect_equal(result_uuid$dob, result_no_uuid$dob)
  # But IDs should be different
  expect_false(all(result_uuid$patient_id == result_no_uuid$patient_id))
})

test_that("use_uuid parameter validation", {
  ids <- c("P001", "P002")
  expect_error(anonymize_id(ids, use_uuid = "invalid"), 
               "use_uuid must be a single logical value")
  expect_error(anonymize_id(ids, use_uuid = c(TRUE, FALSE)), 
               "use_uuid must be a single logical value")
})

