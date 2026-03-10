
<!-- README.md is generated from README.Rmd. Please edit that file -->

# melidosData

<!-- badges: start -->

[![R-CMD-check](https://github.com/MeLiDosProject/melidosData/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/MeLiDosProject/melidosData/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

`melidosData` provides helper utilities and example assets for MeLiDos
REDCap workflows.

The package currently focuses on:

- preparing REDCap codebooks,
- checking column types against codebook expectations,
- adding variable labels and factors from codebook metadata,
- handling common time summaries around midnight,
- shipping small example datasets and dictionaries for reproducible
  examples.

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
labelled_sleep <- REDCap_col_labels(sleep, clean_codebook)

check <- REDCap_coltype_check(clean_codebook, data = labelled_sleep)
check$ok
#> [1] TRUE
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
#> Warning in REDCap_factors(REDCap_example_chronotype, chrono_dict, var_col =
#> `Variable / Field Name`, : Variables provided but not in `data`: mctq_reason,
#> meq_freewake, meq_freesleep, meq_alarm, meq_wakeupease, meq_mor_alert,
#> meq_mor_hunger, meq_mor_feel, meq_free_bedtime, meq_mor_exercise,
#> meq_eve_tired, meq_peak_perf, meq_eleven_tired, meq_delayed_sleep,
#> meq_shift_conseq, meq_phys_work, meq_eve_exercise, meq_ideal_week,
#> meq_besthour, meq_perceived_chron

sapply(chrono, class)[1:5]
#> $record_id
#> [1] "character"
#> 
#> $redcap_repeat_instrument
#> [1] "logical"
#> 
#> $redcap_repeat_instance
#> [1] "logical"
#> 
#> $mctq_regular_work
#> [1] "numeric"
#> 
#> $mctq_nr_workdays
#> [1] "factor"
```
