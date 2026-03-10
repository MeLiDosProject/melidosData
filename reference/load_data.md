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
    "demographics", "evaluation", "health", "leba", "vlsq8", "currentconditions",
    "exercisediary", "experiencelog", "lightexposurediary", "sleepdiaries", "wearlog",
    "wellbeingdiary"),
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
if (FALSE) { # \dontrun{
# load one questionnaire modality for all sites
sleep_all <- load_data("sleepdiaries", site = "all")

# flatten to a single tibble with a site column
sleep_flat <- flatten_data(sleep_all, tz = "UTC")
head(sleep_flat)

# load one site only (returns a data frame)
sleep_tum <- load_data("sleepdiaries", site = "TUM")
} # }
```
