# Flatten multi-site MeLiDos data into one table

`flatten_data()` combines the named list returned by
[`load_data()`](https://melidosproject.github.io/melidosData/reference/load_data.md)
into one tibble and keeps site provenance in a `site` column.

## Usage

``` r
flatten_data(melidos_data, tz = "UTC", label_from = 1)
```

## Arguments

- melidos_data:

  A list returned by
  [`load_data()`](https://melidosproject.github.io/melidosData/reference/load_data.md)
  for multiple sites.

- tz:

  Time zone to enforce for all `POSIXct` columns.

- label_from:

  indice of the dataset that is used to apply labels to the output.

## Value

A tibble with all rows stacked and a `site` column.

## Details

If date-time columns are present (`POSIXct`), their timezone is
overwritten using
[`lubridate::force_tz()`](https://lubridate.tidyverse.org/reference/force_tz.html).

## Examples

``` r
example_multi_site <- structure(
  list(
    TUM = data.frame(id = 1, bedtime = as.POSIXct("2024-01-01 22:00:00", tz = "UTC")),
    UCR = data.frame(id = 2, bedtime = as.POSIXct("2024-01-02 22:30:00", tz = "UTC"))
  ),
  class = c("melidos_data", "list")
)

flatten_data(example_multi_site, tz = "Europe/Berlin")
#> # A tibble: 2 × 3
#>   site     id bedtime            
#>   <chr> <dbl> <dttm>             
#> 1 TUM       1 2024-01-01 22:00:00
#> 2 UCR       2 2024-01-02 22:30:00
```
