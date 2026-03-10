test_that("add_labels applies labels without purrr", {
  dat <- data.frame(a = 1:2, b = 3:4)

  out <- add_labels(dat, c(a = "Column A"))

  expect_s3_class(out, "tbl_df")
  expect_equal(attr(out$a, "label"), "Column A")
  expect_null(attr(out$b, "label"))
})
