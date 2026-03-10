## code to prepare `general_parameters` dataset goes here

melidos_colors <-
  c(
    RISE     = "#88CCEE",  # Sky blue
    FUSPCEU      = "#CC6677",  # Coral red
    BAUA    = "#DDCC77",  # Mustard yellow
    TUM    = "#DDCC77",  # Mustard yellow
    MPI    = "#DDCC77",  # Mustard yellow
    THUAS= "#117733",  # Dark green
    IZTECH     = "#332288",  # Indigo
    KNUST      = "#AA4499",  # Purple-pink
    UCR = "#44AA99"   # Teal
  )

melidos_tzs <- c(
  RISE     = "Europe/Stockholm",
  FUSPCEU      = "Europe/Madrid",
  BAUA    = "Europe/Berlin",
  TUM    = "Europe/Berlin",
  MPI    = "Europe/Berlin",
  THUAS = "Europe/Amsterdam",
  IZTECH     = "Europe/Istanbul",
  KNUST      = "Africa/Accra",
  UCR = "America/Costa_Rica"
)

melidos_countries <- c(
  RISE     = "Sweden",
  FUSPCEU      = "Spain",
  BAUA    = "Germany",
  TUM    = "Germany",
  MPI    = "Germany",
  THUAS = "The Netherlands",
  IZTECH     = "Turkey",
  KNUST      = "Ghana",
  UCR = "Costa Rica"
)

melidos_cities <- c(
  RISE     = "Borås",
  FUSPCEU      = "Madrid",
  BAUA    = "Dortmund",
  TUM    = "Munich",
  MPI    = "Tübingen",
  THUAS = "Delft",
  IZTECH     = "Izmir",
  KNUST      = "Kumasi",
  UCR = "San Pedro, San José"
)

melidos_coordinates <- list(
  RISE     = c(57.715675, 12.890871),
  FUSPCEU      = c(40.4165, -3.70256),
  BAUA    = c(51.498204, 7.416708),
  TUM    = c(48.1333, 11.5667),
  MPI    = c(48.5216, 9.0576),
  THUAS = c(52.0116, 4.3571),
  IZTECH     = c(38.32, 26.63),
  KNUST      = c(6.6750074282377385, -1.572643823555129),
  UCR = c(9.9372, -84.0509)
)

usethis::use_data(melidos_colors,
                  melidos_tzs,
                  melidos_countries,
                  melidos_cities,
                  melidos_coordinates,
                  overwrite = TRUE)
