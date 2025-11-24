# Anonymize Patient Names

Replaces patient names with anonymized identifiers while maintaining
referential integrity (same names get the same anonymized value).

## Usage

``` r
anonymize_names(x, prefix = "Patient", seed = NULL, use_uuid = TRUE)
```

## Arguments

- x:

  A character vector of names to anonymize

- prefix:

  A character string to prefix anonymized names (default: "Patient")

- seed:

  An optional seed for reproducible anonymization

- use_uuid:

  Logical, if TRUE uses short UUIDs instead of sequential IDs (default:
  TRUE).

## Value

A character vector of anonymized names

## Examples

``` r
names <- c("John Doe", "Jane Smith", "Bob Johnson")
anonymize_names(names)
#>           John Doe         Jane Smith        Bob Johnson 
#> "Patient_sND3xPXV" "Patient_nCKLw9hL" "Patient_h4oP5N9d" 
anonymize_names(names, prefix = "PAT", seed = 123)
#>       John Doe     Jane Smith    Bob Johnson 
#> "PAT_NDg84Pt8" "PAT_ufNUJoZm" "PAT_ADANaKPi" 
anonymize_names(names, use_uuid = FALSE, seed = 123)  # Use sequential IDs
#>      John Doe    Jane Smith   Bob Johnson 
#> "Patient 125" "Patient 126" "Patient 127" 
```
