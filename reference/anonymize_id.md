# Anonymize Patient Identifiers

Replaces patient identifiers with anonymized versions while maintaining
referential integrity (same IDs get the same anonymized value).

## Usage

``` r
anonymize_id(x, prefix = "ID", seed = NULL, use_uuid = TRUE)
```

## Arguments

- x:

  A vector of identifiers to anonymize (character, numeric, or factor)

- prefix:

  A character string to prefix anonymized IDs (default: "ID")

- seed:

  An optional seed for reproducible anonymization

- use_uuid:

  Logical, if TRUE uses short UUIDs instead of sequential IDs (default:
  TRUE).

## Value

A character vector of anonymized identifiers

## Examples

``` r
ids <- c("P001", "P002", "P003", "P001")
anonymize_id(ids)
#>          P001          P002          P003          P001 
#> "ID_KPHvJnAi" "ID_SPQFnmK7" "ID_AmV2nhjB" "ID_KPHvJnAi" 
anonymize_id(ids, prefix = "PAT", seed = 123)
#>           P001           P002           P003           P001 
#> "PAT_uhjsB46B" "PAT_4cQBb8Pk" "PAT_meDL69Fd" "PAT_uhjsB46B" 
anonymize_id(ids, use_uuid = FALSE, seed = 123)  # Use sequential IDs
#>    P001    P002    P003    P001 
#> "ID125" "ID126" "ID127" "ID125" 
```
