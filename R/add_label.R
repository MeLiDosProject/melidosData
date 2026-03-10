#' Add a `label` attribute to a vector
#'
#' @param data Vector-like object.
#' @param label Label text.
#'
#' @return `data` with a `label` attribute.
#' @export
#'
#' @examples
#' add_label(1:3, "Example variable")
add_label <- function(data, label) {
  attr(data, "label") <- label
  data
}

#' Add labels to selected data frame columns
#'
#' @param data A data frame.
#' @param labels Named character vector or named list of labels.
#'
#' @return A tibble with column-level `label` attributes where names matched.
#' @export
#'
#' @examples
#' dat <- data.frame(a = 1:2, b = 3:4)
#' labelled <- add_labels(dat, c(a = "Column A"))
#' attr(labelled$a, "label")
#' attr(labelled$b, "label")
add_labels <- function(data, labels) {
  stopifnot(is.data.frame(data))
  stopifnot(is.character(labels) || is.list(labels))

  out <- data
  nms <- names(out)

  for (nm in nms) {
    if (nm %in% names(labels)) {
      out[[nm]] <- add_label(out[[nm]], labels[[nm]])
    }
  }

  tibble::as_tibble(out)
}
