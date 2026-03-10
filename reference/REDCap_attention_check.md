# Evaluate a REDCap attention check column

Replaces a column with a logical pass/fail value based on membership in
`condition`, sets a label attribute, and moves the column to the end.

## Usage

``` r
REDCap_attention_check(
  data,
  check.column,
  condition,
  label = "Attention check successful"
)
```

## Arguments

- data:

  A data frame.

- check.column:

  Unquoted column to evaluate.

- condition:

  Vector of accepted responses.

- label:

  Label to attach to the resulting logical column.

## Value

`data` with an updated attention check column.

## Examples

``` r
dat <- data.frame(attention = c("A", "B", "A"))
REDCap_attention_check(dat, attention, condition = "A")
#>   attention
#> 1      TRUE
#> 2     FALSE
#> 3      TRUE
```
