# Anonymize Dates

Anonymizes dates by shifting them by a random offset or rounding to a
specified granularity. Shifting preserves relative time differences.

## Usage

``` r
anonymize_dates(
  x,
  method = c("shift", "round"),
  days_shift = NULL,
  granularity = "month",
  seed = NULL
)
```

## Arguments

- x:

  A vector of dates (Date, POSIXct, or character that can be coerced to
  Date)

- method:

  Character string specifying anonymization method: "shift" (default)
  shifts all dates by a random offset, "round" rounds dates to specified
  granularity

- days_shift:

  For "shift" method: number of days to shift (default: random between
  -365 and 365)

- granularity:

  For "round" method: "day", "week", "month", "month_year", "quarter",
  or "year" (default: "month"). "month_year" returns character strings
  in "YYYYMM" format (e.g., "202005" for May 2020).

- seed:

  An optional seed for reproducible anonymization

## Value

A Date vector of anonymized dates (or character vector for "month_year"
granularity)

## Examples

``` r
dates <- as.Date(c("2020-01-15", "2020-03-20", "2020-06-10"))
anonymize_dates(dates, method = "shift", seed = 123)
#> [1] "2020-03-04" "2020-05-08" "2020-07-29"
anonymize_dates(dates, method = "round", granularity = "month")
#> [1] "2020-01-01" "2020-03-01" "2020-06-01"
anonymize_dates(dates, method = "round", granularity = "month_year")
#> [1] "202001" "202003" "202006"
```
