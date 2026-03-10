#' Add variable labels from a REDCap codebook
#'
#' Sets the `label` attribute on matching columns in `data`.
#'
#' @param data A data frame.
#' @param lookup A data frame with variable names and labels.
#' @param var_col Unquoted column in `lookup` containing variable names.
#' @param label_col Unquoted column in `lookup` containing human-readable
#'   labels.
#' @param warn Logical; warn when labels are provided for variables not present
#'   in `data`.
#'
#' @return `data` with `label` attributes added.
#' @export
#'
#' @examples
#' dict_path <- system.file("ext", "DataDictionary_sleepdiary.csv",
#'   package = "melidosData"
#' )
#' data_path <- system.file("ext", "example_sleepdiary.csv",
#'   package = "melidosData"
#' )
#' dict <- utils::read.csv(dict_path, check.names = FALSE)
#' dat <- utils::read.csv(data_path, check.names = FALSE)
#' labelled <- add_col_labels(dat, dict)
#' attr(labelled[[1]], "label")
add_col_labels <- function(data,
                           lookup,
                           var_col = `Variable / Field Name`,
                           label_col = `Field Label`,
                           warn = TRUE) {
  var_col <- rlang::enquo(var_col)
  label_col <- rlang::enquo(label_col)

  labs <- lookup |>
    dplyr::mutate(
      .var = as.character(!!var_col),
      .lab = as.character(!!label_col),
      .keep = "none"
    ) |>
    dplyr::filter(!is.na(.var), .var != "") |>
    dplyr::distinct(.var, .keep_all = TRUE) |>
    tibble::deframe()

  vars_in_data <- intersect(names(labs), names(data))
  missing <- setdiff(names(labs), names(data))

  if (warn && length(missing) > 0) {
    warning("Labels provided for variables not in `data`: ",
      paste(missing, collapse = ", ")
    )
  }

  data |>
    dplyr::mutate(
      dplyr::across(
        dplyr::all_of(vars_in_data),
        ~ {
          attr(.x, "label") <- labs[[dplyr::cur_column()]]
          .x
        }
      )
    )
}
