#' Anonymize Patient Identifiers
#'
#' Replaces patient identifiers with anonymized versions while maintaining
#' referential integrity (same IDs get the same anonymized value).
#'
#' @param x A vector of identifiers to anonymize (character, numeric, or factor)
#' @param prefix A character string to prefix anonymized IDs (default: "ID")
#' @param seed An optional seed for reproducible anonymization
#' @param use_uuid Logical, if TRUE uses short UUIDs instead of sequential IDs
#'   (default: TRUE).
#'
#' @return A character vector of anonymized identifiers
#'
#' @examples
#' ids <- c("P001", "P002", "P003", "P001")
#' anonymize_id(ids)
#' anonymize_id(ids, prefix = "PAT", seed = 123)
#' anonymize_id(ids, use_uuid = FALSE, seed = 123)  # Use sequential IDs
#'
#' @export
anonymize_id <- function(x, prefix = "ID", seed = NULL, use_uuid = TRUE) {
  # Validate inputs
  if (!is.logical(use_uuid) || length(use_uuid) != 1) {
    stop("use_uuid must be a single logical value")
  }
  
  if (use_uuid) {
    # Use short UUID generation
    return(generate_short_uuid(x, prefix = prefix, seed = seed))
  }
  
  # Original sequential ID generation
  # Store and restore RNG state if seed is provided
  if (!is.null(seed)) {
    if (exists(".Random.seed", envir = .GlobalEnv)) {
      old_seed <- get(".Random.seed", envir = .GlobalEnv)
      seed_exists <- TRUE
    } else {
      seed_exists <- FALSE
    }
    set.seed(seed)
    # Register on.exit() immediately after set.seed() to restore state
    on.exit({
      if (seed_exists) {
        assign(".Random.seed", old_seed, envir = .GlobalEnv)
      } else {
        if (exists(".Random.seed", envir = .GlobalEnv)) {
          rm(".Random.seed", envir = .GlobalEnv)
        }
      }
    }, add = TRUE)
  }

  # Convert to character if needed
  x_char <- as.character(x)

  # Create mapping of unique values to anonymized IDs
  unique_vals <- unique(x_char[!is.na(x_char)])
  n_unique <- length(unique_vals)

  # Generate anonymized IDs with dataset-specific offset if seed is provided
  # This ensures different datasets get different anonymized values
  if (!is.null(seed)) {
    # Use seed to create an offset for the ID numbering
    # This makes anonymized IDs different across datasets
    offset <- (seed %% 10000) + 1
    anonymized <- paste0(prefix, sprintf("%0*d", nchar(n_unique + offset), seq_len(n_unique) + offset))
  } else {
    anonymized <- paste0(prefix, sprintf("%0*d", nchar(n_unique), seq_len(n_unique)))
  }
  
  names(anonymized) <- unique_vals

  # Map original values to anonymized
  result <- anonymized[x_char]
  result[is.na(x_char)] <- NA_character_

  return(result)
}

