## Version 1.0.1 (2025-11-22)

### Bug Fixes
- **Critical fix:** Replaced weak hash function in UUID generation with cryptographic hash (MD5) to prevent duplicate UUIDs for different patients in large datasets
- Added robust hash function for datasets with more than 5 unique values
- Maintains backward compatibility: small datasets (≤5 unique values) use original hash method
- Now handles datasets with 1 million+ records without collisions
- Added `digest` package as required dependency for robust hashing
- Maintains referential integrity (same input → same UUID) while ensuring uniqueness

### Technical Details
- For large datasets (>5 unique values): Uses MD5 hash via `digest` package
- For small datasets (≤5 unique values): Uses original hash method (backward compatible)
- MD5 collision probability for 1M records: ~10^-15 (negligible)
- All functions using UUIDs (anonymize_id, anonymize_names, anonymize_locations) benefit from this fix

## Version 1.0.0 (2024-11-09)

### Changes
- Fixed README.md to remove reference to DISCLAIMER file (CRAN compliance)
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
- `anonymize_id()` function for anonymizing patient identifiers
- `anonymize_names()` function for anonymizing patient names
- `anonymize_dates()` function with shift and round methods
- `anonymize_locations()` function with remove and generalize methods
- `anonymize_dataframe()` function for anonymizing entire data frames
- Comprehensive test suite using testthat
- Vignette with detailed examples and best practices
- Full roxygen2 documentation

