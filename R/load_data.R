#' Load MeLiDos datasets from project repositories
#'
#' `load_data()` is the main entry point of the package. It downloads one
#' modality from one or more MeLiDos sites and returns either a single data
#' frame (one site) or a named list with class `"melidos_data"` (multiple sites).
#'
#' Use [flatten_data()] to stack multi-site results into one tibble with a
#' `site` column.
#'
#' See the README of the package for a description of sites and modalities.
#'
#' @param modality Dataset to load.
#' @param site Site(s) to load. Use `"all"` for all available sites.
#'
#' @returns
#' A data frame when one site is selected, or a `melidos_data` list for multiple
#' sites.
#' @export
#' @source https://github.com/MeLiDosProject
#'
#' @examples
#' \dontrun{
#' # load one questionnaire modality for all sites
#' sleep_all <- load_data("sleepdiaries", site = "all")
#'
#' # flatten to a single tibble with a site column
#' sleep_flat <- flatten_data(sleep_all, tz = "UTC")
#' head(sleep_flat)
#'
#' # load one site only (returns a data frame)
#' sleep_tum <- load_data("sleepdiaries", site = "TUM")
#' }
load_data <- function(
    modality = c("light_glasses", "light_chest", "light_wrist",
                 "light_glasses_1minute", "light_chest_1minute", "light_wrist_1minute",
                 "acceptability", "ase", "chronotype", "demographics",
                 "evaluation", "health", "leba", "trial_times", "vlsq8",
                 "currentconditions", "exercisediary", "experiencelog",
                 "lightexposurediary", "sleepdiaries", "wearlog", "wellbeingdiary"),
    site = c("all", "BAUA", "FUSPCEU", "IZTECH", "KNUST", "MPI",
             "RISE", "THUAS", "TUM", "UCR")
) {

  modality <- rlang::arg_match(modality)
  site <- rlang::arg_match(site, multiple = TRUE)
  if("all" %in% site) {
    site <- c("BAUA", "FUSPCEU", "IZTECH", "KNUST", "MPI",
              "RISE", "THUAS", "TUM", "UCR")
  }

  if(modality %in% c("light_chest", "light_chest_1minute",
                     "light_wrist", "light_wrist_1minute")) {
    if("MPI" %in% site) {
      site <- setdiff(site, "MPI")
      message("Remove site MPI, as there were no chest-worn devices, and a different type of wrist-worn devices")
    }
  }

  if(modality %in% c("light_chest", "light_wrist", "light_glasses")) {
      message("These datasets are comparatively large (~50MB per site). Download may take a while.")
  }

  base_url_pt1 <- "https://raw.githubusercontent.com/MeLiDosProject/"
  base_url_pt3 <- "/main/data/imported/"
  base_url_pt4 <-
    if(modality %in% c("light_glasses", "light_chest", "light_wrist",
                       "light_glasses_1minute", "light_chest_1minute",
                       "light_wrist_1minute")) {
      "light/"
    } else if (modality %in% c("currentconditions", "exercisediary", "experiencelog",
                               "lightexposurediary", "sleepdiaries", "wearlog",
                               "wellbeingdiary")) {
      "continuous/"
    } else ""
  base_url_end <- ".RData"

  url_strings <-
    site |>
    rlang::set_names() |>
    purrr::map_chr(
      \(x) paste0(base_url_pt1, lookuptable[x],
                  base_url_pt3, base_url_pt4, modality, base_url_end)
      )

  if(modality == "sleepdiaries") {
    modality <- "sleepdiary"
  }
  if(stringr::str_detect(modality, "1minute")) {
    modality <- stringr::str_replace(modality,"1minute", "1min")
  }

  loaded_data <-
  url_strings |>
  purrr::map(
    \(x) {
      try(load(url(x)))
      if(exists(modality)) {
        get(modality)
        } else return()
      },
    .progress = paste0("loading modality: ", modality)
  )

  if(length(loaded_data) == 1) return(loaded_data[[1]]) else {
  class(loaded_data) <- c("melidos_data", class(loaded_data))
  loaded_data
  }
}

lookuptable <- c(BAUA = "BroszioEtAl_Dataset_2025",
                 FUSPCEU = "BaezaEtAl_Dataset_2025",
                 IZTECH = "DidikogluEtAl_Dataset_2025",
                 KNUST = "AkuffoEtAl_Dataset_2025",
                 MPI = "GuidolinEtAl_Dataset_2025",
                 RISE = "NilssonTengelinEtAl_Dataset_2026",
                 THUAS = "AertsEtAl_Dataset_2025",
                 TUM = "HildenEtAl_Dataset_2025",
                 UCR = "Sancho-SalasEtAl_Dataset_2025")

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
flatten_data <- function(melidos_data, tz = "UTC"){
  stopifnot("Input must be a list dataset loaded with `load_data()`" =
              inherits(melidos_data, "melidos_data"))
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
}
