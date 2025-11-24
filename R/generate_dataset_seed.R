#' Generate Dataset-Specific Seed
#'
#' Internal function to generate a seed based on dataset content.
#' This ensures different datasets get different anonymized values even
#' with the same user-provided seed.
#'
#' @param data The dataset
#' @param user_seed Optional user-provided seed
#'
#' @return A numeric seed value
#'
#' @importFrom utils head
#' @keywords internal
generate_dataset_seed <- function(data, user_seed = NULL) {
  # Create a hash of the dataset structure and content
  # This ensures different datasets get different seeds
  # Use a simple hash function based on data characteristics
  
  # Include column names and structure
  col_info <- paste(names(data), collapse = ",")
  dim_info <- paste(nrow(data), ncol(data), sep = "x")
  
  # Include actual data content for uniqueness
  if (nrow(data) > 0) {
    # Sample more data rows and all columns for better uniqueness
    n_sample <- min(10, nrow(data))
    sample_rows <- data[1:n_sample, , drop = FALSE]
    
    # Convert each column to string representation
    sample_data <- paste(
      sapply(sample_rows, function(x) {
        # Take first few non-NA values
        vals <- x[!is.na(x)]
        if (length(vals) > 0) {
          paste(head(vals, min(5, length(vals))), collapse = "|")
        } else {
          "NA"
        }
      }),
      collapse = "||"
    )
    
    # Also include a hash of all unique values in each column
    unique_vals <- paste(
      sapply(data, function(x) {
        unique_vals_col <- unique(x[!is.na(x)])
        if (length(unique_vals_col) > 0) {
          paste(sort(head(unique_vals_col, 10)), collapse = ",")
        } else {
          "NA"
        }
      }),
      collapse = "|||"
    )
    
    data_signature <- paste(col_info, dim_info, sample_data, unique_vals, sep = "|||")
  } else {
    data_signature <- paste(col_info, dim_info, "empty", sep = "|||")
  }
  
  # Convert to numeric seed using simple hash
  # Use multiple hash passes for better distribution
  seed_value <- sum(utf8ToInt(data_signature))
  seed_value <- (seed_value * 31 + length(data_signature)) %% .Machine$integer.max
  seed_value <- (seed_value * 17 + nrow(data) * ncol(data)) %% .Machine$integer.max
  
  # Combine with user seed if provided
  if (!is.null(user_seed)) {
    seed_value <- (seed_value + as.integer(user_seed) * 7) %% .Machine$integer.max
  }
  
  return(seed_value)
}

