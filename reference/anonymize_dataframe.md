# Anonymize Patient Data in a Data Frame

Main function to anonymize patient data in a data frame or data.table.
Automatically detects and anonymizes columns based on data types and
naming patterns, or you can manually specify columns. Different datasets
get different anonymized values for better privacy.

## Usage

``` r
anonymize_dataframe(
  data,
  id_cols = NULL,
  name_cols = NULL,
  date_cols = NULL,
  location_cols = NULL,
  age_cols = NULL,
  auto_detect = TRUE,
  detect_by_type = TRUE,
  date_method = "shift",
  date_granularity = "month",
  location_method = "generalize",
  age_method = "10year",
  use_uuid = TRUE,
  seed = NULL,
  dataset_specific = TRUE
)
```

## Arguments

- data:

  A data frame or data.table containing patient data

- id_cols:

  Character vector of column names containing patient IDs

- name_cols:

  Character vector of column names containing patient names

- date_cols:

  Character vector of column names containing dates

- location_cols:

  Character vector of column names containing locations

- age_cols:

  Character vector of column names containing ages

- auto_detect:

  Logical, if TRUE (default), automatically detects columns based on
  data types and common naming patterns

- detect_by_type:

  Logical, if TRUE (default), detects columns by their R data types
  (Date, character, etc.) in addition to name patterns

- date_method:

  Method for date anonymization: "shift" or "round" (default: "shift").
  Use "round" to enable granularity options including "month_year"
  (YYYYMM format).

- date_granularity:

  For date rounding (when date_method = "round"): "day", "week",
  "month", "month_year" (returns YYYYMM format, e.g., "202005"),
  "quarter", or "year" (default: "month")

- location_method:

  Method for location anonymization: "remove" or "generalize"

- age_method:

  Method for age anonymization: "10year" (default) uses 10-year buckets
  (0-9, 10-19, 20-29, ..., 80-89, 90+) for better research utility, or
  "hipaa" for HIPAA-compliant buckets (0-17, 18-64, 65-89, 90+)

- use_uuid:

  Logical, if TRUE uses short UUIDs for IDs, names, and locations
  instead of sequential identifiers (default: TRUE). Dates and ages are
  not affected.

- seed:

  An optional seed for reproducible anonymization. Different datasets
  will still get different anonymized values even with the same seed.

- dataset_specific:

  Logical, if TRUE (default), generates dataset-specific seeds so
  different datasets get different anonymized values

## Value

A data frame with anonymized patient data (preserves data.table class if
input was data.table)

## Examples

``` r
# Basic usage with auto-detection
patient_data <- data.frame(
  patient_id = c("P001", "P002", "P003"),
  name = c("John Doe", "Jane Smith", "Bob Johnson"),
  dob = as.Date(c("1980-01-15", "1975-03-20", "1990-06-10")),
  location = c("New York, NY", "Los Angeles, CA", "Chicago, IL"),
  diagnosis = c("A", "B", "A")
)
anonymize_dataframe(patient_data, seed = 123)
#>    patient_id             name        dob          location diagnosis
#> 1 ID_ouSbzEgq Patient_6k2nsVas 1980-02-23 Location_Q98vAvyL         A
#> 2 ID_E9JiNTER Patient_7g3kma75 1975-04-28 Location_sBSspjmx         B
#> 3 ID_H9dZM6iQ Patient_A7K9Ea9J 1990-07-19 Location_8MA8fu9H         A

# With month_year date granularity (YYYYMM format)
anonymize_dataframe(patient_data, date_method = "round", date_granularity = "month_year")
#>    patient_id             name    dob          location diagnosis
#> 1 ID_w2EsGPA6 Patient_wfvcEyLg 198001 Location_BKPB9n3n         A
#> 2 ID_qLcguMtS Patient_pA3Na8gU 197503 Location_peX4F6Vi         B
#> 3 ID_apswz96L Patient_6mNgRVDu 199006 Location_zx9FzuBK         A

# Works with data.table
if (requireNamespace("data.table", quietly = TRUE)) {
  dt <- data.table::as.data.table(patient_data)
  anonymize_dataframe(dt)
}
#>     patient_id             name        dob          location diagnosis
#>         <char>           <char>     <Date>            <char>    <char>
#> 1: ID_w2EsGPA6 Patient_wfvcEyLg 1980-09-10 Location_BKPB9n3n         A
#> 2: ID_qLcguMtS Patient_pA3Na8gU 1975-11-14 Location_peX4F6Vi         B
#> 3: ID_apswz96L Patient_6mNgRVDu 1991-02-04 Location_zx9FzuBK         A

# With UUID anonymization (default)
anonymize_dataframe(patient_data, seed = 123)
#>    patient_id             name        dob          location diagnosis
#> 1 ID_ouSbzEgq Patient_6k2nsVas 1980-02-23 Location_Q98vAvyL         A
#> 2 ID_E9JiNTER Patient_7g3kma75 1975-04-28 Location_sBSspjmx         B
#> 3 ID_H9dZM6iQ Patient_A7K9Ea9J 1990-07-19 Location_8MA8fu9H         A

# Without UUID (sequential IDs)
anonymize_dataframe(patient_data, use_uuid = FALSE, seed = 123)
#>   patient_id         name        dob      location diagnosis
#> 1     ID3663 Patient 3663 1980-02-23 Location 3663         A
#> 2     ID3664 Patient 3664 1975-04-28 Location 3664         B
#> 3     ID3665 Patient 3665 1990-07-19 Location 3665         A
```
