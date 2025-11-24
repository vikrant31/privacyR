#' @title privacyR: Privacy-Preserving Data Anonymization
#'
#' @description
#' Tools for anonymizing sensitive data in healthcare and research datasets.
#' Helps protect patient privacy while keeping data useful for analysis.
#'
#' @details
#' Main functions:
#' \itemize{
#'   \item \code{\link{anonymize_id}} - Anonymize patient identifiers
#'   \item \code{\link{anonymize_names}} - Anonymize patient names
#'   \item \code{\link{anonymize_dates}} - Anonymize dates (shift or round)
#'   \item \code{\link{anonymize_locations}} - Anonymize geographic locations
#'   \item \code{\link{anonymize_age}} - Anonymize ages into buckets
#'   \item \code{\link{anonymize_dataframe}} - Anonymize entire data frames
#' }
#'
#' @author
#' Vikrant Dev Rathore
#'
#' @references
#' For more information on data anonymization best practices, see:
#' \itemize{
#'   \item HIPAA De-identification Guidance: \url{https://www.hhs.gov/hipaa/for-professionals/privacy/special-topics/de-identification/index.html}
#'   \item CDC Data Privacy: \url{https://www.cdc.gov/phlp/php/resources/health-insurance-portability-and-accountability-act-of-1996-hipaa.html}
#'   \item California DHCS List of HIPAA Identifiers: \url{https://www.dhcs.ca.gov/dataandstats/data/Pages/ListofHIPAAIdentifiers.aspx}
#' }
#'
#' @section Disclaimer:
#' While this package aids in anonymizing patient data, users must ensure 
#' compliance with all applicable regulations. The author is not liable for 
#' any issues arising from use of this package. See the DISCLAIMER file for 
#' complete terms.
#'
#' @keywords internal
"_PACKAGE"

# The following block is used by usethis to automatically manage
# roxygen namespace tags. Modify with care!
## usethis namespace: start
## usethis namespace: end
NULL

