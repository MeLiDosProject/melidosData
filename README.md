
<!-- README.md is generated from README.Rmd. Please edit that file -->

# melidosData

<!-- badges: start -->

<!-- badges: end -->

<p align="center">
  <img src="man/figures/logo.png" width="180" alt="melidosData logo"/>
</p>

`melidosData` provides helper utilities and example assets for MeLiDos REDCap workflows.

The package currently focuses on:

- preparing REDCap codebooks,
- checking column types against codebook expectations,
- adding variable labels and factors from codebook metadata,
- handling common time summaries around midnight,
- shipping small example datasets and dictionaries for reproducible examples.

## Installation

You can install the development version of melidosData from GitHub with:

``` r
# install.packages("pak")
pak::pak("MeLiDosProject/melidosData")
```

## Example: using included codebooks and datasets

``` r
library(melidosData)

codebook_path <- system.file("ext", "DataDictionary_sleepdiary.csv", package = "melidosData")
codebook <- utils::read.csv(codebook_path, check.names = FALSE)

sleep <- REDCap_example_sleep

clean_codebook <- REDCap_codebook_prepare(codebook)
labelled_sleep <- add_col_labels(sleep, clean_codebook)

check <- REDCap_coltype_check(clean_codebook, data = labelled_sleep)
check$ok
```

## Example: factor conversion from REDCap dictionary choices

``` r
chrono_dict_path <- system.file("ext", "DataDictionary_chronotype.csv", package = "melidosData")
chrono_dict <- utils::read.csv(chrono_dict_path, check.names = FALSE)

chrono <- REDCap_factors(
  REDCap_example_chronotype,
  chrono_dict,
  var_col = `Variable / Field Name`,
  type_col = `Field Type`,
  levels_col = `Choices, Calculations, OR Slider Labels`
)

sapply(chrono, class)[1:5]
```
