test_that("flatten_data binds site rows and enforces timezone", {
  dat <- structure(
    list(
      TUM = data.frame(
        id = 1,
        timestamp = as.POSIXct("2024-01-01 22:00:00", tz = "UTC")
      ),
      UCR = data.frame(
        id = 2,
        timestamp = as.POSIXct("2024-01-02 22:30:00", tz = "UTC")
      )
    ),
    class = c("melidos_data", "list")
  )

  out <- flatten_data(dat, tz = "Europe/Berlin")

  expect_s3_class(out, "tbl_df")
  expect_equal(out$site, c("TUM", "UCR"))
  expect_equal(attr(out$timestamp, "tzone"), "Europe/Berlin")
})

test_that("flatten_data errors on non-melidos_data input", {
  expect_error(
    flatten_data(list(a = data.frame(x = 1))),
    "Input must be a list dataset loaded with `load_data\(\)`"
  )
})

test_that("REDCap_codebook_prepare filters forms and strips formatting", {
  codebook <- data.frame(
    `Variable / Field Name` = c("q1", "q2"),
    `Form Name` = c("sleep", "other"),
    `Field Label` = c("<b>Bedtime</b><br>", "Other"),
    check.names = FALSE
  )

  out <- REDCap_codebook_prepare(
    codebook,
    strings_to_ignore = "<[^>]+>",
    form.filter = "sleep"
  )

  expect_equal(nrow(out), 1)
  expect_equal(out$`Field Label`, "Bedtime")
})

test_that("REDCap_attention_check returns labelled logical column", {
  dat <- data.frame(attention = c("A", "B", "A"))

  out <- REDCap_attention_check(dat, attention, condition = "A", label = "Passed")

  expect_type(out$attention, "logical")
  expect_equal(out$attention, c(TRUE, FALSE, TRUE))
  expect_equal(attr(out$attention, "label"), "Passed")
  expect_identical(names(out)[length(names(out))], "attention")
})

test_that("REDCap_coltype_check flags wrong and missing columns", {
  codebook <- data.frame(
    `Variable / Field Name` = c("q_date", "q_time", "q_num", "q_char", "q_missing"),
    `Field Label` = c("Date of assessment", "Clock time", "Numeric", "Character", "Missing"),
    `Field Type` = c("text", "text", "text", "text", "text"),
    `Text Validation Type OR Show Slider Number` = c("", "time", "number", "", ""),
    check.names = FALSE
  )

  dat <- data.frame(
    q_date = as.Date("2024-01-01"),
    q_time = hms::as_hms("08:00:00"),
    q_num = "not_numeric",
    q_char = "ok",
    stringsAsFactors = FALSE
  )

  out <- REDCap_coltype_check(codebook, data = dat)

  expect_false(out$ok)
  expect_true("q_missing" %in% out$summary$missing)
  expect_true("q_num" %in% out$summary$wrong_type$col)
})
