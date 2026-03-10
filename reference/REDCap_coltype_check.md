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

expected

present

actual

type_ok

issue

bedtime

POSIXct

TRUE

POSIXct

TRUE

ok

sleep

POSIXct

TRUE

POSIXct

TRUE

ok

offset

POSIXct

TRUE

POSIXct

TRUE

ok

out_ofbed

POSIXct

TRUE

POSIXct

TRUE

ok

sleepdelay

numeric

TRUE

numeric

TRUE

ok

awakenings

numeric

TRUE

numeric

TRUE

ok

awake_duration

numeric

TRUE

numeric

TRUE

ok

sleepquality

numeric

TRUE

numeric

TRUE

ok

daytype2

numeric

TRUE

numeric

TRUE

ok

status

numeric

TRUE

numeric

TRUE

ok

scheduledate

Date

TRUE

Date

TRUE

ok

record_id

character

TRUE

character

TRUE

ok

comments

character

TRUE

character

TRUE

ok

uuid

character

TRUE

character

TRUE

ok

supplementaldata

character

TRUE

character

TRUE

ok

serializedresult

character

TRUE

character

TRUE

ok

dict_path \<-
[system.file](https://rdrr.io/r/base/system.file.html)("ext",
"DataDictionary_chronotype.csv", package = "melidosData" ) dict \<-
utils::[read.csv](https://rdrr.io/r/utils/read.table.html)(dict_path,
check.names = FALSE) dict \<-
[REDCap_codebook_prepare](https://melidosproject.github.io/melidosData/reference/REDCap_codebook_prepare.md)(dict,
form.filter = "mctq") coltype_check \<- REDCap_coltype_check(dict, data
= REDCap_example_chronotype) coltype_check\$ok \#\> \[1\] FALSE
coltype_check\$summary \#\> \$missing \#\> \[1\] "mctq_desctext_1"
"mctq_sleep_cycle_pic" "mctq_desctext_2" \#\> \[4\] "mctq_desctext_3"
"mctq_desctext_4" "mctq_reason" \#\> \[7\] "mctq_desctext_5"
"mctq_commute" "mctq_desctext_6" \#\> \[10\] "mctq_outdoor"
"mctq_desctext_7" \#\> \#\> \$missing_by_expected \#\> \# A tibble: 1 ×
2 \#\> expected cols \#\> \<chr\> \<list\> \#\> 1 character \<chr
\[11\]\> \#\> \#\> \$wrong_type \#\> \# A tibble: 10 × 3 \#\> col
expected_type actual_type \#\> \<chr\> \<chr\> \<chr\> \#\> 1
mctq_outdoor_work_min numeric character \#\> 2 mctq_outdoor_free_min
numeric character \#\> 3 mctq_regular_work logical numeric \#\> 4
mctq_alarm_work logical numeric \#\> 5 mctq_wake_alarm logical numeric
\#\> 6 mctq_alarm_free logical numeric \#\> 7 mctq_choose_sleep_free
logical numeric \#\> 8 mctq_shift_work logical numeric \#\> 9
mctq_outdoor_work_calc character numeric \#\> 10 mctq_outdoor_free_calc
character numeric \#\> \#\> \$ok \#\> \[1\] "mctq_nr_workdays"
"mctq_fall_sleep_work" "mctq_get_up_work" \#\> \[4\]
"mctq_fall_sleep_free" "mctq_get_up_free" "mctq_work_flex" \#\> \[7\]
"mctq_work_travel" "mctq_com_to_work_h" "mctq_com_to_work_min" \#\>
\[10\] "mctq_com_from_work_h" "mctq_com_from_work_min"
"mctq_outdoor_work_h" \#\> \[13\] "mctq_outdoor_free_h"
"mctq_stim_cigar" "mctq_stim_beer" \#\> \[16\] "mctq_stim_wine"
"mctq_stim_liquor" "mctq_stim_coffee" \#\> \[19\] "mctq_stim_tea"
"mctq_stim_caf_drink" "mctq_stim_sleep_med" \#\> \[22\] "mctq_nr_cigar"
"mctq_nr_beer" "mctq_nr_wine" \#\> \[25\] "mctq_nr_liquor"
"mctq_nr_coffee" "mctq_nr_tea" \#\> \[28\] "mctq_nr_caf_drink"
"mctq_nr_sleep_med" "mctq_bedtime_work" \#\> \[31\]
"mctq_ready_sleep_work" "mctq_wake_time_work" "mctq_bedtime_free" \#\>
\[34\] "mctq_ready_sleep_free" "mctq_wake_time_free" "mctq_work_start"
\#\> \[37\] "mctq_work_end" "record_id" "mctq_reason_spec" \#\>
coltype_check\$details \|\>
[gt](https://gt.rstudio.com/reference/gt.html)()

| col                    | expected  | present | actual    | type_ok | issue      |
|:-----------------------|:----------|:-------:|:----------|:-------:|:-----------|
| mctq_nr_workdays       | numeric   |  TRUE   | numeric   |  TRUE   | ok         |
| mctq_fall_sleep_work   | numeric   |  TRUE   | numeric   |  TRUE   | ok         |
| mctq_get_up_work       | numeric   |  TRUE   | numeric   |  TRUE   | ok         |
| mctq_fall_sleep_free   | numeric   |  TRUE   | numeric   |  TRUE   | ok         |
| mctq_get_up_free       | numeric   |  TRUE   | numeric   |  TRUE   | ok         |
| mctq_work_flex         | numeric   |  TRUE   | numeric   |  TRUE   | ok         |
| mctq_work_travel       | numeric   |  TRUE   | numeric   |  TRUE   | ok         |
| mctq_com_to_work_h     | numeric   |  TRUE   | numeric   |  TRUE   | ok         |
| mctq_com_to_work_min   | numeric   |  TRUE   | numeric   |  TRUE   | ok         |
| mctq_com_from_work_h   | numeric   |  TRUE   | numeric   |  TRUE   | ok         |
| mctq_com_from_work_min | numeric   |  TRUE   | numeric   |  TRUE   | ok         |
| mctq_outdoor_work_h    | numeric   |  TRUE   | numeric   |  TRUE   | ok         |
| mctq_outdoor_work_min  | numeric   |  TRUE   | character |  FALSE  | wrong_type |
| mctq_outdoor_free_h    | numeric   |  TRUE   | numeric   |  TRUE   | ok         |
| mctq_outdoor_free_min  | numeric   |  TRUE   | character |  FALSE  | wrong_type |
| mctq_stim_cigar        | numeric   |  TRUE   | numeric   |  TRUE   | ok         |
| mctq_stim_beer         | numeric   |  TRUE   | numeric   |  TRUE   | ok         |
| mctq_stim_wine         | numeric   |  TRUE   | numeric   |  TRUE   | ok         |
| mctq_stim_liquor       | numeric   |  TRUE   | numeric   |  TRUE   | ok         |
| mctq_stim_coffee       | numeric   |  TRUE   | numeric   |  TRUE   | ok         |
| mctq_stim_tea          | numeric   |  TRUE   | numeric   |  TRUE   | ok         |
| mctq_stim_caf_drink    | numeric   |  TRUE   | numeric   |  TRUE   | ok         |
| mctq_stim_sleep_med    | numeric   |  TRUE   | numeric   |  TRUE   | ok         |
| mctq_nr_cigar          | numeric   |  TRUE   | numeric   |  TRUE   | ok         |
| mctq_nr_beer           | numeric   |  TRUE   | numeric   |  TRUE   | ok         |
| mctq_nr_wine           | numeric   |  TRUE   | numeric   |  TRUE   | ok         |
| mctq_nr_liquor         | numeric   |  TRUE   | numeric   |  TRUE   | ok         |
| mctq_nr_coffee         | numeric   |  TRUE   | numeric   |  TRUE   | ok         |
| mctq_nr_tea            | numeric   |  TRUE   | numeric   |  TRUE   | ok         |
| mctq_nr_caf_drink      | numeric   |  TRUE   | numeric   |  TRUE   | ok         |
| mctq_nr_sleep_med      | numeric   |  TRUE   | numeric   |  TRUE   | ok         |
| mctq_regular_work      | logical   |  TRUE   | numeric   |  FALSE  | wrong_type |
| mctq_alarm_work        | logical   |  TRUE   | numeric   |  FALSE  | wrong_type |
| mctq_wake_alarm        | logical   |  TRUE   | numeric   |  FALSE  | wrong_type |
| mctq_alarm_free        | logical   |  TRUE   | numeric   |  FALSE  | wrong_type |
| mctq_choose_sleep_free | logical   |  TRUE   | numeric   |  FALSE  | wrong_type |
| mctq_shift_work        | logical   |  TRUE   | numeric   |  FALSE  | wrong_type |
| mctq_bedtime_work      | time      |  TRUE   | hms       |  TRUE   | ok         |
| mctq_ready_sleep_work  | time      |  TRUE   | hms       |  TRUE   | ok         |
| mctq_wake_time_work    | time      |  TRUE   | hms       |  TRUE   | ok         |
| mctq_bedtime_free      | time      |  TRUE   | hms       |  TRUE   | ok         |
| mctq_ready_sleep_free  | time      |  TRUE   | hms       |  TRUE   | ok         |
| mctq_wake_time_free    | time      |  TRUE   | hms       |  TRUE   | ok         |
| mctq_work_start        | time      |  TRUE   | hms       |  TRUE   | ok         |
| mctq_work_end          | time      |  TRUE   | hms       |  TRUE   | ok         |
| record_id              | character |  TRUE   | character |  TRUE   | ok         |
| mctq_desctext_1        | character |  FALSE  | NA        |  FALSE  | missing    |
| mctq_sleep_cycle_pic   | character |  FALSE  | NA        |  FALSE  | missing    |
| mctq_desctext_2        | character |  FALSE  | NA        |  FALSE  | missing    |
| mctq_desctext_3        | character |  FALSE  | NA        |  FALSE  | missing    |
| mctq_desctext_4        | character |  FALSE  | NA        |  FALSE  | missing    |
| mctq_reason            | character |  FALSE  | NA        |  FALSE  | missing    |
| mctq_reason_spec       | character |  TRUE   | character |  TRUE   | ok         |
| mctq_desctext_5        | character |  FALSE  | NA        |  FALSE  | missing    |
| mctq_commute           | character |  FALSE  | NA        |  FALSE  | missing    |
| mctq_desctext_6        | character |  FALSE  | NA        |  FALSE  | missing    |
| mctq_outdoor           | character |  FALSE  | NA        |  FALSE  | missing    |
| mctq_outdoor_work_calc | character |  TRUE   | numeric   |  FALSE  | wrong_type |
| mctq_outdoor_free_calc | character |  TRUE   | numeric   |  FALSE  | wrong_type |
| mctq_desctext_7        | character |  FALSE  | NA        |  FALSE  | missing    |
