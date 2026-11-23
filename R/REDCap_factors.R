parse_radio_levels <- function(levels_string, var_name = NULL, warn = TRUE) {
  if (is.na(levels_string) || levels_string == "") {
    if (warn) {
      warning("Missing radio levels for variable: ", var_name %||% "<unknown>")
    }
    return(NULL)
  }

  pairs <- strsplit(levels_string, " \\| ")[[1]]
  parsed <- purrr::map(pairs, function(pair) {
    parts <- strsplit(pair, ", ", fixed = TRUE)[[1]]
    if (length(parts) < 2) {
      return(NULL)
    }
    list(level = parts[[1]], label = paste(parts[-1], collapse = ", "))
  })

  parsed <- parsed[!vapply(parsed, is.null, logical(1))]
  if (length(parsed) == 0) {
    if (warn) {
      warning(
        "Invalid radio levels string for variable: ",
        var_name %||% "<unknown>"
      )
    }
    return(NULL)
  }

  list(
    levels = vapply(parsed, function(x) x$level, character(1)),
    labels = vapply(parsed, function(x) x$label, character(1))
  )
}

#' Convert REDCap choice fields to factors
#'
#' Applies factor levels and labels using REDCap dictionary definitions for
#' `radio` and `checkbox` fields (configurable via `radio_value`).
#' Expanded checkbox columns named `field___code` or `field_code` are kept
#' separate and converted from 0/1 (or logical) to `Unchecked`/`Checked`
#' factors. Their `checkbox_choice` attribute records the dictionary choice.
#' Missing values remain missing; invalid binary values raise an error.
#' An existing unexpanded choice column retains the legacy radio-style
#' conversion. A single factor cannot represent several checkbox selections.
#'
#' @param data Data frame containing REDCap records.
#' @param lookup Data frame containing variable metadata.
#' @param var_col Unquoted column in `lookup` with variable names.
#' @param type_col Unquoted column in `lookup` with REDCap field types.
#' @param levels_col Unquoted column in `lookup` with coded levels
#'   (`"1, Yes | 0, No"` format).
#' @param radio_value Character vector of field types to convert.
#' @param warn Logical; warn when variables are in `lookup` but absent from
#'   `data`.
#'
#' @return `data` with selected columns converted to factors.
#' @export
#'
#' @examples
#' dict_path <- system.file("ext", "DataDictionary_chronotype.csv",
#'   package = "melidosData"
#' )
#' dict <- utils::read.csv(dict_path, check.names = FALSE)
#' dict <- REDCap_codebook_prepare(dict, form.filter = "mctq")
#'
#' chronotype_with_factors <-
#' REDCap_factors(
#'   data = REDCap_example_chronotype,
#'   lookup = dict
#' )
#'
#' chronotype_with_factors$mctq_work_travel
#' #original:
#' REDCap_example_chronotype$mctq_work_travel
REDCap_factors <- function(
  data,
  lookup,
  var_col = `Variable / Field Name`,
  type_col = `Field Type`,
  levels_col = `Choices, Calculations, OR Slider Labels`,
  radio_value = c("checkbox", "radio"),
  warn = TRUE
) {
  var_col <- rlang::enquo(var_col)
  type_col <- rlang::enquo(type_col)
  levels_col <- rlang::enquo(levels_col)

  radio_lookup <- lookup |>
    dplyr::mutate(
      .var = as.character(!!var_col),
      .type = as.character(!!type_col),
      .levels = as.character(!!levels_col),
      .keep = "none"
    ) |>
    dplyr::filter(!is.na(.var), .var != "", .type %in% radio_value) |>
    dplyr::distinct(.var, .keep_all = TRUE)

  levels_map <- stats::setNames(
    purrr::map(
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

  found <- character()
  for (i in seq_len(nrow(radio_lookup))) {
    variable <- radio_lookup$.var[[i]]
    info <- levels_map[[variable]]
    if (is.null(info)) next
    if (variable %in% names(data)) {
      label <- attr(data[[variable]], "label", exact = TRUE)
      data[[variable]] <- factor(
        as.character(data[[variable]]),
        levels = info$levels,
        labels = info$labels
      )
      attr(data[[variable]], "label") <- label
      found <- union(found, variable)
    }
    if (radio_lookup$.type[[i]] != "checkbox") next
    for (j in seq_along(info$levels)) {
      columns <- intersect(
        paste0(variable, c("___", "_"), info$levels[[j]]),
        names(data)
      )
      for (column in columns) {
        value <- data[[column]]
        label <- attr(value, "label", exact = TRUE)
        if (is.logical(value)) value <- as.integer(value)
        value <- as.character(value)
        value[value == "Unchecked"] <- "0"
        value[value == "Checked"] <- "1"
        if (any(!is.na(value) & !value %in% c("0", "1"))) {
          rlang::abort(paste0(
            "Checkbox column `",
            column,
            "` must contain 0, 1, logical values, or missing values."
          ))
        }
        data[[column]] <- factor(
          value,
          levels = c("0", "1"),
          labels = c("Unchecked", "Checked")
        )
        attr(data[[column]], "label") <- label
        attr(data[[column]], "checkbox_choice") <- info$labels[[j]]
        found <- union(found, variable)
      }
    }
  }
  missing <- setdiff(names(levels_map), found)

  if (warn && length(missing) > 0) {
    warning(
      "Variables provided but not in `data`: ",
      paste(missing, collapse = ", ")
    )
  }

  data
}
