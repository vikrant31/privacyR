#' Anonymize Age by Buckets
#'
#' Groups ages into buckets for privacy protection. Default uses 10-year buckets
#' (0-9, 10-19, etc.) which are useful for research. Ages 90+ are grouped together.
#'
#' @param x A numeric vector of ages to anonymize
#' @param method Character string specifying bucketing method:
#'   "10year" (default) uses 10-year buckets: 0-9, 10-19, 20-29, 30-39, 40-49, 50-59, 60-69, 70-79, 80-89, 90+
#'   "hipaa" uses HIPAA-compliant buckets: 0-17, 18-64, 65-89, 90+
#' @param custom_buckets Optional named numeric vector for custom buckets.
#'   Format: c("0-9" = 9, "10-19" = 19, "20-29" = 29, "90+" = Inf)
#'
#' @return A character vector of age buckets
#'
#' @examples
#' ages <- c(25, 45, 67, 92, 15, 78)
#' anonymize_age(ages)  # Uses 10-year buckets by default
#' anonymize_age(ages, method = "hipaa")  # Use HIPAA buckets
#'
#' @export
anonymize_age <- function(x, method = c("10year", "hipaa"), custom_buckets = NULL) {
  method <- match.arg(method)
  
  # Validate input
  if (!is.numeric(x)) {
    stop("x must be a numeric vector")
  }
  
  # Handle NA values
  na_mask <- is.na(x)
  
  # 10-year buckets (default - research-friendly)
  if (method == "10year") {
    result <- character(length(x))
    
    result[x >= 0 & x <= 9 & !na_mask] <- "0-9"
    result[x >= 10 & x <= 19 & !na_mask] <- "10-19"
    result[x >= 20 & x <= 29 & !na_mask] <- "20-29"
    result[x >= 30 & x <= 39 & !na_mask] <- "30-39"
    result[x >= 40 & x <= 49 & !na_mask] <- "40-49"
    result[x >= 50 & x <= 59 & !na_mask] <- "50-59"
    result[x >= 60 & x <= 69 & !na_mask] <- "60-69"
    result[x >= 70 & x <= 79 & !na_mask] <- "70-79"
    result[x >= 80 & x <= 89 & !na_mask] <- "80-89"
    result[x >= 90 & !na_mask] <- "90+"
    
    # Handle negative ages or invalid values
    invalid <- x < 0 & !na_mask
    if (any(invalid)) {
      warning("Some ages are negative and will be set to NA")
      result[invalid] <- NA_character_
    }
    
    result[na_mask] <- NA_character_
  }
  
  # HIPAA-compliant buckets (alternative)
  if (method == "hipaa") {
    # HIPAA Safe Harbor method: 0-17, 18-64, 65-89, 90+
    result <- character(length(x))
    
    result[x >= 0 & x <= 17 & !na_mask] <- "0-17"
    result[x >= 18 & x <= 64 & !na_mask] <- "18-64"
    result[x >= 65 & x <= 89 & !na_mask] <- "65-89"
    result[x >= 90 & !na_mask] <- "90+"
    
    # Handle negative ages or invalid values
    invalid <- x < 0 & !na_mask
    if (any(invalid)) {
      warning("Some ages are negative and will be set to NA")
      result[invalid] <- NA_character_
    }
    
    result[na_mask] <- NA_character_
  }
  
  # Custom buckets if provided
  if (!is.null(custom_buckets)) {
    if (!is.numeric(custom_buckets) || is.null(names(custom_buckets))) {
      stop("custom_buckets must be a named numeric vector")
    }
    
    result <- character(length(x))
    sorted_buckets <- sort(custom_buckets)
    
    for (i in seq_along(sorted_buckets)) {
      bucket_name <- names(sorted_buckets)[i]
      upper_bound <- sorted_buckets[i]
      
      if (i == 1) {
        lower_bound <- 0
      } else {
        lower_bound <- sorted_buckets[i - 1] + 1
      }
      
      if (is.infinite(upper_bound)) {
        result[x >= lower_bound & !na_mask] <- bucket_name
      } else {
        result[x >= lower_bound & x <= upper_bound & !na_mask] <- bucket_name
      }
    }
    
    result[na_mask] <- NA_character_
  }
  
  return(result)
}

