#' Generate Short UUID for Anonymization
#'
#' Internal function to generate short, reproducible UUIDs for anonymization.
#' Uses a hash-based approach to ensure referential integrity (same input
#' always produces same UUID) while maintaining uniqueness across datasets.
#'
#' @param x Character vector of values to anonymize
#' @param prefix Optional prefix for the UUID (default: NULL)
#' @param seed Dataset-specific seed for reproducibility
#' @param length Length of the random part (default: 8)
#'
#' @return Character vector of short UUIDs
#'
#' @keywords internal
generate_short_uuid <- function(x, prefix = NULL, seed = NULL, length = 8) {
  if (length(x) == 0) {
    return(character(0))
  }
  
  # Store current RNG state if it exists and restore on exit
  # CRAN-compliant approach: use on.exit() to restore state changed by set.seed()
  # This restores the global RNG state that set.seed() modifies, which is acceptable
  if (exists(".Random.seed", envir = .GlobalEnv)) {
    old_seed <- get(".Random.seed", envir = .GlobalEnv)
    seed_exists <- TRUE
    # Use on.exit to restore RNG state when function exits
    # This is the recommended CRAN-compliant way to restore state
    on.exit({
      if (seed_exists) {
        assign(".Random.seed", old_seed, envir = .GlobalEnv)
      }
    }, add = TRUE)
  } else {
    seed_exists <- FALSE
    # If no seed existed initially, clean up if set.seed() created one
    on.exit({
      if (exists(".Random.seed", envir = .GlobalEnv) && !seed_exists) {
        rm(".Random.seed", envir = .GlobalEnv)
      }
    }, add = TRUE)
  }
  
  # Convert to character
  x_char <- as.character(x)
  
  # Get unique values
  unique_vals <- unique(x_char[!is.na(x_char)])
  
  if (length(unique_vals) == 0) {
    result <- rep(NA_character_, length(x_char))
    return(result)
  }
  
  # Generate short UUIDs for unique values
  # Use hash of value + seed to ensure reproducibility and referential integrity
  uuid_map <- character(length(unique_vals))
  names(uuid_map) <- unique_vals
  
  # Character set for short UUIDs (alphanumeric, avoiding confusing characters)
  chars <- c(0:9, letters, LETTERS)
  # Remove confusing characters: 0, O, 1, I, l
  chars <- chars[!chars %in% c("0", "O", "1", "I", "l")]
  
  # Use robust hash for larger datasets to prevent collisions
  use_robust_hash <- length(unique_vals) > 5
  
  for (i in seq_along(unique_vals)) {
    val <- unique_vals[i]
    
    # Create a hash from value and seed
    hash_input <- paste0(val, "_", ifelse(is.null(seed), "default", as.character(seed)))
    
    if (use_robust_hash) {
      if (!requireNamespace("digest", quietly = TRUE)) {
        stop("digest package is required for large datasets. Please install it with: install.packages('digest')")
      }
      hash_hex <- digest::digest(hash_input, algo = "md5", serialize = FALSE)
      hash_chars <- strsplit(hash_hex, "")[[1]]
      char_indices <- sapply(1:length, function(j) {
        hex_pair <- paste0(hash_chars[((j-1)*2 + 1):min((j*2), 32)], collapse = "")
        as.integer(paste0("0x", hex_pair)) %% length(chars) + 1
      })
      random_part <- paste0(chars[char_indices], collapse = "")
    } else {
      hash_val <- sum(utf8ToInt(hash_input))
      # Use hash to generate reproducible random UUID
      # Save current state before setting seed (set.seed() modifies .Random.seed)
      if (seed_exists) {
        temp_seed <- get(".Random.seed", envir = .GlobalEnv)
      }
      set.seed(hash_val)
      # Generate short random string using R's RNG
      random_part <- paste0(sample(chars, length, replace = TRUE), collapse = "")
      # Restore previous seed immediately to avoid affecting subsequent iterations
      if (seed_exists) {
        assign(".Random.seed", temp_seed, envir = .GlobalEnv)
      }
    }
    
    # Add prefix if provided
    if (!is.null(prefix)) {
      uuid_map[i] <- paste0(prefix, "_", random_part)
    } else {
      uuid_map[i] <- random_part
    }
  }
  
  # Check for duplicates and resolve if needed (should be rare with MD5)
  if (any(duplicated(uuid_map))) {
    dup_indices <- which(duplicated(uuid_map))
    for (idx in dup_indices) {
      val <- unique_vals[idx]
      hash_input <- paste0(val, "_", ifelse(is.null(seed), "default", as.character(seed)), "_collision")
      if (use_robust_hash) {
        hash_hex <- digest::digest(hash_input, algo = "md5", serialize = FALSE)
        hash_val <- strtoi(substr(hash_hex, 1, 16), base = 16)
        if (is.na(hash_val)) {
          hash_val <- sum(utf8ToInt(hash_input))
        }
      } else {
        hash_val <- sum(utf8ToInt(hash_input))
      }
      if (seed_exists) {
        temp_seed <- get(".Random.seed", envir = .GlobalEnv)
      }
      set.seed(hash_val)
      random_part <- paste0(sample(chars, length, replace = TRUE), collapse = "")
      if (seed_exists) {
        assign(".Random.seed", temp_seed, envir = .GlobalEnv)
      }
      if (!is.null(prefix)) {
        uuid_map[idx] <- paste0(prefix, "_", random_part)
      } else {
        uuid_map[idx] <- random_part
      }
    }
  }
  
  # Map original values to UUIDs
  result <- uuid_map[x_char]
  result[is.na(x_char)] <- NA_character_
  
  return(result)
}

