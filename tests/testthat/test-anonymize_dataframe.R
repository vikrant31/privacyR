test_that("anonymize_dataframe works with basic data frame", {
  patient_data <- data.frame(
    patient_id = c("P001", "P002", "P003"),
    name = c("John Doe", "Jane Smith", "Bob Johnson"),
    dob = as.Date(c("1980-01-15", "1975-03-20", "1990-06-10")),
    location = c("New York, NY", "Los Angeles, CA", "Chicago, IL"),
    diagnosis = c("A", "B", "A")
  )
  result <- anonymize_dataframe(patient_data, seed = 123)
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 3)
  expect_equal(ncol(result), 5)
})

test_that("anonymize_dataframe auto-detects columns", {
  patient_data <- data.frame(
    patient_id = c("P001", "P002"),
    patient_name = c("John Doe", "Jane Smith"),
    date_of_birth = as.Date(c("1980-01-15", "1975-03-20")),
    city = c("New York", "Los Angeles")
  )
  result <- anonymize_dataframe(patient_data, auto_detect = TRUE, seed = 123)
  # Check that columns were anonymized
  expect_false(any(result$patient_id == patient_data$patient_id))
  expect_false(any(result$patient_name == patient_data$patient_name))
})

test_that("anonymize_dataframe respects manual column specification", {
  patient_data <- data.frame(
    patient_id = c("P001", "P002"),
    name = c("John Doe", "Jane Smith"),
    other_col = c("A", "B")
  )
  result <- anonymize_dataframe(patient_data, id_cols = "patient_id",
                                name_cols = NULL, auto_detect = FALSE, seed = 123)
  expect_false(any(result$patient_id == patient_data$patient_id))
  expect_equal(result$name, patient_data$name)  # Should not be anonymized
})

test_that("anonymize_dataframe handles date_method parameter", {
  patient_data <- data.frame(
    dob = as.Date(c("1980-01-15", "1975-03-20"))
  )
  result_shift <- anonymize_dataframe(patient_data, date_cols = "dob",
                                      date_method = "shift", seed = 123)
  result_round <- anonymize_dataframe(patient_data, date_cols = "dob",
                                      date_method = "round", seed = 123)
  expect_s3_class(result_shift$dob, "Date")
  expect_s3_class(result_round$dob, "Date")
})

test_that("anonymize_dataframe handles location_method parameter", {
  patient_data <- data.frame(
    location = c("New York, NY", "Los Angeles, CA")
  )
  result_remove <- anonymize_dataframe(patient_data, location_cols = "location",
                                       location_method = "remove", seed = 123)
  result_generalize <- anonymize_dataframe(patient_data, location_cols = "location",
                                           location_method = "generalize", seed = 123)
  expect_true(all(result_remove$location == "[Location Removed]"))
  expect_false(any(result_generalize$location == patient_data$location))
})

test_that("anonymize_dataframe throws error for non-data.frame input", {
  expect_error(anonymize_dataframe(list(a = 1, b = 2)), "data must be a data frame")
})

