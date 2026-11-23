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
#' @param ref Git revision to download: a branch, tag, or commit SHA. Supply one
#'   revision for all sites, or a named character vector with one revision per
#'   selected site. Use full commit SHAs for reproducible inputs. The default
#'   `"main"` follows the current repository contents.
#' @param on_failure Whether a failed download, missing object, or invalid
#'   object should stop (`"error"`, the default) or warn and retain a `NULL`
#'   entry (`"warn"`). Expected unavailable MPI modalities are still omitted.
#'
#' @returns
#' A data frame when one site is loaded successfully, or a `melidos_data` list
#' for multiple sites. With `on_failure = "warn"`, a failed single site returns
#' a one-element `melidos_data` list containing `NULL`. If all selected sites
#' are unavailable for the modality, an empty `melidos_data` list is returned.
#' The `melidos_sources` attribute records each attempted site's
#' repository, revision, URL, expected object, and load status. Branch names
#' are recorded as requested and are not resolved to immutable commits.
#' @export
#' @source https://github.com/MeLiDosProject
#'
#' @examplesIf interactive()
#' # load one questionnaire modality for two sites
#' sleep_all <- load_data("sleepdiaries", site = c("TUM", "RISE"))
#'
#' # flatten to a single tibble with a site column
#' sleep_flat <- flatten_data(sleep_all, tz = "UTC")
#' head(sleep_flat)
#'
#' # load one site only (returns a data frame)
#' sleep_tum <- load_data("sleepdiaries", site = "TUM")
load_data <- function(
  modality = c(
    "light_glasses",
    "light_chest",
    "light_wrist",
    "light_glasses_1minute",
    "light_chest_1minute",
    "light_wrist_1minute",
    "acceptability",
    "ase",
    "chronotype",
    "demographics",
    "evaluation",
    "health",
    "leba",
    "trial_times",
    "vlsq8",
    "currentconditions",
    "exercisediary",
    "experiencelog",
    "lightexposurediary",
    "sleepdiaries",
    "wearlog",
    "wellbeingdiary"
  ),
  site = c(
    "all",
    "BAUA",
    "FUSPCEU",
    "IZTECH",
    "KNUST",
    "MPI",
    "RISE",
    "THUAS",
    "TUM",
    "UCR"
  ),
  ref = "main",
  on_failure = c("error", "warn")
) {
  modality <- rlang::arg_match(modality)
  site <- rlang::arg_match(site, multiple = TRUE)
  on_failure <- rlang::arg_match(on_failure)
  if ("all" %in% site) {
    site <- c(
      "BAUA",
      "FUSPCEU",
      "IZTECH",
      "KNUST",
      "MPI",
      "RISE",
      "THUAS",
      "TUM",
      "UCR"
    )
  }

  if (modality %in% c("health")) {
    if ("MPI" %in% site) {
      site <- setdiff(site, "MPI")
      message("Remove site MPI, as there was no health-related questionnaire")
    }
  }

  if (
    modality %in%
      c(
        "light_chest",
        "light_chest_1minute",
        "light_wrist",
        "light_wrist_1minute"
      )
  ) {
    if ("MPI" %in% site) {
      site <- setdiff(site, "MPI")
      message(
        "Remove site MPI, as there were no chest-worn devices, and a different type of wrist-worn devices"
      )
    }
  }

  if (modality %in% c("light_chest", "light_wrist", "light_glasses")) {
    message(
      "These datasets are comparatively large (~50MB per site). Download may take a while."
    )
  }

  base_url_pt1 <- "https://raw.githubusercontent.com/MeLiDosProject/"
  refs <- resolve_source_refs(ref, site)
  base_url_pt4 <-
    if (
      modality %in%
        c(
          "light_glasses",
          "light_chest",
          "light_wrist",
          "light_glasses_1minute",
          "light_chest_1minute",
          "light_wrist_1minute"
        )
    ) {
      "light/"
    } else if (
      modality %in%
        c(
          "currentconditions",
          "exercisediary",
          "experiencelog",
          "lightexposurediary",
          "sleepdiaries",
          "wearlog",
          "wellbeingdiary"
        )
    ) {
      "continuous/"
    } else ""
  base_url_end <- ".RData"

  url_strings <-
    site |>
    rlang::set_names() |>
    purrr::map_chr(
      \(x)
        paste0(
          base_url_pt1,
          lookuptable[x],
          "/",
          utils::URLencode(refs[[x]], reserved = TRUE),
          "/data/imported/",
          base_url_pt4,
          modality,
          base_url_end
        )
    )

  if (modality == "sleepdiaries") {
    modality <- "sleepdiary"
  }
  if (stringr::str_detect(modality, "1minute")) {
    modality <- stringr::str_replace(modality, "1minute", "1min")
  }

  loaded_data <-
    url_strings |>
    purrr::map(
      \(x)
        tryCatch(
          load_remote_rdata(x, modality),
          melidos_data_load_error = function(error) {
            if (on_failure == "error") stop(error)
            warning(conditionMessage(error), call. = FALSE)
            NULL
          }
        ),
      .progress = paste0("loading modality: ", modality)
    )

  sources <- tibble::tibble(
    site = site,
    repository = unname(lookuptable[site]),
    revision = unname(refs),
    url = unname(url_strings),
    object = rep(modality, length(site)),
    status = unname(dplyr::if_else(
      purrr::map_lgl(loaded_data, is.null),
      "failed",
      "loaded"
    ))
  )
  if (length(loaded_data) == 1L && !is.null(loaded_data[[1L]])) {
    result <- loaded_data[[1L]]
    attr(result, "melidos_sources") <- sources
    return(result)
  } else {
    class(loaded_data) <- c("melidos_data", class(loaded_data))
    attr(loaded_data, "melidos_sources") <- sources
    loaded_data
  }
}


