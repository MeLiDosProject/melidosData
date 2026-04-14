#' Flatten multi-site MeLiDos data into one table
#'
#' `flatten_data()` combines the named list returned by [load_data()] into one
#' tibble and keeps site provenance in a `site` column.
#'
#' If date-time columns are present (`POSIXct`), their timezone is overwritten
#' using [lubridate::force_tz()].
#'
#' @param melidos_data A list returned by [load_data()] for multiple sites.
#' @param tz Time zone to enforce for all `POSIXct` columns.
#' @param label_from indice of the dataset that is used to apply labels to the output.
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
flatten_data <- function(melidos_data, tz = "UTC", label_from = 1){
  stopifnot("Input must be a list dataset loaded with `load_data()`" =
              inherits(melidos_data, "melidos_data"),
            "label_from must be an indice of melidos_data" = label_from <= length(melidos_data))

  labels_all <- melidos_data |> purrr::map(extract_labels)
  # browser()
  labels_identical <- purrr::map_lgl(labels_all, \(x) identical(x, labels_all[label_from][[1]]))
  if(!all(labels_identical) & !all(is.na(labels_all[[label_from]]))) {
    warning(
      "Not all labels across all sites were identical. Labels used from: ",
      melidos_data[label_from] |> names(),
      "; sites that have other labels: ", names(labels_identical |> subset(!labels_identical)) |> paste(collapse = ", ")
    )
  }
  labels_original <- labels_all[label_from]


  flattened_data <-
  melidos_data |>
    purrr::map(
      \(x) if(inherits(x, "data.frame")) {
        x |>
          dplyr::mutate(
            dplyr::across(
              dplyr::where(lubridate::is.POSIXct),
              \(y) lubridate::force_tz(y, tz)
            )
          )
      } else x
    ) |>
    purrr::list_rbind(names_to = "site")

  flattened_data |> add_labels(labels_original[[1]])
}
