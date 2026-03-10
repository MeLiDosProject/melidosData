## code to prepare `REDCap_data` dataset goes here

REDCap_example_chronotype <-
  vroom::vroom("inst/ext/example_chronotype.csv")

REDCap_example_sleep <-
  vroom::vroom("inst/ext/example_sleepdiary.csv") |>
  dplyr::filter_out(is.na(redcap_repeat_instance))

usethis::use_data(REDCap_example_chronotype,
                  REDCap_example_sleep,
                  overwrite = TRUE)