resolve_source_refs <- function(ref, site) {
  if (
    !is.character(ref) ||
      length(ref) == 0L ||
      anyNA(ref) ||
      any(!nzchar(trimws(ref)))
  ) {
    rlang::abort("`ref` must contain nonempty Git revisions.")
  }
  if (is.null(names(ref)) && length(ref) == 1L) {
    return(stats::setNames(rep(ref, length(site)), site))
  }
  if (
    is.null(names(ref)) ||
      anyNA(names(ref)) ||
      any(!nzchar(names(ref))) ||
      anyDuplicated(names(ref)) ||
      !all(site %in% names(ref))
  ) {
    rlang::abort(
      "`ref` must be a single unnamed revision or have one named revision per selected site."
    )
  }
  ref[site]
}

load_remote_rdata <- function(url_string, object_name) {
  data_env <- new.env(parent = emptyenv())
  tryCatch(
    {
      con <- url(url_string, open = "rb")
      on.exit(close(con), add = TRUE)
      load(con, envir = data_env)
      if (!exists(object_name, envir = data_env, inherits = FALSE)) {
        stop(sprintf("Expected object `%s` is absent.", object_name))
      }
      result <- data_env[[object_name]]
      if (!is.data.frame(result)) {
        stop(sprintf(
          "Expected object `%s` must be a data frame; found %s.",
          object_name,
          paste(class(result), collapse = "/")
        ))
      }
      result
    },
    error = function(error) {
      rlang::abort(
        paste0(
          "Could not load `",
          object_name,
          "` from ",
          url_string,
          ": ",
          conditionMessage(error)
        ),
        class = "melidos_data_load_error",
        parent = error
      )
    }
  )
}

lookuptable <- c(
  BAUA = "BroszioEtAl_Dataset_2025",
  FUSPCEU = "BaezaEtAl_Dataset_2025",
  IZTECH = "DidikogluEtAl_Dataset_2025",
  KNUST = "AkuffoEtAl_Dataset_2025",
  MPI = "GuidolinEtAl_Dataset_2025",
  RISE = "NilssonTengelinEtAl_Dataset_2026",
  THUAS = "AertsEtAl_Dataset_2025",
  TUM = "HildenEtAl_Dataset_2025",
  UCR = "Sancho-SalasEtAl_Dataset_2025"
)
