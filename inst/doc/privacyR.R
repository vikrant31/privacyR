## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 7,
  fig.height = 5
)

## ----install, eval = FALSE----------------------------------------------------
# # Install from CRAN
# install.packages("privacyR")

## ----anonymize_id-------------------------------------------------------------
library(privacyR)

# Original patient IDs
patient_ids <- c("P001", "P002", "P003", "P001", "P002")
print(patient_ids)

# Anonymize IDs
anonymized_ids <- anonymize_id(patient_ids, seed = 123)
print(anonymized_ids)

# Note: Same original IDs map to same anonymized IDs

## ----anonymize_names----------------------------------------------------------
# Original names
names <- c("John Doe", "Jane Smith", "Bob Johnson", "John Doe")
print(names)

# Anonymize names
anonymized_names <- anonymize_names(names, seed = 123)
print(anonymized_names)

## ----anonymize_dates_shift----------------------------------------------------
# Original dates
dates <- as.Date(c("2020-01-15", "2020-03-20", "2020-06-10"))
print(dates)

# Shift dates
shifted_dates <- anonymize_dates(dates, method = "shift", seed = 123)
print(shifted_dates)

# Relative differences are preserved
diff_original <- as.numeric(dates[2] - dates[1])
diff_shifted <- as.numeric(shifted_dates[2] - shifted_dates[1])
cat("Original difference:", diff_original, "days\n")
cat("Shifted difference:", diff_shifted, "days\n")

## ----anonymize_dates_round----------------------------------------------------
# Round to month
rounded_month <- anonymize_dates(dates, method = "round", 
                                 granularity = "month", seed = 123)
print(rounded_month)

# Round to year
rounded_year <- anonymize_dates(dates, method = "round", 
                                granularity = "year", seed = 123)
print(rounded_year)

## ----anonymize_locations------------------------------------------------------
# Original locations
locations <- c("New York, NY", "Los Angeles, CA", "Chicago, IL", 
               "New York, NY")
print(locations)

# Generalize locations
generalized <- anonymize_locations(locations, method = "generalize", seed = 123)
print(generalized)

# Or remove locations entirely
removed <- anonymize_locations(locations, method = "remove", seed = 123)
print(removed)

## ----anonymize_dataframe------------------------------------------------------
# Create sample patient data
patient_data <- data.frame(
  patient_id = c("P001", "P002", "P003", "P001"),
  name = c("John Doe", "Jane Smith", "Bob Johnson", "John Doe"),
  dob = as.Date(c("1980-01-15", "1975-03-20", "1990-06-10", "1980-01-15")),
  admission_date = as.Date(c("2020-01-10", "2020-02-15", "2020-03-20", "2020-01-10")),
  location = c("New York, NY", "Los Angeles, CA", "Chicago, IL", "New York, NY"),
  diagnosis = c("Hypertension", "Diabetes", "Hypertension", "Hypertension"),
  age = c(40, 45, 30, 40)
)

print("Original data:")
print(patient_data)

# Anonymize the entire data frame
anonymized_data <- anonymize_dataframe(patient_data, seed = 123)

print("\nAnonymized data:")
print(anonymized_data)

## ----auto_detect--------------------------------------------------------------
# The function automatically detects:
# - ID columns: patient_id, subject_id, etc.
# - Name columns: name, patient_name, etc.
# - Date columns: date, dob, admission_date, etc.
# - Location columns: location, address, city, etc.

# You can also manually specify columns
manual_anon <- anonymize_dataframe(
  patient_data,
  id_cols = "patient_id",
  name_cols = "name",
  date_cols = c("dob", "admission_date"),
  location_cols = "location",
  auto_detect = FALSE,
  seed = 123
)

## ----best_practices, eval = FALSE---------------------------------------------
# anonymized <- anonymize_dataframe(data, seed = 12345)

## ----help, eval = FALSE-------------------------------------------------------
# ?anonymize_dataframe
# help(package = "privacyR")

