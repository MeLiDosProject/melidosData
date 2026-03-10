#' Evaluate a REDCap attention check column
#'
#' Replaces a column with a logical pass/fail value based on membership in
#' `condition`, sets a label attribute, and moves the column to the end.
#'
#' @param data A data frame.
#' @param check.column Unquoted column to evaluate.
#' @param condition Vector of accepted responses.
#' @param label Label to attach to the resulting logical column.
#'
#' @return `data` with an updated attention check column.
#' @export
#'
#' @examples
#' dat <- data.frame(attention = c("A", "B", "A"))
#' REDCap_attention_check(dat, attention, condition = "A")
REDCap_attention_check <-
  function(data, check.column, condition, label = "Attention check successful") {
    data |>
      dplyr::mutate(
        {{ check.column }} :=
          ({{ check.column }} %in% condition) |>
            add_label(label)
      ) |>
      dplyr::relocate({{ check.column }}, .after = dplyr::last_col())
  }
