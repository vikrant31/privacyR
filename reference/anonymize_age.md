# Anonymize Age by Buckets

Groups ages into buckets for privacy protection. Default uses 10-year
buckets (0-9, 10-19, etc.) which are useful for research. Ages 90+ are
grouped together.

## Usage

``` r
anonymize_age(x, method = c("10year", "hipaa"), custom_buckets = NULL)
```

## Arguments

- x:

  A numeric vector of ages to anonymize

- method:

  Character string specifying bucketing method: "10year" (default) uses
  10-year buckets: 0-9, 10-19, 20-29, 30-39, 40-49, 50-59, 60-69, 70-79,
  80-89, 90+ "hipaa" uses HIPAA-compliant buckets: 0-17, 18-64, 65-89,
  90+

- custom_buckets:

  Optional named numeric vector for custom buckets. Format: c("0-9" = 9,
  "10-19" = 19, "20-29" = 29, "90+" = Inf)

## Value

A character vector of age buckets

## Examples

``` r
ages <- c(25, 45, 67, 92, 15, 78)
anonymize_age(ages)  # Uses 10-year buckets by default
#> [1] "20-29" "40-49" "60-69" "90+"   "10-19" "70-79"
anonymize_age(ages, method = "hipaa")  # Use HIPAA buckets
#> [1] "18-64" "18-64" "65-89" "90+"   "0-17"  "65-89"
```
