#' Anonymize Patient Names
#'
#' Replaces patient names with anonymized identifiers while maintaining
#' referential integrity (same names get the same anonymized value).
#'
#' @param x A character vector of names to anonymize
#' @param prefix A character string to prefix anonymized names (default: "Patient")
#' @param seed An optional seed for reproducible anonymization
#' @param use_uuid Logical, if TRUE uses short UUIDs instead of sequential IDs
#'   (default: TRUE).
#'
#' @return A character vector of anonymized names
#'
#' @examples
#' names <- c("John Doe", "Jane Smith", "Bob Johnson")
#' anonymize_names(names)
#' anonymize_names(names, prefix = "PAT", seed = 123)
#' anonymize_names(names, use_uuid = FALSE, seed = 123)  # Use sequential IDs
#'
#' @export
anonymize_names <- function(x, prefix = "Patient", seed = NULL, use_uuid = TRUE) {
  # Validate inputs
  if (!is.logical(use_uuid) || length(use_uuid) != 1) {
    stop("use_uuid must be a single logical value")
  }
  
  if (use_uuid) {
    # Use short UUID generation
    return(generate_short_uuid(x, prefix = prefix, seed = seed))
  }
  
  # Original sequential name generation
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

  # Create mapping of unique names to anonymized versions
  unique_names <- unique(x_char[!is.na(x_char)])
  n_unique <- length(unique_names)

  # Generate anonymized names with dataset-specific offset if seed is provided
  if (!is.null(seed)) {
    offset <- (seed %% 10000) + 1
    anonymized <- paste0(prefix, sprintf(" %0*d", nchar(n_unique + offset), seq_len(n_unique) + offset))
  } else {
    anonymized <- paste0(prefix, sprintf(" %0*d", nchar(n_unique), seq_len(n_unique)))
  }
  
  names(anonymized) <- unique_names

  # Map original names to anonymized
  result <- anonymized[x_char]
  result[is.na(x_char)] <- NA_character_

  return(result)
}

