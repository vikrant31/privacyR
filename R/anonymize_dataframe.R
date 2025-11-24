#' Anonymize Patient Data in a Data Frame
#'
#' Main function to anonymize patient data in a data frame or data.table.
#' Automatically detects and anonymizes columns based on data types and naming
#' patterns, or you can manually specify columns. Different datasets get
#' different anonymized values for better privacy.
#'
#' @param data A data frame or data.table containing patient data
#' @param id_cols Character vector of column names containing patient IDs
#' @param name_cols Character vector of column names containing patient names
#' @param date_cols Character vector of column names containing dates
#' @param location_cols Character vector of column names containing locations
#' @param age_cols Character vector of column names containing ages
#' @param auto_detect Logical, if TRUE (default), automatically detects columns
#'   based on data types and common naming patterns
#' @param detect_by_type Logical, if TRUE (default), detects columns by their
#'   R data types (Date, character, etc.) in addition to name patterns
#' @param date_method Method for date anonymization: "shift" or "round" (default: "shift").
#'   Use "round" to enable granularity options including "month_year" (YYYYMM format).
#' @param date_granularity For date rounding (when date_method = "round"): "day", "week", "month", 
#'   "month_year" (returns YYYYMM format, e.g., "202005"), "quarter", or "year" (default: "month")
#' @param location_method Method for location anonymization: "remove" or "generalize"
#' @param use_uuid Logical, if TRUE uses short UUIDs for IDs, names, and locations
#'   instead of sequential identifiers (default: TRUE). Dates and ages are not affected.
#' @param age_method Method for age anonymization: "10year" (default) uses 10-year buckets
#'   (0-9, 10-19, 20-29, ..., 80-89, 90+) for better research utility, or "hipaa" for
#'   HIPAA-compliant buckets (0-17, 18-64, 65-89, 90+)
#' @param seed An optional seed for reproducible anonymization. Different
#'   datasets will still get different anonymized values even with the same seed.
#' @param dataset_specific Logical, if TRUE (default), generates dataset-specific
#'   seeds so different datasets get different anonymized values
#'
#' @return A data frame with anonymized patient data (preserves data.table class if input was data.table)
#'
#' @examples
#' # Basic usage with auto-detection
#' patient_data <- data.frame(
#'   patient_id = c("P001", "P002", "P003"),
#'   name = c("John Doe", "Jane Smith", "Bob Johnson"),
#'   dob = as.Date(c("1980-01-15", "1975-03-20", "1990-06-10")),
#'   location = c("New York, NY", "Los Angeles, CA", "Chicago, IL"),
#'   diagnosis = c("A", "B", "A")
#' )
#' anonymize_dataframe(patient_data, seed = 123)
#'
#' # With month_year date granularity (YYYYMM format)
#' anonymize_dataframe(patient_data, date_method = "round", date_granularity = "month_year")
#'
#' # Works with data.table
#' if (requireNamespace("data.table", quietly = TRUE)) {
#'   dt <- data.table::as.data.table(patient_data)
#'   anonymize_dataframe(dt)
#' }
#'
#' # With UUID anonymization (default)
#' anonymize_dataframe(patient_data, seed = 123)
#'
#' # Without UUID (sequential IDs)
#' anonymize_dataframe(patient_data, use_uuid = FALSE, seed = 123)
#'
#' @export
anonymize_dataframe <- function(data, id_cols = NULL, name_cols = NULL,
                                 date_cols = NULL, location_cols = NULL,
                                 age_cols = NULL,
                                 auto_detect = TRUE, detect_by_type = TRUE,
                                 date_method = "shift",
                                 date_granularity = "month",
                                 location_method = "generalize",
                                 age_method = "10year",
                                 use_uuid = TRUE,
                                 seed = NULL, dataset_specific = TRUE) {
  # Check if data.table
  is_data_table <- inherits(data, "data.table")
  
  # Convert data.table to data.frame for processing, but preserve class
  if (is_data_table) {
    data <- as.data.frame(data)
  } else if (!is.data.frame(data)) {
    stop("data must be a data frame or data.table")
  }

  # Generate dataset-specific seed if requested
  if (dataset_specific) {
    dataset_seed <- generate_dataset_seed(data, user_seed = seed)
  } else {
    dataset_seed <- seed
  }

  # Store and restore RNG state if seed is provided
  if (!is.null(dataset_seed)) {
    if (exists(".Random.seed", envir = .GlobalEnv)) {
      old_seed <- get(".Random.seed", envir = .GlobalEnv)
      seed_exists <- TRUE
    } else {
      seed_exists <- FALSE
    }
    set.seed(dataset_seed)
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

  result <- data

  # Auto-detect columns if requested
  if (auto_detect) {
    all_cols <- names(data)

    # Detect by type if requested
    if (detect_by_type) {
      # Detect Date/POSIXct columns by type
      date_type_cols <- all_cols[sapply(data, function(x) {
        inherits(x, c("Date", "POSIXct", "POSIXt"))
      })]
      
      # Detect character columns that might be IDs, names, or locations
      char_cols <- all_cols[sapply(data, is.character)]
      
      # Detect numeric columns that might be IDs
      num_cols <- all_cols[sapply(data, is.numeric)]
    } else {
      date_type_cols <- character(0)
      char_cols <- character(0)
      num_cols <- character(0)
    }

    # Detect ID columns (by name pattern and type)
    if (is.null(id_cols)) {
      id_patterns <- c("id", "ID", "patient_id", "patientid", "subject_id", "subjectid")
      id_by_name <- all_cols[grepl(paste(id_patterns, collapse = "|"), all_cols, ignore.case = TRUE)]
      
      # Also consider numeric or character columns that look like IDs
      id_by_type <- c()
      if (detect_by_type) {
        # Character columns with short, unique values might be IDs
        for (col in char_cols) {
          non_na <- data[[col]][!is.na(data[[col]])]
          if (length(non_na) > 0) {
            uniqueness_ratio <- length(unique(non_na)) / length(non_na)
            avg_length <- mean(nchar(non_na), na.rm = TRUE)
            # High uniqueness and short values suggest ID
            if (uniqueness_ratio > 0.8 && avg_length < 20) {
              id_by_type <- c(id_by_type, col)
            }
          }
        }
        # Numeric integer columns with high uniqueness might be IDs
        # Exclude columns that look like ages (0-120 range)
        for (col in num_cols) {
          non_na <- data[[col]][!is.na(data[[col]])]
          if (length(non_na) > 0) {
            # Check if this might be an age column first
            is_likely_age <- all(non_na >= 0 & non_na <= 120, na.rm = TRUE) && 
                            mean(non_na, na.rm = TRUE) > 0 && 
                            mean(non_na, na.rm = TRUE) < 100
            
            if (!is_likely_age) {
              is_integer <- all(non_na == as.integer(non_na))
              uniqueness_ratio <- length(unique(non_na)) / length(non_na)
              # Integer values with high uniqueness suggest ID
              if (is_integer && uniqueness_ratio > 0.7 && length(unique(non_na)) > 1) {
                id_by_type <- c(id_by_type, col)
              }
            }
          }
        }
      }
      
      id_cols <- unique(c(id_by_name, id_by_type))
    }

    # Detect name columns (by name pattern and type)
    if (is.null(name_cols)) {
      name_patterns <- c("name", "Name", "patient_name", "firstname", "lastname", "fullname", 
                         "first_name", "last_name", "fname", "lname")
      name_by_name <- all_cols[grepl(paste(name_patterns, collapse = "|"), all_cols, ignore.case = TRUE)]
      
      # Character columns with longer text values might be names
      name_by_type <- c()
      if (detect_by_type) {
        for (col in char_cols) {
          if (!col %in% id_cols && 
              any(nchar(data[[col]][!is.na(data[[col]])]) > 5, na.rm = TRUE) &&
              any(grepl(" ", data[[col]][!is.na(data[[col]])]))) {
            # Contains spaces and longer text suggests name
            name_by_type <- c(name_by_type, col)
          }
        }
      }
      
      name_cols <- unique(c(name_by_name, name_by_type))
    }

    # Detect date columns (by name pattern and type)
    if (is.null(date_cols)) {
      date_patterns <- c("date", "Date", "dob", "DOB", "birth", "admission", "discharge", 
                        "visit_date", "appointment", "time")
      date_by_name <- all_cols[grepl(paste(date_patterns, collapse = "|"), all_cols, ignore.case = TRUE)]
      date_cols <- unique(c(date_by_name, date_type_cols))
    }

    # Detect location columns (by name pattern and type)
    if (is.null(location_cols)) {
      location_patterns <- c("location", "Location", "address", "Address", "city", "City", 
                            "zip", "ZIP", "postal", "state", "country", "region")
      location_by_name <- all_cols[grepl(paste(location_patterns, collapse = "|"), all_cols, ignore.case = TRUE)]
      
      # Character columns that might be locations
      location_by_type <- c()
      if (detect_by_type) {
        for (col in char_cols) {
          if (!col %in% c(id_cols, name_cols) &&
              any(grepl(",", data[[col]][!is.na(data[[col]])]) | 
                  grepl("\\d{5}", data[[col]][!is.na(data[[col]])]))) {
            # Contains commas or ZIP codes suggests location
            location_by_type <- c(location_by_type, col)
          }
        }
      }
      
      location_cols <- unique(c(location_by_name, location_by_type))
    }

    # Detect age columns (by name pattern and type)
    if (is.null(age_cols)) {
      age_patterns <- c("age", "Age", "patient_age", "age_years", "age_at")
      age_by_name <- all_cols[grepl(paste(age_patterns, collapse = "|"), all_cols, ignore.case = TRUE)]
      
      # Numeric columns that might be ages (reasonable age range: 0-120)
      age_by_type <- c()
      if (detect_by_type) {
        for (col in num_cols) {
          if (!col %in% id_cols) {
            non_na <- data[[col]][!is.na(data[[col]])]
            if (length(non_na) > 0) {
              # Check if values are in reasonable age range
              if (all(non_na >= 0 & non_na <= 120, na.rm = TRUE) && 
                  mean(non_na, na.rm = TRUE) > 0 && mean(non_na, na.rm = TRUE) < 100) {
                age_by_type <- c(age_by_type, col)
              }
            }
          }
        }
      }
      
      age_cols <- unique(c(age_by_name, age_by_type))
    }
  }

  # Validate use_uuid parameter
  if (!is.logical(use_uuid) || length(use_uuid) != 1) {
    stop("use_uuid must be a single logical value")
  }

  # Anonymize ID columns
  if (!is.null(id_cols) && length(id_cols) > 0) {
    for (col in id_cols) {
      if (col %in% names(result)) {
        result[[col]] <- anonymize_id(result[[col]], prefix = "ID", 
                                      seed = dataset_seed, use_uuid = use_uuid)
      }
    }
  }

  # Anonymize name columns
  if (!is.null(name_cols) && length(name_cols) > 0) {
    for (col in name_cols) {
      if (col %in% names(result)) {
        result[[col]] <- anonymize_names(result[[col]], prefix = "Patient", 
                                         seed = dataset_seed, use_uuid = use_uuid)
      }
    }
  }

  # Anonymize date columns (dates are NOT affected by use_uuid)
  if (!is.null(date_cols) && length(date_cols) > 0) {
    for (col in date_cols) {
      if (col %in% names(result)) {
        result[[col]] <- anonymize_dates(result[[col]], method = date_method,
                                         granularity = date_granularity, seed = dataset_seed)
      }
    }
  }

  # Anonymize location columns
  if (!is.null(location_cols) && length(location_cols) > 0) {
    for (col in location_cols) {
      if (col %in% names(result)) {
        result[[col]] <- anonymize_locations(result[[col]], method = location_method,
                                             seed = dataset_seed, use_uuid = use_uuid)
      }
    }
  }

  # Anonymize age columns (HIPAA-compliant bucketing)
  if (!is.null(age_cols) && length(age_cols) > 0) {
    for (col in age_cols) {
      if (col %in% names(result)) {
        # Ensure age column is numeric
        age_values <- as.numeric(result[[col]])
        result[[col]] <- anonymize_age(age_values, method = age_method)
      }
    }
  }

  # Convert back to data.table if original was data.table
  if (is_data_table) {
    if (requireNamespace("data.table", quietly = TRUE)) {
      result <- data.table::as.data.table(result)
    }
  }

  return(result)
}

