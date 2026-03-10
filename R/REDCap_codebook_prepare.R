#' Title
#'
#' @param codebook
#' @param strings_to_ignore
#' @param form.filter
#' @param field.label
#'
#' @returns
#' @export
#'
#' @examples
REDCap_codebook_prepare <- function(codebook,
                                    strings_to_ignore = "<div class=\"rich-text-field-label\">|<span style=\"font-weight: normal;\">|<span style=\"text-decoration: underline;\">|</span>|<p>|<br />|<em>|</em>|</p>|</div>",
                                    form.filter = NULL,
                                    field.label = `Field Label`
                                    ) {
  if(!is.null(form.filter)){
    #filter relevant columns
    codebook <-
      codebook |> dplyr::filter(`Form Name` %in% form.filter)
  }

  #clean up labels
  codebook <-
    codebook |>
    dplyr::mutate(
      {{ field.label }} :=
        {{ field.label }} |>
        stringr::str_remove_all(strings_to_ignore)
    )
  codebook
}
