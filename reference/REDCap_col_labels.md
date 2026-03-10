# Add variable labels from a REDCap codebook

Sets the `label` attribute on matching columns in `data`.

## Usage

``` r
REDCap_col_labels(
  data,
  lookup,
  var_col = `Variable / Field Name`,
  label_col = `Field Label`,
  warn = TRUE
)
```

## Arguments

- data:

  A data frame.

- lookup:

  A data frame with variable names and labels.

- var_col:

  Unquoted column in `lookup` containing variable names.

- label_col:

  Unquoted column in `lookup` containing human-readable labels.

- warn:

  Logical; warn when labels are provided for variables not present in
  `data`.

## Value

`data` with `label` attributes added.

## Examples

``` r
dict_path <- system.file("ext", "DataDictionary_chronotype.csv",
  package = "melidosData"
)
dict <- utils::read.csv(dict_path, check.names = FALSE)
dict <- REDCap_codebook_prepare(dict,  form.filter = "mctq")
labelled <- REDCap_col_labels(REDCap_example_chronotype, dict)
#> Warning: Labels provided for variables not in `data`: mctq_desctext_1, mctq_sleep_cycle_pic, mctq_desctext_2, mctq_desctext_3, mctq_desctext_4, mctq_reason, mctq_desctext_5, mctq_commute, mctq_desctext_6, mctq_outdoor, mctq_desctext_7
attr(labelled[[5]], "label")
#> [1] "I work on ... days per week"
```
