#' Prepare a REDCap codebook for downstream processing
#'
#' Cleans HTML formatting from codebook labels and optionally filters the
#' codebook to selected REDCap forms.
#'
#' @param codebook A REDCap data dictionary as a data frame.
#' @param strings_to_ignore A regular expression used in
#'   [stringr::str_remove_all()] to remove formatting fragments from field labels.
#' @param form.filter Optional character vector of REDCap form names to keep.
#' @param field.label Unquoted column containing question labels.
#'
#' @return A cleaned codebook tibble/data frame.
#' @export
#'
#' @examples
#' codebook_path <- system.file("ext", "DataDictionary_sleepdiary.csv",
#'   package = "melidosData"
#' )
#' codebook <- utils::read.csv(codebook_path, check.names = FALSE)
#' cleaned <- REDCap_codebook_prepare(codebook)
#' names(cleaned)
REDCap_codebook_prepare <- function(codebook,
                                    strings_to_ignore = "<div class=\"rich-text-field-label\">|<span style=\"font-weight: normal;\">|<span style=\"text-decoration: underline;\">|</span>|<p>|<br />|<em>|</em>|</p>|</div>",
                                    form.filter = NULL,
                                    field.label = `Field Label`
                                    ) {
  if (!is.null(form.filter)) {
    codebook <-
      codebook |>
      dplyr::filter(`Form Name` %in% form.filter)
  }

  codebook |>
    dplyr::mutate(
      {{ field.label }} :=
        {{ field.label }} |>
        stringr::str_remove_all(strings_to_ignore)
    )
}
