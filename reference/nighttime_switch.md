# Summarise times across midnight

Converts times before `cutoff` to the next day before applying `.fun`,
which helps summarise nighttime values spanning midnight (for example,
median sleep time).

## Usage

``` r
nighttime_switch(
  datetime,
  .fun = stats::median,
  cutoff = 12 * 60 * 60,
  hms = TRUE
)
```

## Arguments

- datetime:

  A date-time vector coercible to `POSIXct`.

- .fun:

  Summary function applied after the date shift.

- cutoff:

  Cutoff in seconds since midnight. Values below cutoff are treated as
  belonging to the next day.

- hms:

  Logical; if `TRUE`, return an `hms` object.

## Value

A summarised time as `hms` (default) or date-time.

## Examples

``` r
x <- as.POSIXct(c("2024-01-01 23:00:00", "2024-01-02 01:00:00"), tz = "UTC")
nighttime_switch(x)
#> 00:00:00
```
