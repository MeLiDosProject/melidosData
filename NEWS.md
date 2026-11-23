# melidosData 1.0.7

* DESCRIPTION updated with the correct number of participants.

* `load_data()` now stops with the source URL and expected object when a site
  cannot be loaded. `on_failure = "warn"` retains failed entries for inspection;
  `flatten_data()` refuses to silently drop them.
* `load_data(ref = ...)` supports a shared Git revision or named revisions by
  site and records requested sources in the `melidos_sources` attribute.
* `flatten_data(time_mode = "instant")` preserves absolute instants. The default
  `"clock"` retains the existing local-clock behavior, now documented explicitly.
* `REDCap_factors()` supports expanded checkbox fields without collapsing
  multiple selections. `REDCap_coltype_check()` recognizes REDCap date and
  datetime validation codes for all supported date orders.

# melidosData 1.0.6

* DESCRIPTION updated to conform to CRAN requirements

# melidosData 1.0.5

* `load_data()`: Example was simplified so it does not require a *dontrun* exception

* DESCRIPTION now contains a reference to the Guidolin et al. protocol

# melidosData 1.0.4

* `load_data()`: closes connections after downloading. This could be an issue when downloading many modalities

# melidosData 1.0.3

* `flatten_data()`: fixed a bug that kept the labels from being displayed

# melidosData 1.0.2

* `flatten_data()`: keeps labels intact and warns if labels vary across sites

* `extract_labels()`: collects labels from a list or data.frame in a named vector (names are only available if the list contains names)

# melidosData 1.0.1

* `load_data()`: partial matching of arguments no longer works

* `load_data()`: supports `trial_times` modality.

# melidosData 1.0.0

* Initial stable GitHub release
