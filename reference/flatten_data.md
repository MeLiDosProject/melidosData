# Flatten multi-site MeLiDos data into one table

`flatten_data()` combines the named list returned by
[`load_data()`](https://melidosproject.github.io/melidosData/reference/load_data.md)
into one tibble and keeps site provenance in a `site` column.

## Usage

``` r
flatten_data(
  melidos_data,
  tz = "UTC",
  label_from = 1,
  time_mode = c("clock", "instant")
)
```

## Arguments

- melidos_data:

  A list returned by
  [`load_data()`](https://melidosproject.github.io/melidosData/reference/load_data.md)
  for multiple sites.

- tz:

  Output time zone for all `POSIXct` columns.

- label_from:

  Index of the dataset used to apply labels to the output.

- time_mode:

  Either `"clock"` (the backward-compatible default) or `"instant"`. See
  Details.

## Value

A tibble with all rows stacked and a `site` column.

## Details

The default preserves local clock readings using
[`lubridate::force_tz()`](https://lubridate.tidyverse.org/reference/force_tz.html).
This changes the represented instants and is intended for comparisons by
local clock time. Use `time_mode = "instant"` to preserve absolute
instants with
[`lubridate::with_tz()`](https://lubridate.tidyverse.org/reference/with_tz.html),
for example when aligning devices or diaries. Neither mode repairs
incorrectly parsed source timestamps. In clock mode, readings skipped by
a daylight-saving transition in the output time zone become `NA`. Use
`tz = "UTC"` for clock comparisons without daylight-saving gaps.

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
