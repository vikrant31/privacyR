# privacyR

**Privacy-Preserving Data Anonymization for R**

An R package for anonymizing sensitive patient and research data. Helps protect privacy while keeping your data useful for analysis.

## Installation

```r
# Install from CRAN
install.packages("privacyR")
```

## Quick Start

```r
library(privacyR)

# Anonymize a data frame
patient_data <- data.frame(
  patient_id = c("P001", "P002", "P003"),
  name = c("John Doe", "Jane Smith", "Bob Johnson"),
  dob = as.Date(c("1980-01-15", "1975-03-20", "1990-06-10")),
  location = c("New York, NY", "Los Angeles, CA", "Chicago, IL")
)

anonymized_data <- anonymize_dataframe(patient_data, seed = 123)
print(anonymized_data)

# With UUID anonymization for stronger privacy
anonymized_data_uuid <- anonymize_dataframe(patient_data, use_uuid = TRUE, seed = 123)
print(anonymized_data_uuid)

# Month-year date anonymization
anonymized_data <- anonymize_dataframe(patient_data, 
                                       date_method = "round",
                                       date_granularity = "month_year")
print(anonymized_data)
```

## Features

- Anonymize IDs, names, dates, locations, and ages
- Maintains referential integrity (same values get same anonymized values)
- Auto-detects columns by name patterns and data types
- Short UUID support for stronger privacy (default)
- Date anonymization with month-year format (YYYYMM)
- Age bucketing (10-year or HIPAA-compliant)
- Works with data frames and data.tables
- Dataset-specific anonymization (different datasets get different values)

## Reproducibility and Seeds

All anonymization functions accept an optional `seed` parameter (default: `NULL`). 

- **When `seed = NULL`**: The package maintains referential integrity using a deterministic hash-based approach. Same inputs always produce the same anonymized outputs, ensuring relationships in your data are preserved.
- **When `seed` is provided**: You get explicit control over the anonymization for reproducibility across sessions.
- **Global RNG state**: The package always restores your R session's random number generator state after anonymization, so your random number generation is never affected.

You can use the package without providing a seed, and it will still maintain referential integrity automatically.

## Main Functions

- `anonymize_id()` - Anonymize patient identifiers
- `anonymize_names()` - Anonymize patient names
- `anonymize_dates()` - Anonymize dates (shift or round)
- `anonymize_locations()` - Anonymize geographic locations
- `anonymize_dataframe()` - Anonymize entire data frames

## Documentation

See the package vignette for detailed examples and usage:
```r
vignette("privacyR")
```

## Disclaimer

**IMPORTANT:** While the privacyR package aids in anonymizing patient data, users must ensure compliance with all applicable regulations and guidelines. The author is not liable for any issues arising from the use of this package.

**Testing:** This package has been tested against 1 million synthetic patient records to ensure UUID uniqueness and proper anonymization functionality. However, users should validate anonymization results for their specific use cases and datasets.

Users should pay close attention to:
- **CDC Guidelines**: [CDC Data Privacy and HIPAA](https://www.cdc.gov/phlp/php/resources/health-insurance-portability-and-accountability-act-of-1996-hipaa.html)
- **California Department of Health Care Services**: [DHCS List of HIPAA Identifiers](https://www.dhcs.ca.gov/dataandstats/data/Pages/ListofHIPAAIdentifiers.aspx)
- **HIPAA Regulations**: [HHS De-identification Guidance](https://www.hhs.gov/hipaa/for-professionals/privacy/special-topics/de-identification/index.html)

This package is provided "as is" without warranty. Users assume full responsibility for ensuring anonymized data meets regulatory requirements. Consult with legal and privacy experts as needed.

## License

MIT

## Citation

If you use this package in your research, please cite it as:

```r
citation("privacyR")
```

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

