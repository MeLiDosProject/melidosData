<!-- README.md is generated from README.Rmd. Please edit that file -->

# melidosData

<!-- badges: start -->

[![R-CMD-check](https://github.com/MeLiDosProject/melidosData/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/MeLiDosProject/melidosData/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

`melidosData` helps you **load MeLiDos data** and then **work with REDCap dictionaries and metadata**.

- Main workflow:
  - `load_data()` downloads a modality for one or many sites.
  - `flatten_data()` combines multi-site lists into one analysis-ready table.
- Helper workflow:
  - REDCap functions clean codebooks, add labels/factors, and perform QA checks.

## Installation

You can install the development version of melidosData from GitHub with:

``` r
# install.packages("pak")
pak::pak("MeLiDosProject/melidosData")
```

## Main workflow example

``` r
library(melidosData)

# one site -> data frame
# sleep_tum <- load_data("sleepdiaries", site = "TUM")

# many sites -> `melidos_data` list
# sleep_all <- load_data("sleepdiaries", site = c("TUM", "UCR"))

# flatten list output for analysis
# sleep_all_flat <- flatten_data(sleep_all, tz = "UTC")
```

> Note: examples above are commented to avoid network calls during README rendering.

## Mini vignette: REDCap helper workflow

``` r
# 1) load dictionary and clean labels
codebook_path <- system.file("ext", "DataDictionary_sleepdiary.csv", package = "melidosData")
codebook <- utils::read.csv(codebook_path, check.names = FALSE)
codebook_clean <- REDCap_codebook_prepare(codebook)

# 2) start with example REDCap export
sleep <- REDCap_example_sleep

# 3) attach human-readable labels from dictionary
sleep_labelled <- REDCap_col_labels(sleep, codebook_clean)

# 4) check expected column types against dictionary metadata
check <- REDCap_coltype_check(codebook_clean, data = sleep_labelled)
check$ok
```

``` r
# Optional: convert coded REDCap choice fields to factors
chrono_dict_path <- system.file("ext", "DataDictionary_chronotype.csv", package = "melidosData")
chrono_dict <- utils::read.csv(chrono_dict_path, check.names = FALSE)

chrono_factor <- REDCap_factors(
  REDCap_example_chronotype,
  chrono_dict,
  var_col = `Variable / Field Name`,
  type_col = `Field Type`,
  levels_col = `Choices, Calculations, OR Slider Labels`,
  warn = FALSE
)

sapply(chrono_factor[1:5], class)
```
