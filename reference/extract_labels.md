# Extract labels from a list of objects

Retrieves the `"label"` attribute from each element in a list and
returns a character vector of labels.

## Usage

``` r
extract_labels(data)
```

## Arguments

- data:

  A list of objects. Each element is expected to have a `"label"`
  attribute (e.g., created via `attr(x, "label") <- "some label"`).

## Value

A character vector containing the `"label"` attribute of each element in
`data`. If an element does not have a `"label"` attribute,
`NA_character_` is returned for that element.

## Examples

``` r
# Create example data with labels
x1 <- 1:3
attr(x1, "label") <- "First variable"

x2 <- 4:6
attr(x2, "label") <- "Second variable"

x3 <- 7:9
# No label set for x3

data <- list(x1, x2, x3)

# Extract labels
extract_labels(data)
#> [1] "First variable"  "Second variable" NA               

# Works for data frames as well
data <- data.frame (x1, x2, x3)
extract_labels(data)
#>                x1                x2                x3 
#>  "First variable" "Second variable"                NA 
```
