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
    "UCR"),
  ref = "main",
  on_failure = c("error", "warn")
)
```

## Source

https://github.com/MeLiDosProject

## Arguments

- modality:

  Dataset to load.

- site:

  Site(s) to load. Use `"all"` for all available sites.

- ref:

  Git revision to download: a branch, tag, or commit SHA. Supply one
  revision for all sites, or a named character vector with one revision
  per selected site. Use full commit SHAs for reproducible inputs. The
  default `"main"` follows the current repository contents.

- on_failure:

  Whether a failed download, missing object, or invalid object should
  stop (`"error"`, the default) or warn and retain a `NULL` entry
  (`"warn"`). Expected unavailable MPI modalities are still omitted.

## Value

A data frame when one site is loaded successfully, or a `melidos_data`
list for multiple sites. With `on_failure = "warn"`, a failed single
site returns a one-element `melidos_data` list containing `NULL`. If all
selected sites are unavailable for the modality, an empty `melidos_data`
list is returned. The `melidos_sources` attribute records each attempted
site's repository, revision, URL, expected object, and load status.
Branch names are recorded as requested and are not resolved to immutable
commits.

## Details

Use
[`flatten_data()`](https://melidosproject.github.io/melidosData/reference/flatten_data.md)
to stack multi-site results into one tibble with a `site` column.

See the README of the package for a description of sites and modalities.

## Examples

``` r
if (FALSE) { # interactive()
# load one questionnaire modality for two sites
sleep_all <- load_data("sleepdiaries", site = c("TUM", "RISE"))

# flatten to a single tibble with a site column
sleep_flat <- flatten_data(sleep_all, tz = "UTC")
head(sleep_flat)

# load one site only (returns a data frame)
sleep_tum <- load_data("sleepdiaries", site = "TUM")
}
```
