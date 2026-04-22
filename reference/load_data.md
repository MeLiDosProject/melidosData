# Load MeLiDos datasets from project repositories

`load_data()` is the main entry point of the package. It downloads one
modality from one or more MeLiDos sites and returns either a single data
frame (one site) or a named list with class `"melidos_data"` (multiple
sites).

## Usage

``` r
load_data(
  modality = c("light_glasses", "light_chest", "light_wrist", "light_glasses_1minute",
    "light_chest_1minute", "light_wrist_1minute", "acceptability", "ase", "chronotype",
    "demographics", "evaluation", "health", "leba", "trial_times", "vlsq8",
    "currentconditions", "exercisediary", "experiencelog", "lightexposurediary",
    "sleepdiaries", "wearlog", "wellbeingdiary"),
  site = c("all", "BAUA", "FUSPCEU", "IZTECH", "KNUST", "MPI", "RISE", "THUAS", "TUM",
    "UCR")
)
```

## Source

https://github.com/MeLiDosProject

## Arguments

- modality:

  Dataset to load.

- site:

  Site(s) to load. Use `"all"` for all available sites.

## Value

A data frame when one site is selected, or a `melidos_data` list for
multiple sites.

## Details

Use
[`flatten_data()`](https://melidosproject.github.io/melidosData/reference/flatten_data.md)
to stack multi-site results into one tibble with a `site` column.

See the README of the package for a description of sites and modalities.

## Examples

``` r
# load one questionnaire modality for two sites
sleep_all <- load_data("sleepdiaries", site = c("TUM", "RISE"))

# flatten to a single tibble with a site column
sleep_flat <- flatten_data(sleep_all, tz = "UTC")
#> Warning: Not all labels across all sites were identical. Labels used from: TUM; sites that have other labels: RISE
head(sleep_flat)
#> # A tibble: 6 × 15
#>   site  Id       bedtime             sleepprep           wake               
#>   <chr> <chr>    <dttm>              <dttm>              <dttm>             
#> 1 TUM   TUM_S001 2024-05-14 00:00:00 2024-05-14 00:15:00 2024-05-14 09:38:00
#> 2 TUM   TUM_S001 2024-05-15 00:15:00 2024-05-15 00:15:00 2024-05-15 08:00:00
#> 3 TUM   TUM_S001 2024-05-16 00:30:00 2024-05-16 00:30:00 2024-05-16 10:00:00
#> 4 TUM   TUM_S001 2024-05-17 01:00:00 2024-05-17 01:15:00 2024-05-17 09:30:00
#> 5 TUM   TUM_S001 2024-05-18 00:20:00 2024-05-18 00:30:00 2024-05-18 09:30:00
#> 6 TUM   TUM_S001 2024-05-19 05:15:00 2024-05-19 05:30:00 2024-05-19 11:30:00
#> # ℹ 10 more variables: out_ofbed <dttm>, sleepdelay <dbl>, awakenings <dbl>,
#> #   awake_duration <dbl>, sleepquality <fct>, daytype2 <fct>, comments <chr>,
#> #   sleep <dttm>, sleep_duration <drtn>, comments_english <chr>

# load one site only (returns a data frame)
sleep_tum <- load_data("sleepdiaries", site = "TUM")
```
