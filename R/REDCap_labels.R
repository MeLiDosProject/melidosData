
#' Title
#'
#' @param data
#' @param lookup
#' @param var_col
#' @param label_col
#' @param warn
#'
#' @returns
#' @export
#'
#' @examples
add_col_labels <- function(data,
                           lookup,
                           var_col = `Variable / Field Name`,
                           label_col = `Field Label`,
                           warn = TRUE) {
  var_col   <- rlang::enquo(var_col)
  label_col <- rlang::enquo(label_col)

  # Named vector: names = variable names, values = labels
  labs <- lookup |>
    dplyr::mutate(.var = as.character(!!var_col),
                  .lab = as.character(!!label_col),
                  .keep = "none") |>
    dplyr::filter(!is.na(.var), .var != "") |>
    dplyr::distinct(.var, .keep_all = TRUE) |>
    tibble::deframe()

  vars_in_data <- intersect(names(labs), names(data))
  missing      <- setdiff(names(labs), names(data))

  if (warn && length(missing) > 0) {
    warning("Labels provided for variables not in `data`: ",
            paste(missing, collapse = ", "))
  }

  data |>
    dplyr::mutate(
      dplyr::across(
        dplyr::all_of(vars_in_data),
        ~{
      attr(.x, "label") <- labs[[dplyr::cur_column()]]
      .x
    }))
}
