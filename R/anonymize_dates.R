#' Anonymize Dates
#'
#' Anonymizes dates by shifting them by a random offset or rounding to a
#' specified granularity. Shifting preserves relative time differences.
#'
#' @param x A vector of dates (Date, POSIXct, or character that can be coerced to Date)
#' @param method Character string specifying anonymization method:
#'   "shift" (default) shifts all dates by a random offset,
#'   "round" rounds dates to specified granularity
#' @param days_shift For "shift" method: number of days to shift (default: random between -365 and 365)
#' @param granularity For "round" method: "day", "week", "month", "month_year", "quarter", or "year" (default: "month").
#'   "month_year" returns character strings in "YYYYMM" format (e.g., "202005" for May 2020).
#' @param seed An optional seed for reproducible anonymization
#'
#' @return A Date vector of anonymized dates (or character vector for "month_year" granularity)
#'
#' @examples
#' dates <- as.Date(c("2020-01-15", "2020-03-20", "2020-06-10"))
#' anonymize_dates(dates, method = "shift", seed = 123)
#' anonymize_dates(dates, method = "round", granularity = "month")
#' anonymize_dates(dates, method = "round", granularity = "month_year")
#'
#' @importFrom lubridate floor_date year month
#' @export
anonymize_dates <- function(x, method = c("shift", "round"),
                            days_shift = NULL, granularity = "month",
                            seed = NULL) {
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

  method <- match.arg(method)

  # Convert to Date if needed
  if (inherits(x, "POSIXct") || inherits(x, "POSIXt")) {
    x <- as.Date(x)
  } else if (is.character(x)) {
    x <- as.Date(x)
  } else if (!inherits(x, "Date")) {
    stop("x must be a Date, POSIXct, or character vector that can be coerced to Date")
  }

  if (method == "shift") {
    # Shift dates by a random offset
    if (is.null(days_shift)) {
      days_shift <- sample(-365:365, 1)
    }
    result <- x + days_shift
  } else if (method == "round") {
    # Round dates to specified granularity
    valid_granularities <- c("day", "week", "month", "month_year", "quarter", "year")
    if (!granularity %in% valid_granularities) {
      stop("granularity must be one of: ", paste(valid_granularities, collapse = ", "))
    }
    
    if (granularity == "month_year") {
      # Return character vector in "YYYYMM" format (year-month, no hyphen)
      rounded_dates <- lubridate::floor_date(x, unit = "month")
      result <- paste0(lubridate::year(rounded_dates), 
                       sprintf("%02d", lubridate::month(rounded_dates)))
    } else {
      result <- lubridate::floor_date(x, unit = granularity)
    }
  }

  return(result)
}

