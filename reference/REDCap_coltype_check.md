# Check data column classes against REDCap expectations

Uses REDCap codebook metadata to infer expected classes and compares
these to classes in `data`.

## Usage

``` r
REDCap_coltype_check(
  codebook,
  indicator_POSIXct = "datetime_dmy",
  indicator_date = "Date",
  indicator_time = "time",
  indicator_logical = "yesno",
  indicator_numeric.val_col = c("number", "integer"),
  indicator_numeric.type_col = c("radio", "dropdown"),
  label_col = `Field Label`,
  name_col = `Variable / Field Name`,
  type_col = `Field Type`,
  val_col = `Text Validation Type OR Show Slider Number`,
  data
)
```

## Arguments

- codebook:

  REDCap data dictionary.

- indicator_POSIXct:

  Indicator in `val_col` identifying datetime fields.

- indicator_date:

  Pattern used in labels to identify date variables.

- indicator_time:

  Indicator in `val_col` identifying time-only fields.

- indicator_logical:

  Indicator in `type_col` identifying logical fields.

- indicator_numeric.val_col:

  Indicators in `val_col` for numeric fields.

- indicator_numeric.type_col:

  Indicators in `type_col` for numeric fields.

- label_col:

  Unquoted codebook label column.

- name_col:

  Unquoted codebook variable-name column.

- type_col:

  Unquoted codebook field-type column.

- val_col:

  Unquoted codebook validation/type-hint column.

- data:

  Data frame to validate.

## Value

A list with `ok`, `summary`, and per-column `details`.

## Examples

``` r

library(gt)
dict_path <- system.file("ext", "DataDictionary_sleepdiary.csv",
  package = "melidosData"
)
dict <- utils::read.csv(dict_path, check.names = FALSE)

coltype_check <- REDCap_coltype_check(dict, data = REDCap_example_sleep)
coltype_check$ok
#> [1] TRUE
coltype_check$summary
#> $missing
#> character(0)
#> 
#> $missing_by_expected
#> # A tibble: 0 × 2
#> # ℹ 2 variables: expected <chr>, cols <list>
#> 
#> $wrong_type
#> # A tibble: 0 × 3
#> # ℹ 3 variables: col <chr>, expected_type <chr>, actual_type <chr>
#> 
#> $ok
#>  [1] "bedtime"          "sleep"            "offset"           "out_ofbed"       
#>  [5] "sleepdelay"       "awakenings"       "awake_duration"   "sleepquality"    
#>  [9] "daytype2"         "status"           "scheduledate"     "record_id"       
#> [13] "comments"         "uuid"             "supplementaldata" "serializedresult"
#> 
coltype_check$details |> gt()


  

col
```
