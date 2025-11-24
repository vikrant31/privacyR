# Changelog

## Version 1.0.1 (2025-11-22)

CRAN release: 2025-11-23

### Bug Fixes

- **Critical fix:** Replaced weak hash function in UUID generation with
  cryptographic hash (MD5) to prevent duplicate UUIDs for different
  patients in large datasets
- Added robust hash function for datasets with more than 5 unique values
- Maintains backward compatibility: small datasets (≤5 unique values)
  use original hash method
- Now handles datasets with 1 million+ records without collisions
- Added `digest` package as required dependency for robust hashing
- Maintains referential integrity (same input → same UUID) while
  ensuring uniqueness

### Technical Details

- For large datasets (\>5 unique values): Uses MD5 hash via `digest`
  package
- For small datasets (≤5 unique values): Uses original hash method
  (backward compatible)
- MD5 collision probability for 1M records: ~10^-15 (negligible)
- All functions using UUIDs (anonymize_id, anonymize_names,
  anonymize_locations) benefit from this fix

## Version 1.0.0 (2024-11-09)

CRAN release: 2025-11-17

### Changes

- Fixed README.md to remove reference to DISCLAIMER file (CRAN
  compliance)
- Disclaimer text now only in README.md
- First stable release

## Version 0.1.1 (2024-11-07)

### Changes

- Package renamed from shadowR to privacyR to avoid CRAN name conflict
- Fixed LICENSE format for CRAN compliance
- Updated CDC HIPAA URL reference
- Added DISCLAIMER to .Rbuildignore

## Version 0.1.0 (Initial Release)

### Features

- Initial release of privacyR package
- [`anonymize_id()`](https://vikrant31.github.io/privacyR/reference/anonymize_id.md)
  function for anonymizing patient identifiers
- [`anonymize_names()`](https://vikrant31.github.io/privacyR/reference/anonymize_names.md)
  function for anonymizing patient names
- [`anonymize_dates()`](https://vikrant31.github.io/privacyR/reference/anonymize_dates.md)
  function with shift and round methods
- [`anonymize_locations()`](https://vikrant31.github.io/privacyR/reference/anonymize_locations.md)
  function with remove and generalize methods
- [`anonymize_dataframe()`](https://vikrant31.github.io/privacyR/reference/anonymize_dataframe.md)
  function for anonymizing entire data frames
- Comprehensive test suite using testthat
- Vignette with detailed examples and best practices
- Full roxygen2 documentation
