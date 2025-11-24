# Privacy-Preserving Data Anonymization with privacyR

## Introduction

The `privacyR` package helps you anonymize sensitive data in healthcare
and research datasets. It provides tools to protect patient privacy
while keeping your data useful for analysis.

## Installation

``` r
# Install from CRAN
install.packages("privacyR")
```

## Basic Usage

### Anonymizing Patient Identifiers

Anonymize patient IDs while keeping referential integrity (same IDs get
the same anonymized value):

``` r
library(privacyR)

# Original patient IDs
patient_ids <- c("P001", "P002", "P003", "P001", "P002")
print(patient_ids)
#> [1] "P001" "P002" "P003" "P001" "P002"

# Anonymize IDs
anonymized_ids <- anonymize_id(patient_ids, seed = 123)
print(anonymized_ids)
#>          P001          P002          P003          P001          P002 
#> "ID_uhjsB46B" "ID_4cQBb8Pk" "ID_meDL69Fd" "ID_uhjsB46B" "ID_4cQBb8Pk"

# Note: Same original IDs map to same anonymized IDs
```

### Anonymizing Patient Names

``` r
# Original names
names <- c("John Doe", "Jane Smith", "Bob Johnson", "John Doe")
print(names)
#> [1] "John Doe"    "Jane Smith"  "Bob Johnson" "John Doe"

# Anonymize names
anonymized_names <- anonymize_names(names, seed = 123)
print(anonymized_names)
#>           John Doe         Jane Smith        Bob Johnson           John Doe 
#> "Patient_NDg84Pt8" "Patient_ufNUJoZm" "Patient_ADANaKPi" "Patient_NDg84Pt8"
```

### Anonymizing Dates

Two methods are available: shifting or rounding.

#### Date Shifting

Shifting moves all dates by the same amount, preserving relative time
differences:

``` r
# Original dates
dates <- as.Date(c("2020-01-15", "2020-03-20", "2020-06-10"))
print(dates)
#> [1] "2020-01-15" "2020-03-20" "2020-06-10"

# Shift dates
shifted_dates <- anonymize_dates(dates, method = "shift", seed = 123)
print(shifted_dates)
#> [1] "2020-03-04" "2020-05-08" "2020-07-29"

# Relative differences are preserved
diff_original <- as.numeric(dates[2] - dates[1])
diff_shifted <- as.numeric(shifted_dates[2] - shifted_dates[1])
cat("Original difference:", diff_original, "days\n")
#> Original difference: 65 days
cat("Shifted difference:", diff_shifted, "days\n")
#> Shifted difference: 65 days
```

#### Date Rounding

Rounding reduces precision by grouping dates into buckets (day, week,
month, year, etc.):

``` r
# Round to month
rounded_month <- anonymize_dates(dates, method = "round", 
                                 granularity = "month", seed = 123)
print(rounded_month)
#> [1] "2020-01-01" "2020-03-01" "2020-06-01"

# Round to year
rounded_year <- anonymize_dates(dates, method = "round", 
                                granularity = "year", seed = 123)
print(rounded_year)
#> [1] "2020-01-01" "2020-01-01" "2020-01-01"
```

### Anonymizing Locations

``` r
# Original locations
locations <- c("New York, NY", "Los Angeles, CA", "Chicago, IL", 
               "New York, NY")
print(locations)
#> [1] "New York, NY"    "Los Angeles, CA" "Chicago, IL"     "New York, NY"

# Generalize locations
generalized <- anonymize_locations(locations, method = "generalize", seed = 123)
print(generalized)
#>        New York, NY     Los Angeles, CA         Chicago, IL        New York, NY 
#> "Location_ggyQKpzW" "Location_hybAy7Aq" "Location_DpYfTU6h" "Location_ggyQKpzW"

# Or remove locations entirely
removed <- anonymize_locations(locations, method = "remove", seed = 123)
print(removed)
#> [1] "[Location Removed]" "[Location Removed]" "[Location Removed]"
#> [4] "[Location Removed]"
```

## Working with Data Frames

The
[`anonymize_dataframe()`](https://vikrant31.github.io/privacyR/reference/anonymize_dataframe.md)
function provides a convenient way to anonymize entire data frames:

``` r
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
#> [1] "Original data:"
print(patient_data)
#>   patient_id        name        dob admission_date        location    diagnosis
#> 1       P001    John Doe 1980-01-15     2020-01-10    New York, NY Hypertension
#> 2       P002  Jane Smith 1975-03-20     2020-02-15 Los Angeles, CA     Diabetes
#> 3       P003 Bob Johnson 1990-06-10     2020-03-20     Chicago, IL Hypertension
#> 4       P001    John Doe 1980-01-15     2020-01-10    New York, NY Hypertension
#>   age
#> 1  40
#> 2  45
#> 3  30
#> 4  40

# Anonymize the entire data frame
anonymized_data <- anonymize_dataframe(patient_data, seed = 123)

print("\nAnonymized data:")
#> [1] "\nAnonymized data:"
print(anonymized_data)
#>    patient_id             name        dob admission_date          location
#> 1 ID_yy4R3rcM Patient_az6MEMKn 1980-10-20     2020-10-15 Location_j5VxZULh
#> 2 ID_wegx46wW Patient_VrFXRGmZ 1975-12-24     2020-11-20 Location_DDYWM3yf
#> 3 ID_2wEutqA2 Patient_ipQ2Y8Di 1991-03-16     2020-12-24 Location_xW5ux6EG
#> 4 ID_yy4R3rcM Patient_az6MEMKn 1980-10-20     2020-10-15 Location_j5VxZULh
#>      diagnosis   age
#> 1 Hypertension 40-49
#> 2     Diabetes 40-49
#> 3 Hypertension 30-39
#> 4 Hypertension 40-49
```

### Auto-detection

By default,
[`anonymize_dataframe()`](https://vikrant31.github.io/privacyR/reference/anonymize_dataframe.md)
automatically detects columns based on naming patterns and data types:

``` r
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
```

## Best Practices

1.  **Seeds and reproducibility**:

    - The `seed` parameter is optional (default: `NULL`). When
      `seed = NULL`, the package still maintains referential integrity
      using a deterministic hash-based approach, so same inputs always
      produce same outputs.
    - For explicit reproducibility across sessions, provide a seed:

    ``` r
    anonymized <- anonymize_dataframe(data, seed = 12345)
    ```

    - **Note**: The package always restores your R session’s random
      number generator state after anonymization, so your random number
      generation is never affected.

2.  **Referential integrity** is maintained automatically - same
    original values get the same anonymized values, which preserves
    relationships in your data. This works even when `seed = NULL`.

3.  **Date anonymization**:

    - Use “shift” to preserve relative time differences
    - Use “round” to reduce precision (e.g., month-year format)

4.  **Location anonymization**:

    - Use “generalize” to keep some location info
    - Use “remove” when location is too sensitive

5.  **Validate your results** - make sure anonymized data still works
    for your analysis.

## Privacy Considerations

Keep in mind:

- Complete anonymization is difficult to achieve
- You may need additional privacy measures depending on your use case
- Consider consulting privacy experts for sensitive data
- Review relevant regulations (HIPAA, GDPR, etc.) for your jurisdiction

## Getting Help

For more information, see the package documentation:

``` r
?anonymize_dataframe
help(package = "privacyR")
```
