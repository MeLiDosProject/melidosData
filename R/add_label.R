#' Title
#'
#' @param data
#' @param label
#'
#' @returns
#' @export
#'
#' @examples
add_label <- function(data, label){
  attr(data, "label") <- label
  data
}

#' Title
#'
#' @param data
#' @param labels
#'
#' @returns
#' @export
#'
#' @examples
add_labels <- function(data, labels) {
  stopifnot(is.data.frame(data))
  stopifnot(is.character(labels) || is.list(labels))

  out <- purrr::imap(data, \(x, nm) {
    if (nm %in% names(labels)) add_label(x, labels[[nm]]) else x
  })

  tibble::as_tibble(out)   # or vctrs::list_cbind(out)
}
