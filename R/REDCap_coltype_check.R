#' Check data column classes against REDCap expectations
#'
#' Uses REDCap codebook metadata to infer expected classes and compares these to
#' classes in `data`.
#'
#' @param codebook REDCap data dictionary.
#' @param indicator_POSIXct Indicator in `val_col` identifying datetime fields.
#' @param indicator_date Pattern used in labels to identify date variables.
#' @param indicator_time Indicator in `val_col` identifying time-only fields.
#' @param indicator_logical Indicator in `type_col` identifying logical fields.
#' @param indicator_numeric.val_col Indicators in `val_col` for numeric fields.
#' @param indicator_numeric.type_col Indicators in `type_col` for numeric fields.
#' @param label_col Unquoted codebook label column.
#' @param name_col Unquoted codebook variable-name column.
#' @param type_col Unquoted codebook field-type column.
#' @param val_col Unquoted codebook validation/type-hint column.
#' @param data Data frame to validate.
#'
#' @return A list with `ok`, `summary`, and per-column `details`.
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
#' REDCap_coltype_check(dict, data = dat)$ok
REDCap_coltype_check <- function(codebook,
                                 indicator_POSIXct = "datetime_dmy",
                                 indicator_date = "Date",
                                 indicator_time = "time",
                                 indicator_logical = "yesno",
                                 indicator_numeric.val_col = c("number", "integer"),
                                 indicator_numeric.type_col = c("radio", "dropdown"),
                                 label_col = `Field Label`,
                                 name_col = `Variable / Field Name`,
                                 type_col = `Field Type`,
                                 val_col = `Text Validation Type OR Show Slider Number`,
                                 data) {
  should_POSIXct <-
    codebook |>
    dplyr::filter({{ val_col }} %in% indicator_POSIXct) |>
    dplyr::pull({{ name_col }}) |>
    unique()

  should_logical <-
    codebook |>
    dplyr::filter(
      {{ type_col }} %in% indicator_logical
    ) |>
    dplyr::pull({{ name_col }}) |>
    unique()

  should_numeric <-
    codebook |>
    dplyr::filter(
      {{ val_col }} %in% indicator_numeric.val_col |
        {{ type_col }} %in% indicator_numeric.type_col
    ) |>
    dplyr::pull({{ name_col }}) |>
    unique()

  should_date <-
    codebook |>
    dplyr::filter(stringr::str_detect({{ label_col }}, indicator_date)) |>
    dplyr::pull({{ name_col }}) |>
    unique() |>
    setdiff(c("startdate", "enddate"))

  should_time <-
    codebook |>
    dplyr::filter(
      {{ val_col }} %in% indicator_time
    ) |>
    dplyr::pull({{ name_col }}) |>
    unique() |>
    setdiff(should_POSIXct)

  should_character <-
    setdiff(
      unique(codebook |> dplyr::pull({{ name_col }})),
      c(
        should_numeric, should_POSIXct, should_logical,
        should_date, should_time, "startdate", "enddate"
      )
    )

  expected_map <- tibble::tribble(
    ~col, ~expected,
    !!!c(
      rbind(should_POSIXct, rep("POSIXct", length(should_POSIXct))),
      rbind(should_numeric, rep("numeric", length(should_numeric))),
      rbind(should_logical, rep("logical", length(should_logical))),
      rbind(should_date, rep("Date", length(should_date))),
      rbind(should_time, rep("time", length(should_time))),
      rbind(should_character, rep("character", length(should_character)))
    )
  ) |>
    as.data.frame(stringsAsFactors = FALSE) |>
    tibble::as_tibble() |>
    dplyr::mutate(
      col = .data$col,
      expected = .data$expected,
      .keep = "none"
    ) |>
    dplyr::distinct()

  if (nrow(expected_map) == 0) {
    return(list(
      ok = TRUE,
      summary = list(
        missing = character(0),
        wrong_type = tibble::tibble(),
        ok = character(0)
      ),
      details = tibble::tibble()
    ))
  }

  actual_class <- function(x) {
    class(x)[1]
  }

  is_expected_type <- function(x, expected) {
    switch(
      expected,
      "POSIXct" = inherits(x, "POSIXct"),
      "numeric" = is.numeric(x),
      "logical" = is.logical(x),
      "Date" = inherits(x, "Date"),
      "time" = inherits(x, "hms"),
      "character" = is.character(x),
      FALSE
    )
  }

  data_names <- names(data)

  details <- expected_map |>
    dplyr::mutate(
      present = .data$col %in% data_names,
      actual = dplyr::if_else(
        present,
        vapply(.data$col, \(nm) actual_class(data[[nm]]), character(1)),
        NA_character_
      ),
      type_ok = dplyr::if_else(
        present,
        mapply(
          \(nm, exp) is_expected_type(data[[nm]], exp),
          .data$col,
          .data$expected
        ),
        FALSE
      ),
      issue = dplyr::case_when(
        !present ~ "missing",
        present & !type_ok ~ "wrong_type",
        TRUE ~ "ok"
      )
    )

  missing <- details |> dplyr::filter(issue == "missing") |> dplyr::pull(col)
  ok_cols <- details |> dplyr::filter(issue == "ok") |> dplyr::pull(col)

  wrong_type <- details |>
    dplyr::filter(issue == "wrong_type") |>
    dplyr::mutate(
      col,
      expected_type = expected,
      actual_type = actual,
      .keep = "none"
    )

  missing_by_expected <- details |>
    dplyr::filter(issue == "missing") |>
    dplyr::group_by(expected) |>
    dplyr::summarise(cols = list(col), .groups = "drop")

  out <- list(
    ok = length(missing) == 0 && nrow(wrong_type) == 0,
    summary = list(
      missing = missing,
      missing_by_expected = missing_by_expected,
      wrong_type = wrong_type,
      ok = ok_cols
    ),
    details = details
  )

  class(out) <- c("coltype_check", class(out))
  out
}
