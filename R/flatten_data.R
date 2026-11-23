#' Flatten multi-site MeLiDos data into one table
#'
#' `flatten_data()` combines the named list returned by [load_data()] into one
#' tibble and keeps site provenance in a `site` column.
#'
#' The default preserves local clock readings using [lubridate::force_tz()].
#' This changes the represented instants and is intended for comparisons by
#' local clock time. Use `time_mode = "instant"` to preserve absolute instants
#' with [lubridate::with_tz()], for example when aligning devices or diaries.
#' Neither mode repairs incorrectly parsed source timestamps.
#' In clock mode, readings skipped by a daylight-saving transition in the
#' output time zone become `NA`. Use `tz = "UTC"` for clock comparisons without
#' daylight-saving gaps.
#'
#' @param melidos_data A list returned by [load_data()] for multiple sites.
#' @param tz Output time zone for all `POSIXct` columns.
#' @param label_from Index of the dataset used to apply labels to the output.
#' @param time_mode Either `"clock"` (the backward-compatible default) or
#'   `"instant"`. See Details.
#'
#' @returns A tibble with all rows stacked and a `site` column.
#' @export
#'
#' @examples
#' example_multi_site <- structure(
#'   list(
#'     TUM = data.frame(id = 1, bedtime = as.POSIXct("2024-01-01 22:00:00", tz = "UTC")),
#'     UCR = data.frame(id = 2, bedtime = as.POSIXct("2024-01-02 22:30:00", tz = "UTC"))
#'   ),
#'   class = c("melidos_data", "list")
#' )
#'
#' flatten_data(example_multi_site, tz = "Europe/Berlin")
flatten_data <- function(
  melidos_data,
  tz = "UTC",
  label_from = 1,
  time_mode = c("clock", "instant")
) {
  stopifnot(
    "Input must be a list dataset loaded with `load_data()`" = inherits(
      melidos_data,
      "melidos_data"
    )
  )
  if (length(melidos_data) == 0L) {
    rlang::abort("`melidos_data` must contain at least one site.")
  }
  invalid <- !purrr::map_lgl(melidos_data, is.data.frame)
  if (any(invalid)) {
    sites <- names(melidos_data)
    if (is.null(sites)) sites <- as.character(seq_along(melidos_data))
    rlang::abort(paste0(
      "Cannot flatten missing or invalid site data: ",
      paste(sites[invalid], collapse = ", "),
      ". Reload these sites first."
    ))
  }
  if (
    length(label_from) != 1L ||
      !is.numeric(label_from) ||
      is.na(label_from) ||
      !is.finite(label_from) ||
      label_from < 1 ||
      label_from > length(melidos_data) ||
      label_from != as.integer(label_from)
  ) {
    rlang::abort(
      "`label_from` must be one valid integer index of `melidos_data`."
    )
  }
  if (
    !is.character(tz) || length(tz) != 1L || is.na(tz) || !tz %in% OlsonNames()
  ) {
    rlang::abort("`tz` must be one valid Olson time-zone name.")
  }
  time_mode <- rlang::arg_match(time_mode)
  convert_time <- if (time_mode == "clock") lubridate::force_tz else
    lubridate::with_tz

  labels_all <- melidos_data |> purrr::map(extract_labels)
  labels_identical <- purrr::map_lgl(
    labels_all,
    \(x) identical(x, labels_all[label_from][[1]])
  )
  if (!all(labels_identical) & !all(is.na(labels_all[[label_from]]))) {
    warning(
      "Not all labels across all sites were identical. Labels used from: ",
      melidos_data[label_from] |> names(),
      "; sites that have other labels: ",
      names(labels_identical |> subset(!labels_identical)) |>
        paste(collapse = ", ")
    )
  }
  labels_original <- labels_all[label_from]

  flattened_data <-
    melidos_data |>
    purrr::map(
      \(x)
        if (inherits(x, "data.frame")) {
          x |>
            dplyr::mutate(
              dplyr::across(
                dplyr::where(lubridate::is.POSIXct),
                \(y) convert_time(y, tzone = tz)
              )
            )
        } else x
    ) |>
    purrr::list_rbind(names_to = "site")

  result <- flattened_data |> add_labels(labels_original[[1]])
  attr(result, "melidos_sources") <- attr(melidos_data, "melidos_sources")
  result
}
