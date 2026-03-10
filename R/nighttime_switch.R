#' Summarise times across midnight
#'
#' Converts times before `cutoff` to the next day before applying `.fun`, which
#' helps summarise nighttime values spanning midnight (for example, median sleep
#' time).
#'
#' @param datetime A date-time vector coercible to `POSIXct`.
#' @param .fun Summary function applied after the date shift.
#' @param cutoff Cutoff in seconds since midnight. Values below cutoff are
#'   treated as belonging to the next day.
#' @param hms Logical; if `TRUE`, return an `hms` object.
#'
#' @return A summarised time as `hms` (default) or date-time.
#' @export
#'
#' @examples
#' x <- as.POSIXct(c("2024-01-01 23:00:00", "2024-01-02 01:00:00"), tz = "UTC")
#' nighttime_switch(x)
nighttime_switch <- function(datetime,
                             .fun = median,
                             cutoff = 12 * 60 * 60,
                             hms = TRUE) {
  datetime <- as.POSIXct(datetime)
  tz <- attr(datetime, "tzone") %||% "UTC"

  time_seconds <- as.numeric(hms::as_hms(datetime))
  shifted_dates <- as.Date(datetime) + ifelse(time_seconds < cutoff, 1, 0)

  shifted <- as.POSIXct(shifted_dates, tz = tz) + time_seconds
  out <- .fun(shifted)

  if (hms) {
    return(hms::as_hms(out))
  }

  out
}
