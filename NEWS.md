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
