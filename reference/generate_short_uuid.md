# Generate Short UUID for Anonymization

Internal function to generate short, reproducible UUIDs for
anonymization. Uses a hash-based approach to ensure referential
integrity (same input always produces same UUID) while maintaining
uniqueness across datasets.

## Usage

``` r
generate_short_uuid(x, prefix = NULL, seed = NULL, length = 8)
```

## Arguments

- x:

  Character vector of values to anonymize

- prefix:

  Optional prefix for the UUID (default: NULL)

- seed:

  Dataset-specific seed for reproducibility

- length:

  Length of the random part (default: 8)

## Value

Character vector of short UUIDs
