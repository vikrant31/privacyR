#' Anonymize Geographic Locations
#'
#' Anonymizes geographic locations by removing them or replacing with generic
#' labels. Maintains referential integrity (same locations get the same value).
#'
#' @param x A character vector of locations to anonymize
#' @param method Character string specifying anonymization method:
#'   "remove" (default) removes location information,
#'   "generalize" replaces with generic location labels
#' @param prefix For "generalize" method: prefix for generic locations (default: "Location")
#' @param seed An optional seed for reproducible anonymization
#' @param use_uuid Logical, if TRUE uses short UUIDs instead of sequential IDs
#'   (default: TRUE). Only applies when method = "generalize".
#'
#' @return A character vector of anonymized locations
#'
#' @examples
#' locations <- c("New York, NY", "Los Angeles, CA", "Chicago, IL")
#' anonymize_locations(locations, method = "remove")
#' anonymize_locations(locations, method = "generalize", seed = 123)
#' anonymize_locations(locations, method = "generalize", 
#'                     use_uuid = FALSE, seed = 123)  # Use sequential IDs
#'
#' @export
anonymize_locations <- function(x, method = c("remove", "generalize"),
                                prefix = "Location", seed = NULL, use_uuid = TRUE) {
  # Validate inputs
  if (!is.logical(use_uuid) || length(use_uuid) != 1) {
    stop("use_uuid must be a single logical value")
  }
  
  method <- match.arg(method)

  # Convert to character if needed
  x_char <- as.character(x)

  if (method == "remove") {
    # Replace with NA or generic placeholder
    result <- rep(NA_character_, length(x_char))
    result[!is.na(x_char)] <- "[Location Removed]"
  } else if (method == "generalize") {
    if (use_uuid) {
      # Use short UUID generation
      result <- generate_short_uuid(x, prefix = prefix, seed = seed)
    } else {
      # Original sequential location generation
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
      
      # Create mapping of unique locations to generic labels
      unique_locs <- unique(x_char[!is.na(x_char)])
      n_unique <- length(unique_locs)

      # Generate generic location labels with dataset-specific offset if seed is provided
      if (!is.null(seed)) {
        offset <- (seed %% 10000) + 1
        anonymized <- paste0(prefix, sprintf(" %0*d", nchar(n_unique + offset), seq_len(n_unique) + offset))
      } else {
        anonymized <- paste0(prefix, sprintf(" %0*d", nchar(n_unique), seq_len(n_unique)))
      }
      
      names(anonymized) <- unique_locs

      # Map original locations to anonymized
      result <- anonymized[x_char]
      result[is.na(x_char)] <- NA_character_
    }
  }

  return(result)
}

