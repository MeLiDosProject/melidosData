test_that("nighttime_switch summarizes across midnight", {
  x <- as.POSIXct(c("2024-01-01 23:00:00", "2024-01-02 01:00:00"), tz = "UTC")

  out <- nighttime_switch(x)

  expect_true(inherits(out, "hms"))
  expect_equal(as.character(out), "00:00:00")
})
