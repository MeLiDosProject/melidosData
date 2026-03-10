#' Title
#'
#' @param data
#' @param check.column
#' @param condition
#' @param label
#'
#' @returns
#' @export
#'
#' @examples
REDCap_attention_check <-
  function(data, check.column, condition, label = "Attention check successful") {
    data <-
      data |>
      dplyr::mutate({{ check.column }} :=
               ({{ check.column }} %in% condition) |>
               add_label(label)
      ) |>
      dplyr::relocate({{ check.column }}, .after = dplyr::last_col())
  }
