# Convert REDCap choice fields to factors

Applies factor levels and labels using REDCap dictionary definitions for
`radio` and `checkbox` fields (configurable via `radio_value`).

## Usage

``` r
REDCap_factors(
  data,
  lookup,
  var_col = `Variable / Field Name`,
  type_col = `Field Type`,
  levels_col = `Choices, Calculations, OR Slider Labels`,
  radio_value = c("checkbox", "radio"),
  warn = TRUE
)
```

## Arguments

- data:

  Data frame containing REDCap records.

- lookup:

  Data frame containing variable metadata.

- var_col:

  Unquoted column in `lookup` with variable names.

- type_col:

  Unquoted column in `lookup` with REDCap field types.

- levels_col:

  Unquoted column in `lookup` with coded levels (`"1, Yes | 0, No"`
  format).

- radio_value:

  Character vector of field types to convert.

- warn:

  Logical; warn when variables are in `lookup` but absent from `data`.

## Value

`data` with selected columns converted to factors.

## Examples

``` r
dict_path <- system.file("ext", "DataDictionary_chronotype.csv",
  package = "melidosData"
)
dict <- utils::read.csv(dict_path, check.names = FALSE)
dict <- REDCap_codebook_prepare(dict, form.filter = "mctq")

chronotype_with_factors <-
REDCap_factors(
  data = REDCap_example_chronotype,
  lookup = dict
)
#> Warning: Variables provided but not in `data`: mctq_reason

chronotype_with_factors$mctq_work_travel
#>  [1] not within an enclosed vehicle (e.g. on foot, by bike). 
#>  [2] within an enclosed vehicle (e.g. car, bus, underground).
#>  [3] within an enclosed vehicle (e.g. car, bus, underground).
#>  [4] not within an enclosed vehicle (e.g. on foot, by bike). 
#>  [5] not within an enclosed vehicle (e.g. on foot, by bike). 
#>  [6] within an enclosed vehicle (e.g. car, bus, underground).
#>  [7] within an enclosed vehicle (e.g. car, bus, underground).
#>  [8] within an enclosed vehicle (e.g. car, bus, underground).
#>  [9] not within an enclosed vehicle (e.g. on foot, by bike). 
#> [10] not within an enclosed vehicle (e.g. on foot, by bike). 
#> [11] not within an enclosed vehicle (e.g. on foot, by bike). 
#> [12] not within an enclosed vehicle (e.g. on foot, by bike). 
#> [13] not within an enclosed vehicle (e.g. on foot, by bike). 
#> [14] not within an enclosed vehicle (e.g. on foot, by bike). 
#> [15] not within an enclosed vehicle (e.g. on foot, by bike). 
#> [16] within an enclosed vehicle (e.g. car, bus, underground).
#> [17] within an enclosed vehicle (e.g. car, bus, underground).
#> 3 Levels: within an enclosed vehicle (e.g. car, bus, underground). ...
#original:
REDCap_example_chronotype$mctq_work_travel
#>  [1] 2 1 1 2 2 1 1 1 2 2 2 2 2 2 2 1 1
```
