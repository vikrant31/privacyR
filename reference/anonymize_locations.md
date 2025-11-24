# Anonymize Geographic Locations

Anonymizes geographic locations by removing them or replacing with
generic labels. Maintains referential integrity (same locations get the
same value).

## Usage

``` r
anonymize_locations(
  x,
  method = c("remove", "generalize"),
  prefix = "Location",
  seed = NULL,
  use_uuid = TRUE
)
```

## Arguments

- x:

  A character vector of locations to anonymize

- method:

  Character string specifying anonymization method: "remove" (default)
  removes location information, "generalize" replaces with generic
  location labels

- prefix:

  For "generalize" method: prefix for generic locations (default:
  "Location")

- seed:

  An optional seed for reproducible anonymization

- use_uuid:

  Logical, if TRUE uses short UUIDs instead of sequential IDs (default:
  TRUE). Only applies when method = "generalize".

## Value

A character vector of anonymized locations

## Examples

``` r
locations <- c("New York, NY", "Los Angeles, CA", "Chicago, IL")
anonymize_locations(locations, method = "remove")
#> [1] "[Location Removed]" "[Location Removed]" "[Location Removed]"
anonymize_locations(locations, method = "generalize", seed = 123)
#>        New York, NY     Los Angeles, CA         Chicago, IL 
#> "Location_ggyQKpzW" "Location_hybAy7Aq" "Location_DpYfTU6h" 
anonymize_locations(locations, method = "generalize", 
                    use_uuid = FALSE, seed = 123)  # Use sequential IDs
#>    New York, NY Los Angeles, CA     Chicago, IL 
#>  "Location 125"  "Location 126"  "Location 127" 
```
