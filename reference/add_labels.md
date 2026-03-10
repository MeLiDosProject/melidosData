# Add labels to selected data frame columns

Add labels to selected data frame columns

## Usage

``` r
add_labels(data, labels)
```

## Arguments

- data:

  A data frame.

- labels:

  Named character vector or named list of labels.

## Value

A tibble with column-level `label` attributes where names matched.

## Examples

``` r
dat <- data.frame(a = 1:2, b = 3:4)
labelled <- add_labels(dat, c(a = "Column A"))
attr(labelled$a, "label")
#> [1] "Column A"
attr(labelled$b, "label")
#> NULL
```
