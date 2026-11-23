test_that("flattening separates wall-clock and absolute time semantics", {
  times <- list(
    TUM = as.POSIXct("2024-06-01 12:00:00", tz = "Europe/Berlin"),
    UCR = as.POSIXct("2024-06-01 12:00:00", tz = "America/Costa_Rica")
  )
  dat <- structure(
    purrr::map(times, ~ data.frame(timestamp = .x)),
    class = c("melidos_data", "list")
  )
  clock <- flatten_data(dat)
  instant <- flatten_data(dat, time_mode = "instant")
  expect_equal(
    format(clock$timestamp, tz = "UTC", format = "%H:%M"),
    c("12:00", "12:00")
  )
  expect_equal(
    as.numeric(instant$timestamp),
    purrr::map_dbl(times, as.numeric),
    ignore_attr = TRUE
  )
  expect_equal(
    format(instant$timestamp, tz = "UTC", format = "%H:%M"),
    c("10:00", "18:00")
  )
  expect_error(flatten_data(dat, label_from = 0), "valid integer index")
  expect_error(flatten_data(dat, label_from = NA_real_), "valid integer index")
  expect_error(flatten_data(dat, tz = "not/a/zone"), "Olson")
})

test_that("flattening preserves absolute instants across the autumn clock change", {
  utc <- as.POSIXct(c("2024-10-27 00:30:00", "2024-10-27 01:30:00"), tz = "UTC")
  local <- lubridate::with_tz(utc, "Europe/Berlin")
  dat <- structure(
    list(TUM = data.frame(time = local)),
    class = c("melidos_data", "list")
  )
  expect_identical(
    as.numeric(flatten_data(dat, time_mode = "instant")$time),
    as.numeric(utc)
  )
})

test_that("clock comparisons in UTC avoid spring daylight-saving gaps", {
  dat <- structure(
    list(
      TUM = data.frame(
        time = as.POSIXct("2024-03-31 02:30:00", tz = "UTC")
      )
    ),
    class = c("melidos_data", "list")
  )
  expect_true(is.na(flatten_data(dat, tz = "Europe/Berlin")$time))
  expect_identical(as.numeric(flatten_data(dat)$time), as.numeric(dat$TUM$time))
  expect_identical(
    as.numeric(
      flatten_data(dat, tz = "Europe/Berlin", time_mode = "instant")$time
    ),
    as.numeric(dat$TUM$time)
  )
})

test_that("REDCap date validation codes override labels and support all date orders", {
  codes <- c(
    "date_ymd",
    "date_dmy",
    "date_mdy",
    "datetime_ymd",
    "datetime_dmy",
    "datetime_mdy",
    "datetime_seconds_ymd",
    "datetime_seconds_dmy",
    "datetime_seconds_mdy"
  )
  dict <- data.frame(
    `Variable / Field Name` = paste0("v", seq_along(codes)),
    `Field Label` = rep("Date", length(codes)),
    `Field Type` = "text",
    `Text Validation Type OR Show Slider Number` = codes,
    check.names = FALSE
  )
  dat <- stats::setNames(
    rep(list(as.Date("2024-01-01")), length(codes)),
    dict[[1]]
  )
  dat[4:9] <- rep(list(as.POSIXct("2024-01-01 12:00:00", tz = "UTC")), 6)
  out <- REDCap_coltype_check(dict, data = as.data.frame(dat))
  expect_true(out$ok)
  expect_equal(nrow(out$details), length(codes))
  dat$v1 <- as.character(dat$v1)
  expect_false(REDCap_coltype_check(dict, data = as.data.frame(dat))$ok)
})

test_that("expanded checkbox choices retain every selection and their labels", {
  dict <- data.frame(
    `Variable / Field Name` = c("identity", "social"),
    `Field Type` = c("checkbox", "checkbox"),
    `Choices, Calculations, OR Slider Labels` = c(
      "1, Friend | 2, Colleague",
      "1, Alone | 2, Together"
    ),
    check.names = FALSE
  )
  dat <- data.frame(
    identity___1 = c(1, 0, NA),
    identity___2 = c(1, 1, 0),
    social_1 = c(TRUE, FALSE, NA),
    social_2 = c(FALSE, TRUE, TRUE)
  )
  expect_no_warning(out <- REDCap_factors(dat, dict))
  expect_identical(names(out), names(dat))
  expect_identical(
    as.character(out$identity___1),
    c("Checked", "Unchecked", NA_character_)
  )
  expect_identical(
    as.character(out$identity___2),
    c("Checked", "Checked", "Unchecked")
  )
  expect_identical(attr(out$identity___2, "checkbox_choice"), "Colleague")
  expect_identical(REDCap_factors(out, dict), out)
  dat$identity___2[1] <- 2
  expect_error(REDCap_factors(dat, dict), "identity___2.*must contain")
})

test_that("unexpanded radio conversions remain compatible", {
  dict <- data.frame(
    variable = "rating",
    type = "radio",
    choices = "1, Low | 2, High"
  )
  dat <- data.frame(rating = c(2, 1, NA))
  out <- REDCap_factors(dat, dict, variable, type, choices)
  expect_identical(as.character(out$rating), c("High", "Low", NA_character_))
})
