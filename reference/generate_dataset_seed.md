# Generate Dataset-Specific Seed

Internal function to generate a seed based on dataset content. This
ensures different datasets get different anonymized values even with the
same user-provided seed.

## Usage

``` r
generate_dataset_seed(data, user_seed = NULL)
```

## Arguments

- data:

  The dataset

- user_seed:

  Optional user-provided seed

## Value

A numeric seed value
