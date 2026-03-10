#' Title
#'
#' @param .fun
#' @param cutoff
#' @param hms
#' @param datetime
#'
#' @returns
#' @export
#'
#' @examples
nighttime_switch <- function(datetime,
                             .fun = median,
                             cutoff = 12*60*60,
                             hms = TRUE
                             ){
  morning <- hms::as_hms(datetime) < cutoff
  lubridate::date(datetime) <-
    ifelse(morning, as.Date("2000-01-02"), as.Date("2000-01-01")) |>
    as.Date()
  datetime <- .fun(datetime)

  if(hms) return(datetime |> hms::as_hms()) else return(datetime)
}
