#' Title
#'
#' @param codebook
#' @param data
#' @param indicator_POSIXct
#' @param indicator_date
#' @param indicator_time
#' @param indicator_logical
#' @param indicator_numeric.val_col
#' @param indicator_numeric.type_col
#' @param label_col
#' @param name_col
#' @param type_col
#' @param val_col
#'
#' @returns
#' @export
#'
#' @examples
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
  # --- expected columns by rule ---
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
      {{ val_col }} %in% indicator_time) |>
    dplyr::pull({{ name_col }}) |>
    unique() |>
    setdiff(should_POSIXct)

  should_character <-
    setdiff(
      unique(codebook |> dplyr::pull({{ name_col }})),
      c(should_numeric, should_POSIXct, should_logical,
        should_date, should_time, "startdate", "enddate")
    )

  expected_map <- tibble::tribble(
    ~col, ~expected,
    !!!c(rbind(should_POSIXct,  rep("POSIXct",    length(should_POSIXct))),
         rbind(should_numeric,  rep("numeric",    length(should_numeric))),
         rbind(should_logical,  rep("logical",    length(should_logical))),
         rbind(should_date,     rep("Date",       length(should_date))),
         rbind(should_time,     rep("time",       length(should_time))),
         rbind(should_character,rep("character",  length(should_character))))
  ) |>
    # The rbind trick can create a matrix; coerce cleanly:
    as.data.frame(stringsAsFactors = FALSE) |>
    tibble::as_tibble() |>
    mutate(col = .data$col, expected = .data$expected,
           .keep = "none") |>
    dplyr::distinct()

  # If nothing expected, return a trivial summary
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

  # --- helpers ---
  actual_class <- function(x) {
    # Return the first class; keep simple and stable for reporting
    class(x)[1]
  }

  is_expected_type <- function(x, expected) {
    switch(
      expected,
      "POSIXct"   = inherits(x, "POSIXct"),
      "numeric"   = is.numeric(x),
      "logical"   = is.logical(x),
      "Date"      = inherits(x, "Date"),
      "time"      = inherits(x, "hms"),
      "character" = is.character(x),
      FALSE
    )
  }

  data_names <- names(data)

  # --- build per-column diagnostics ---
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
        mapply(\(nm, exp) is_expected_type(data[[nm]], exp),
               .data$col, .data$expected),
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

  # --- grouped missing for convenience ---
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
