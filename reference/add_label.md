# Add a `label` attribute to a vector

Add a `label` attribute to a vector

## Usage

``` r
add_label(data, label)
```

## Arguments

- data:

  Vector-like object.

- label:

  Label text.

## Value

`data` with a `label` attribute.

## Examples

``` r
add_label(1:3, "Example variable")
#> [1] 1 2 3
#> attr(,"label")
#> [1] "Example variable"
```
