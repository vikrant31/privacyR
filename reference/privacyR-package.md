# privacyR: Privacy-Preserving Data Anonymization

Tools for anonymizing sensitive data in healthcare and research
datasets. Helps protect patient privacy while keeping data useful for
analysis.

## Details

Main functions:

- [`anonymize_id`](https://vikrant31.github.io/privacyR/reference/anonymize_id.md) -
  Anonymize patient identifiers

- [`anonymize_names`](https://vikrant31.github.io/privacyR/reference/anonymize_names.md) -
  Anonymize patient names

- [`anonymize_dates`](https://vikrant31.github.io/privacyR/reference/anonymize_dates.md) -
  Anonymize dates (shift or round)

- [`anonymize_locations`](https://vikrant31.github.io/privacyR/reference/anonymize_locations.md) -
  Anonymize geographic locations

- [`anonymize_age`](https://vikrant31.github.io/privacyR/reference/anonymize_age.md) -
  Anonymize ages into buckets

- [`anonymize_dataframe`](https://vikrant31.github.io/privacyR/reference/anonymize_dataframe.md) -
  Anonymize entire data frames

## Disclaimer

While this package aids in anonymizing patient data, users must ensure
compliance with all applicable regulations. The author is not liable for
any issues arising from use of this package. See the DISCLAIMER file for
complete terms.

## References

For more information on data anonymization best practices, see:

- HIPAA De-identification Guidance:
  <https://www.hhs.gov/hipaa/for-professionals/privacy/special-topics/de-identification/index.html>

- CDC Data Privacy:
  <https://www.cdc.gov/phlp/php/resources/health-insurance-portability-and-accountability-act-of-1996-hipaa.html>

- California DHCS List of HIPAA Identifiers:
  <https://www.dhcs.ca.gov/dataandstats/data/Pages/ListofHIPAAIdentifiers.aspx>

## Author

Vikrant Dev Rathore
