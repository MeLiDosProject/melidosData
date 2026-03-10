parse_radio_levels <- function(levels_string, var_name = NULL, warn = TRUE) {
  # Convert "level, label | level, label" strings into paired vectors.
  if (is.na(levels_string) || levels_string == "") {
    if (warn) {
      warning("Missing radio levels for variable: ", var_name %||% "<unknown>")
    }
    return(NULL)
  }

  pairs <- strsplit(levels_string, " \\| ")[[1]]
  parsed <- lapply(pairs, function(pair) {
    parts <- strsplit(pair, ", ", fixed = TRUE)[[1]]
    if (length(parts) < 2) {
      return(NULL)
    }
    list(level = parts[[1]], label = paste(parts[-1], collapse = ", "))
  })

  parsed <- parsed[!vapply(parsed, is.null, logical(1))]
  if (length(parsed) == 0) {
    if (warn) {
      warning("Invalid radio levels string for variable: ", var_name %||% "<unknown>")
    }
    return(NULL)
  }

  list(
    levels = vapply(parsed, function(x) x$level, character(1)),
    labels = vapply(parsed, function(x) x$label, character(1))
  )
}

#' Title
#'
#' @param data
#' @param lookup
#' @param var_col
#' @param type_col
#' @param levels_col
#' @param radio_value
#' @param warn
#'
#' @returns
#' @export
#'
#' @examples
REDCap_factors <- function(data,
                              lookup,
                              var_col = var,
                              type_col = type,
                              levels_col = levels,
                              radio_value = c("checkbox", "radio"),
                              warn = TRUE) {
  var_col <- rlang::enquo(var_col)
  type_col <- rlang::enquo(type_col)
  levels_col <- rlang::enquo(levels_col)

  # Keep only the radio variables and parse their level/label strings.
  radio_lookup <- lookup |>
    dplyr::mutate(
      .var = as.character(!!var_col),
      .type = as.character(!!type_col),
      .levels = as.character(!!levels_col),
      .keep = "none"
    ) |>
    dplyr::filter(!is.na(.var), .var != "", .type %in% radio_value) %>%
    dplyr::distinct(.var, .keep_all = TRUE)

  levels_map <- stats::setNames(
    lapply(
      seq_len(nrow(radio_lookup)),
      function(i) {
        parse_radio_levels(
          radio_lookup$.levels[[i]],
          var_name = radio_lookup$.var[[i]],
          warn = warn
        )
      }
    ),
    radio_lookup$.var
  )

  vars_in_data <- intersect(names(levels_map), names(data))
  missing <- setdiff(names(levels_map), names(data))

  if (warn && length(missing) > 0) {
    warning("Variables provided but not in `data`: ",
            paste(missing, collapse = ", "))
  }

  data  |>
    dplyr::mutate(dplyr::across(dplyr::all_of(vars_in_data), ~{
      info <- levels_map[[cur_column()]]
      if (is.null(info)) {
        return(.x)
      }
      factor(as.character(.x), levels = info$levels, labels = info$labels)
    }))
}
